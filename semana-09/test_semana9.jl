# Corrige la entrega de la semana 9, laboratorio_semana9.jl y ficha.typ en esta carpeta:
#   julia --project=semana-09 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-09 --depwarn=yes semana-09/test_semana9.jl
using Test, Logging, SHA

const script = joinpath(@__DIR__, "laboratorio_semana9.jl")
const ficha = joinpath(@__DIR__, "ficha.typ")
const resultados = joinpath(@__DIR__, "resultados")
const zip_defunciones = joinpath(@__DIR__, "datos", "datos_2024.zip")
# La versión de los microdatos con la que se escribió la semana: si el INE revisa el archivo,
# las defunciones dejan de cuadrar, y esta suma lo dice antes.
const sha256_defunciones = "33682a2f2965f72863ff1a899fe98e747f828862eed17146aea0f8e6ced3d3c1"
const entrega = Module(:Entrega)

git(args...) = Cmd(`git $args`; dir = dirname(@__DIR__))
numero(s) = parse(Float64, replace(s, "." => "", "," => "."))

# Las tablas del INE, leídas aquí por su cuenta: (sexo, año, función) => valores por edad
const ine = let t = Dict{Tuple{String, Int, String}, Vector{Float64}}()
    for linea in Iterators.drop(eachline(joinpath(@__DIR__, "datos", "tablas_mortalidad.csv")), 1)
        s, edad, f, año, valor = split(linea, ';')
        v = get!(() -> zeros(101), t, (String(s), parse(Int, año), String(f)))
        v[parse(Int, first(split(edad))) + 1] = numero(valor)
    end
    t
end
e0(sexo, año) = ine[(sexo, año, "Esperanza de vida")][1]
tabla_publicada(sexo, año) = (l = ine[(sexo, año, "Supervivientes")], L = ine[(sexo, año, "Población estacionaria")],
                              T = ine[(sexo, año, "Tiempo por vivir")])

# Arriaga, escrito aquí con los efectos directo e indirecto por separado
function arriaga_referencia(t1, t2)
    w = length(t1.l); l0 = t1.l[1]
    directo = [t1.l[i] / l0 * (t2.L[i] / t2.l[i] - t1.L[i] / t1.l[i]) for i in 1:w-1]
    indirecto = [t2.T[i+1] / l0 * (t1.l[i] / t2.l[i] - t1.l[i+1] / t2.l[i+1]) for i in 1:w-1]
    return [directo .+ indirecto; t1.l[w] / l0 * (t2.T[w] / t2.l[w] - t1.T[w] / t1.l[w])]
end

@testset "Semana 9" begin
    rm(resultados; force = true, recursive = true)

    @testset "se ejecuta sin excepciones ni advertencias" begin
        @test_logs min_level = Logging.Warn Base.include(entrega, script)
    end

    @testset "deja la figura en resultados/" begin
        @test isdir(resultados) && any(endswith(".png"), readdir(resultados))
    end

    @testset "los microdatos son los de la semana" begin
        @test bytes2hex(open(sha256, zip_defunciones)) == sha256_defunciones
        @test success(git("check-ignore", "-q", "semana-09/datos/datos_2024.zip"))
        @test isempty(readchomp(git("ls-files", "semana-09/datos/datos_2024.zip")))
    end

    @testset "test_tabla_vida" begin
        # Con las tasas y los aₓ del INE, la tabla de la entrega reproduce la publicada
        for (s, año) in (("Ambos sexos", 2019), ("Mujeres", 2024))
            t = entrega.tabla_vida(ine[(s, año, "Tasa de mortalidad")] ./ 1000,
                                   ine[(s, año, "Promedio de años vividos el último año de vida")])
            @test t.e ≈ ine[(s, año, "Esperanza de vida")] rtol = 1e-5
            @test t.l[1] == 100_000 && sum(t.d) ≈ 100_000 && t.q[end] == 1
        end
    end

    @testset "test_lexis" begin
        (; replicada, por_sexo, residentes, poblacion, tasas_lexis) = entrega
        @test all(r -> r.residente, residentes) && length(residentes) == count(r -> r.residente, entrega.defunciones)
        @test replicada.e[1] ≈ e0("Ambos sexos", 2024) atol = 2e-3
        @test replicada.m ≈ ine[("Ambos sexos", 2024, "Tasa de mortalidad")] ./ 1000 rtol = 2e-3
        for s in ("Hombres", "Mujeres")
            @test por_sexo[s].e[1] ≈ e0(s, 2024) atol = 2e-3
        end
        # La función, no un vector copiado: las mujeres, calculadas aquí con ella
        m, a = tasas_lexis(filter(r -> r.sexo == "Mujeres", residentes), poblacion("Mujeres", 2024),
                           poblacion("Mujeres", 2025), 2024)
        @test m ≈ ine[("Mujeres", 2024, "Tasa de mortalidad")] ./ 1000 rtol = 3e-3
        @test a[end] ≈ ine[("Mujeres", 2024, "Promedio de años vividos el último año de vida")][end] rtol = 1e-3
    end

    @testset "test_arriaga" begin
        t1, t2 = tabla_publicada("Ambos sexos", 2019), tabla_publicada("Ambos sexos", 2020)
        Δ = entrega.arriaga(t1, t2)
        @test sum(Δ) ≈ e0("Ambos sexos", 2020) - e0("Ambos sexos", 2019) atol = 1e-6
        @test Δ ≈ arriaga_referencia(t1, t2) rtol = 1e-8
        h, m = tabla_publicada("Hombres", 2024), tabla_publicada("Mujeres", 2024)   # otro par
        @test sum(entrega.arriaga(h, m)) ≈ e0("Mujeres", 2024) - e0("Hombres", 2024) atol = 1e-6
        @test entrega.esperanza_temporal(t1, 0, 65) ≈ (t1.T[1] - t1.T[66]) / t1.l[1]
        @test entrega.esperanza_temporal(t2, 15, 35) ≈ (t2.T[16] - t2.T[51]) / t2.l[16]
    end

    @testset "test_ficha" begin
        @test occursin("toml(", read(ficha, String))           # los números salen del script
        @test success(Cmd(`typst compile ficha.typ 'resultados/ficha-{p}.png'`; dir = @__DIR__))
        @test count(startswith("ficha-"), readdir(resultados)) == 1   # una sola página
    end
end
