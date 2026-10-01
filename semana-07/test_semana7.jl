# Corrige la entrega de la semana 7, laboratorio_semana7.jl en esta carpeta:
#   julia --project=semana-07 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-07 --depwarn=yes semana-07/test_semana7.jl
using Test, Logging, LinearAlgebra, Random

const script = joinpath(@__DIR__, "laboratorio_semana7.jl")
const resultados = joinpath(@__DIR__, "resultados")
const entrega = Module(:Entrega)

σ(z) = 1 / (1 + exp(-z))

# La referencia, independiente de la entrega: Newton con el gradiente y la hessiana analíticos.
function newton_referencia(X, y)
    β = zeros(size(X, 2))
    for _ in 1:100
        p = σ.(X * β)
        g = X' * (y .- p)
        norm(g) < 1e-10 && break
        β += (X' * (X .* (p .* (1 .- p)))) \ g
    end
    return β
end

# El dado de Brandeis de Jaynes, resuelto por bisección sobre λ en pₖ ∝ exp(λ k).
function entropia_referencia(valores, μ)
    media(λ) = (w = exp.(λ .* valores); sum(w .* valores) / sum(w))
    a, b = -50.0, 50.0
    for _ in 1:200
        m = (a + b) / 2
        media(m) < μ ? (a = m) : (b = m)
    end
    w = exp.(((a + b) / 2) .* valores)
    return w ./ sum(w)
end

@testset "Semana 7" begin
    rm(resultados; force = true, recursive = true)

    @testset "se ejecuta sin excepciones ni advertencias" begin
        @test_logs min_level = Logging.Warn Base.include(entrega, script)
    end

    @testset "deja la figura en resultados/" begin
        @test isdir(resultados) && any(endswith(".png"), readdir(resultados))
    end

    (; X, y) = entrega
    β = randn(Xoshiro(1), size(X, 2)) .* [0.5, 0.05, 0.5]

    @testset "test_gradiente" begin
        ℓ(b) = entrega.logverosimilitud(b, X, y)
        h = 1e-6
        numerico = [(ℓ(β + h * e) - ℓ(β - h * e)) / 2h for e in eachcol(Matrix(1.0I, length(β), length(β)))]
        @test entrega.gradiente(β, X, y) ≈ numerico rtol = 1e-5
        @test entrega.gradiente(β, X, y) ≈ X' * (y .- σ.(X * β))
    end

    @testset "test_hessiana" begin
        H = entrega.hessiana(β, X, y)
        @test H ≈ -X' * (X .* (σ.(X * β) .* (1 .- σ.(X * β))))
        @test issymmetric(round.(H; sigdigits = 12)) && all(<(0), eigvals(Symmetric(H)))
    end

    @testset "test_newton" begin
        β̂, normas = entrega.newton_logistica(X, y)
        @test norm(entrega.gradiente(β̂, X, y)) < 1e-8
        @test length(normas) <= 10                       # convergencia cuadrática: pocas iteraciones
        @test β̂ ≈ newton_referencia(X, y) rtol = 1e-8
    end

    @testset "test_max_entropia" begin
        p = entrega.max_entropia(1:6, 4.5)
        @test sum(p) ≈ 1 && sum(p .* (1:6)) ≈ 4.5
        @test p ≈ entropia_referencia(1:6, 4.5) atol = 1e-8
        q = entrega.max_entropia(1:10, 3.0)              # otro problema: no vale un vector fijo
        @test sum(q) ≈ 1 && sum(q .* (1:10)) ≈ 3.0
        @test q ≈ entropia_referencia(1:10, 3.0) atol = 1e-8
    end
end
