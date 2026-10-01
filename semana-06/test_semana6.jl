# Corrige la entrega de la semana 6, laboratorio_semana6.jl en esta carpeta:
#   julia --project=semana-06 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-06 --depwarn=yes semana-06/test_semana6.jl
using Test, Logging, Statistics

const script = joinpath(@__DIR__, "laboratorio_semana6.jl")
const resultados = joinpath(@__DIR__, "resultados")
const entrega = Module(:Entrega)

@testset "Semana 6" begin
    rm(resultados; force = true, recursive = true)

    @testset "se ejecuta sin excepciones ni advertencias" begin
        @test_logs min_level = Logging.Warn Base.include(entrega, script)
    end

    @testset "deja el panel en resultados/" begin
        @test isdir(resultados) && any(endswith(".png"), readdir(resultados))
    end

    @testset "test_bayes_conjugada" begin
        (; α, β, k, n, muestras) = entrega
        @test length(muestras) == 100_000
        @test mean(muestras) ≈ (α + k) / (α + β + n) rtol = 1e-3
    end

    @testset "pérdida esperada del ejercicio 3" begin
        (; muestras, perdida_intervenir, perdida_no_intervenir) = entrega
        @test perdida_intervenir ≈ 500_000 * mean(<(0.40), muestras)
        @test perdida_no_intervenir ≈ 2_000_000 * mean(>=(0.40), muestras)
    end
end
