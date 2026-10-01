# Corrige la entrega de la semana 10, laboratorio_semana10.jl en esta carpeta:
#   julia --project=semana-10 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-10 --depwarn=yes semana-10/test_semana10.jl
using Test, Logging

const script = joinpath(@__DIR__, "laboratorio_semana10.jl")
const resultados = joinpath(@__DIR__, "resultados")
const entrega = Module(:Entrega)

numero(s) = parse(Float64, replace(s, "." => "", "," => "."))
lineas(archivo) = [split(l, ';') for l in Iterators.drop(eachline(archivo), 1)]
const pob = lineas(joinpath(@__DIR__, "..", "semana-09", "datos", "poblacion.csv"))
const tablas = lineas(joinpath(@__DIR__, "..", "semana-09", "datos", "tablas_mortalidad.csv"))
const nac = lineas(joinpath(@__DIR__, "datos", "nacimientos.csv"))
const orden = lineas(joinpath(@__DIR__, "datos", "nacimientos_orden.csv"))

# Lo mismo que el script, escrito aquí por su cuenta, solo para las edades fértiles, 15 a 49
edad_madre(s) = s == "Menos de 15 años" ? 15 : s == "50 y más años" ? 49 : parse(Int, first(split(s)))
mujeres(año, x) = sum(numero(c[4]) for c in pob if c[2] == "Mujeres" && c[1] in ("$x años", "$x año") &&
                      c[3] in ("1 de enero de $año", "1 de enero de $(año + 1)")) / 2
function tasas(año, filas_año)
    b = zeros(35)
    for (edad, valor) in filas_año
        edad == "Todas las edades" || (b[edad_madre(edad) - 14] += numero(valor))
    end
    return b ./ [mujeres(año, x) for x in 15:49]
end
tasas_total(año, sexo = "Total") = tasas(año, [(c[3], c[5]) for c in nac if c[2] == sexo && c[4] == "$año"])
tasas_orden(año, os) = tasas(año, [(c[2], c[5]) for c in orden if c[3] in os && c[4] == "$año"])
const ordenes = [["Primero"], ["Segundo"], ["Tercero"],
                 ["Cuarto", "Quinto", "Sexto", "Séptimo", "Octavo", "Noveno", "Décimo y más"]]
function bf_referencia(año)
    edad(f) = sum((15.5:49.5) .* f) / sum(f)
    return sum(sum(tasas_orden(año, o)) / (1 - (edad(tasas_orden(año + 1, o)) - edad(tasas_orden(año - 1, o))) / 2)
               for o in ordenes)
end

# Euler-Lotka por bisección: ψ(r) = Σ e^{-r(x+½)} φₓ - 1 es decreciente en r
function raiz_referencia(φ)
    ψ(r) = sum(exp.(-r .* ((0:length(φ)-1) .+ 0.5)) .* φ) - 1
    a, b = -1.0, 1.0
    for _ in 1:200
        m = (a + b) / 2
        ψ(m) > 0 ? (a = m) : (b = m)
    end
    return (a + b) / 2
end

@testset "Semana 10" begin
    rm(resultados; force = true, recursive = true)

    @testset "se ejecuta sin excepciones ni advertencias" begin
        @test_logs min_level = Logging.Warn Base.include(entrega, script)
    end

    @testset "deja la figura en resultados/" begin
        @test isdir(resultados) && any(endswith(".png"), readdir(resultados))
    end

    @testset "test_fecundidad" begin
        @test entrega.fecundidad(2024)[16:50] ≈ tasas_total(2024) rtol = 1e-10
        @test entrega.isf ≈ [sum(tasas_total(t)) for t in 2015:2024] rtol = 1e-10
    end

    @testset "test_euler_lotka" begin
        L = zeros(101)
        for c in tablas
            c[1] == "Mujeres" && c[3] == "Población estacionaria" && c[4] == "2024" &&
                (L[parse(Int, first(split(c[2]))) + 1] = numero(c[5]) / 100_000)
        end
        δ = sum(tasas_total(2024, "Mujeres") .* [mujeres(2024, x) for x in 15:49]) /
            sum(tasas_total(2024) .* [mujeres(2024, x) for x in 15:49])
        φ = zeros(101); φ[16:50] = L[16:50] .* tasas_total(2024) .* δ
        @test entrega.φ ≈ φ rtol = 1e-10
        @test entrega.R0 ≈ sum(φ) rtol = 1e-10
        @test entrega.r ≈ raiz_referencia(φ) atol = 1e-12
        @test entrega.T ≈ log(sum(φ)) / raiz_referencia(φ) rtol = 1e-8
        # La función, con problemas cuya raíz se conoce: todas las hijas a los 30 años
        ψ = zeros(60); ψ[31] = 2.0
        @test entrega.euler_lotka(ψ) ≈ log(2) / 30.5 atol = 1e-12
        @test abs(entrega.euler_lotka(φ ./ sum(φ))) < 1e-12        # R₀ = 1 da r = 0
        @test entrega.euler_lotka(3 .* φ) ≈ raiz_referencia(3 .* φ) atol = 1e-12
    end

    @testset "test_bongaarts_feeney" begin
        @test entrega.isf_ajustado ≈ [bf_referencia(t) for t in 2016:2023] rtol = 1e-8
        @test entrega.bongaarts_feeney(2019) ≈ bf_referencia(2019) rtol = 1e-8
    end
end
