# Corrige la entrega de la semana 4, laboratorio_semana4.jl en esta carpeta:
#   julia --project=semana-04 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-04 --depwarn=yes semana-04/test_semana4.jl
using Test, Logging, LinearAlgebra

const script = joinpath(@__DIR__, "laboratorio_semana4.jl")
const resultados = joinpath(@__DIR__, "resultados")
const entrega = Module(:Entrega)

@testset "Semana 4" begin
    rm(resultados; force = true, recursive = true)

    @testset "estima sin paquetes de regresión" begin
        @test !occursin(r"\b(GLM|FixedEffectModels|MLJ\w*|lm)\b", read(script, String))
    end

    @testset "se ejecuta sin excepciones ni advertencias" begin
        @test_logs min_level = Logging.Warn Base.include(entrega, script)
    end

    @testset "deja el panel en resultados/" begin
        @test isdir(resultados) && any(endswith(".png"), readdir(resultados))
    end

    @testset "test_ortogonalidad" begin
        (; X, y, residuos) = entrega
        @test residuos ≈ y - X * (X \ y)   # los residuos son los de la proyección de y sobre col(X)
        @test norm(X' * residuos, Inf) < 1e-10
    end

    @testset "test_descomposicion_varianza" begin
        (; ss_tot, ss_reg, ss_res) = entrega
        @test ss_reg + ss_res ≈ ss_tot rtol = 1e-12
    end
end
