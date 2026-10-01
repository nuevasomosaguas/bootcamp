# Corrige la entrega de la semana 2, laboratorio_semana2.jl y flujo.sh en esta carpeta:
#   julia --project=semana-02 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-02 --depwarn=yes semana-02/test_semana2.jl
using Test, Logging, LinearAlgebra, Random

const script = joinpath(@__DIR__, "laboratorio_semana2.jl")
const resultados = joinpath(@__DIR__, "resultados")
const entrega = Module(:Entrega)

perdida(Q) = opnorm(Q' * Q - I)
hilbert(m, n) = [1 / (i + j - 1) for i in 1:m, j in 1:n]

@testset "Semana 2" begin
    rm(resultados; force = true, recursive = true)

    @testset "se ejecuta sin excepciones ni advertencias" begin
        @test_logs min_level = Logging.Warn Base.include(entrega, script)
    end

    @testset "deja la figura y la tabla en resultados/" begin
        @test isfile(joinpath(resultados, "ortogonalidad.csv"))
        @test isdir(resultados) && any(endswith(".png"), readdir(resultados))
    end

    @testset "test_mgs" begin
        A = randn(Xoshiro(1), 50, 20)
        Q, R = entrega.mgs(A)
        @test Q * R ≈ A
        @test perdida(Q) < 1e-12
        @test istriu(R) && all(>(0), diag(R))
        # Con κ ≈ 6·10⁸, Gram-Schmidt clásico pierde la ortogonalidad (≈ 1), Householder
        # no la pierde (≈ 10⁻¹⁵) y el modificado queda entre ambos (≈ 10⁻⁸).
        @test 1e-12 < perdida(entrega.mgs(hilbert(12, 8))[1]) < 1e-6
    end

    @testset "test_flujo_posix" begin
        filas = split.(readlines(joinpath(resultados, "ortogonalidad.csv"))[2:end], ",")
        esperado = join((f[1] * "\n" for f in filas if parse(Float64, f[3]) > 1e-6))
        @test read(Cmd(`sh flujo.sh`; dir = @__DIR__), String) == esperado
    end
end
