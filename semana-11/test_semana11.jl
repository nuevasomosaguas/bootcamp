# Corrige la entrega de la semana 11, laboratorio_semana11.jl en esta carpeta:
#   julia --project=semana-11 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-11 --depwarn=yes semana-11/test_semana11.jl
using Test, Logging, LinearAlgebra, Random

const script = joinpath(@__DIR__, "laboratorio_semana11.jl")
const resultados = joinpath(@__DIR__, "resultados")
const datos9 = joinpath(@__DIR__, "..", "semana-09", "datos")
const entrega = Module(:Entrega)

numero(s) = parse(Float64, replace(s, "." => "", "," => "."))
lineas(archivo) = [split(l, ';') for l in Iterators.drop(eachline(archivo), 1)]
const pob = lineas(joinpath(datos9, "poblacion.csv"))
const tablas = lineas(joinpath(datos9, "tablas_mortalidad.csv"))
const nac = lineas(joinpath(@__DIR__, "..", "semana-10", "datos", "nacimientos.csv"))

# La matriz de Leslie de referencia, construida aquí por su cuenta
function mujeres(año)
    p = zeros(101)
    for c in pob
        c[2] == "Mujeres" && c[3] == "1 de enero de $año" || continue
        m = match(r"^(\d+) años?$", c[1])
        m !== nothing && parse(Int, m[1]) < 100 && (p[parse(Int, m[1]) + 1] = numero(c[4]))
        c[1] == "100 y más años" && (p[101] = numero(c[4]))
    end
    return p
end
funcion(f) = (v = zeros(101); for c in tablas
    c[1] == "Mujeres" && c[3] == f && c[4] == "2024" && (v[parse(Int, first(split(c[2]))) + 1] = numero(c[5]) / 100_000)
end; v)
edad_madre(s) = s == "Menos de 15 años" ? 15 : s == "50 y más años" ? 49 : parse(Int, first(split(s)))
nacidos(sexo) = (b = zeros(101); for c in nac
    c[2] == sexo && c[4] == "2024" && c[3] != "Todas las edades" && (b[edad_madre(c[3]) + 1] += numero(c[5]))
end; b)
const Lx, Tx = funcion("Población estacionaria"), funcion("Tiempo por vivir")
const fx = nacidos("Total") ./ ((mujeres(2024) .+ mujeres(2025)) ./ 2)
const δ = sum(nacidos("Mujeres")) / sum(nacidos("Total"))
const sx = [Lx[2:100] ./ Lx[1:99]; Tx[101] / Tx[100]]
const A = let A = zeros(101, 101)
    for x in 0:99
        A[x + 2, x + 1] = sx[x + 1]
        A[1, x + 1] = Lx[1] / 2 * (fx[x + 1] + sx[x + 1] * fx[x + 2]) * δ
    end
    A[101, 101] = sx[100]
    A
end
dominante(M) = maximum(real, eigvals(M))
const λref = dominante(A)

# La raíz de Euler-Lotka de la semana 10, por bisección
const rref = let φ = Lx .* fx .* δ, a = -1.0, b = 1.0
    for _ in 1:200
        c = (a + b) / 2
        sum(exp.(-c .* ((0:100) .+ 0.5)) .* φ) > 1 ? (a = c) : (b = c)
    end
    (a + b) / 2
end

# La migración neta por el método residual, con las defunciones de mujeres residentes
function migracion_referencia()
    muertes = Dict{Int, Int}()
    for l in Iterators.drop(eachline(`unzip -p $(joinpath(datos9, "datos_2024.zip")) CSV/MNPdefun_2024.tab`), 1)
        c = split(l, '\t')
        c[5] == "6" && c[14] == "1" && (g = parse(Int, c[4]); muertes[g] = get(muertes, g, 0) + 1)
    end
    P0, P1 = mujeres(2024), mujeres(2025)
    m = [P1[1] - sum(nacidos("Mujeres")) + get(muertes, 2024, 0);
         [P1[x + 2] - P0[x + 1] + get(muertes, 2023 - x, 0) for x in 0:98];
         P1[101] - P0[100] - P0[101] + sum(n for (g, n) in muertes if g <= 1924)]
    return m
end

@testset "Semana 11" begin
    rm(resultados; force = true, recursive = true)

    @testset "se ejecuta sin excepciones ni advertencias" begin
        @test_logs min_level = Logging.Warn Base.include(entrega, script)
    end

    @testset "deja la figura en resultados/" begin
        @test isdir(resultados) && any(endswith(".png"), readdir(resultados))
    end

    @testset "test_leslie" begin
        @test entrega.A ≈ A rtol = 1e-10
        # La ecuación característica de Leslie es la de Euler-Lotka discreta
        @test sum(A[1, k] * prod(sx[1:k-1]) * λref^(-k) for k in 1:100) ≈ 1 rtol = 1e-10
        @test log(λref) ≈ rref atol = 1e-5
    end

    @testset "test_potencia" begin
        λ, w, k = entrega.metodo_potencia(A)
        @test λ ≈ λref rtol = 1e-10
        @test sum(w) ≈ 1 && all(>(0), w)
        @test A * w ≈ λ * w rtol = 1e-8
        @test 1 < k < 100_000
        # Otra matriz, con su autovalor dominante conocido
        B = rand(Xoshiro(11), 6, 6) .+ 0.1
        λB, wB, _ = entrega.metodo_potencia(B)
        @test λB ≈ dominante(B) rtol = 1e-10
        @test B * wB ≈ λB * wB rtol = 1e-8
        @test entrega.amortiguamiento ≈ λref / sort(abs.(eigvals(A)); rev = true)[2] rtol = 1e-8
    end

    @testset "test_sensibilidad" begin
        (; v, w, S, E, λ) = entrega
        @test v[1] ≈ 1
        @test v' * A ≈ λ * v' rtol = 1e-8
        h = 1e-7
        for (i, j) in ((2, 1), (1, 31), (40, 39), (1, 20))
            Ah = copy(A); Ah[i, j] += h
            @test S[i, j] ≈ (dominante(Ah) - λref) / h rtol = 1e-4
        end
        @test entrega.sensibilidad(A, v, w) ≈ S
        @test sum(E) ≈ 1 rtol = 1e-8
    end

    @testset "test_inercia" begin
        A1 = copy(A); A1[1, :] ./= sum(Lx .* fx .* δ)
        @test dominante(A1) ≈ 1 atol = 1e-10            # la fecundidad de reemplazo da λ = 1
        n0 = mujeres(2025)
        z = copy(n0); for _ in 1:3000; z = A1 * z; end
        @test entrega.inercia(A1, n0) ≈ sum(z) / sum(n0) rtol = 1e-6
        @test entrega.M ≈ sum(z) / sum(n0) rtol = 1e-6
        u = [ones(50); zeros(51)]                        # otra población inicial
        z = copy(u); for _ in 1:3000; z = A1 * z; end
        @test entrega.inercia(A1, u) ≈ sum(z) / sum(u) rtol = 1e-6
    end

    @testset "test_migracion" begin
        m = migracion_referencia()
        @test entrega.m == m
        n = entrega.poblacion_estacionaria(A, m)
        @test n ≈ A * n + m rtol = 1e-10
        @test entrega.poblacion_estacionaria(A, 2 .* m) ≈ 2 .* n rtol = 1e-10
    end
end
