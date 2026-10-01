# Corrige la entrega de la semana 5, laboratorio_semana5.jl en esta carpeta:
#   julia --project=semana-05 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-05 --depwarn=yes semana-05/test_semana5.jl
using Test, Logging

const script = joinpath(@__DIR__, "laboratorio_semana5.jl")
const resultados = joinpath(@__DIR__, "resultados")
const entrega = Module(:Entrega)

# El ancho en píxeles de un PNG, que va en los bytes 17-20 de su cabecera.
ancho_png(archivo) = ntoh(reinterpret(UInt32, read(archivo, 20)[17:20])[1])

@testset "Semana 5" begin
    rm(resultados; force = true, recursive = true)

    @testset "se ejecuta sin excepciones ni advertencias" begin
        @test_logs min_level = Logging.Warn Base.include(entrega, script)
    end

    @testset "deja el panel en alta resolución en resultados/" begin
        pngs = isdir(resultados) ? filter(endswith(".png"), readdir(resultados; join = true)) : String[]
        @test !isempty(pngs)
        @test all(>=(2000) ∘ ancho_png, pngs)
    end

    @testset "test_pico_inflexion" begin
        (; N, dNdt, K) = entrega
        @test 0.499K <= N[argmax(dNdt)] <= 0.501K
    end

    @testset "resuelve el SIR con paso adaptativo" begin
        (; sir) = entrega
        @test sir.retcode == entrega.ReturnCode.Success
        @test length(unique(diff(sir.t))) > 1             # el paso cambia: no es Euler
        @test sum(sir.u[end]) ≈ sum(sir.u[1]) rtol = 1e-6  # S + I + R se conserva
    end
end
