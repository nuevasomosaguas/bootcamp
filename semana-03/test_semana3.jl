# Corrige la entrega de la semana 3, laboratorio_semana3.jl en esta carpeta, y el historial
# de Git del repositorio:
#   julia --project=semana-03 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-03 --depwarn=yes semana-03/test_semana3.jl
using Test, Logging, LinearAlgebra, Random

const script = joinpath(@__DIR__, "laboratorio_semana3.jl")
const resultados = joinpath(@__DIR__, "resultados")
const raiz = dirname(@__DIR__)
const entrega = Module(:Entrega)

git(args...) = Cmd(`git $args`; dir = raiz)
asignado(f, args...) = (f(args...); @allocated f(args...))   # la primera llamada compila
error_relativo(x, x₀) = norm(x - x₀) / norm(x₀)

@testset "Semana 3" begin
    rm(resultados; force = true, recursive = true)

    @testset "se ejecuta sin excepciones ni advertencias" begin
        @test_logs min_level = Logging.Warn Base.include(entrega, script)
    end

    @testset "deja la figura en resultados/" begin
        @test isdir(resultados) && any(endswith(".png"), readdir(resultados))
    end

    @testset "test_sustitucion_atras" begin
        rng = Xoshiro(1)
        R = triu(randn(rng, 50, 50)) + 10I
        c, x = randn(rng, 50), zeros(50)
        @test entrega.sustitucion_atras!(x, R, c) === x
        @test R * x ≈ c
        @test asignado(entrega.sustitucion_atras!, x, R, c) == 0
    end

    @testset "test_minimos_cuadrados_mgs" begin
        A = randn(Xoshiro(2), 200, 6)
        b = randn(Xoshiro(3), 200)
        @test entrega.minimos_cuadrados_mgs(A, b) ≈ A \ b
        # En el problema de grado 9, κ(A) ≈ 4·10⁶: Rx = Qᵀb con la Q de Gram-Schmidt
        # modificado se equivoca en ≈ 10⁻⁵, como la ecuación normal; MGS sobre [A b], en ≈ 10⁻¹².
        (; A, b, x_real) = entrega
        @test error_relativo(entrega.minimos_cuadrados_mgs(A, b), x_real) < 1e-8
    end

    @testset "test_historial_git" begin
        @test !isempty(readchomp(git("log", "--merges", "--oneline")))
        @test success(git("check-ignore", "-q", "semana-03/resultados/minimos_cuadrados.png"))
        @test isempty(readchomp(git("ls-files", "semana-03/resultados")))
    end
end
