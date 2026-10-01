# Corrige la entrega de la semana 1, laboratorio_semana1.jl en esta carpeta:
#   julia --project=semana-01 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-01 --depwarn=yes semana-01/test_semana1.jl
using Test, LinearAlgebra, Logging

const script = joinpath(@__DIR__, "laboratorio_semana1.jl")
const resultados = joinpath(@__DIR__, "resultados")
const entrega = Module(:Entrega)

@testset "Semana 1" begin
    rm(resultados; force = true, recursive = true)

    @testset "se ejecuta sin excepciones ni advertencias" begin
        @test_logs min_level = Logging.Warn Base.include(entrega, script)
    end

    @testset "deja las dos figuras en resultados/" begin
        pngs = isdir(resultados) ? filter(endswith(".png"), readdir(resultados)) : String[]
        @test length(pngs) >= 2
    end

    @testset "test_normas_unitarias" begin
        V̄ = entrega.normalizar(entrega.V)
        @test size(V̄) == size(entrega.V)
        @test all(abs.(norm.(eachrow(V̄)) .- 1) .<= 1e-7)
    end
end
