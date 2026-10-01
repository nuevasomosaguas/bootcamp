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
        panel = joinpath(resultados, "difusion_logistica.png")
        @test isfile(panel) && ancho_png(panel) >= 2000
    end

    @testset "test_pico_inflexion" begin
        (; N, t, r, K, N0, dt, t_inflexion) = entrega
        # N es la trayectoria de Euler, paso a paso, desde N0 en t = 0
        euler = accumulate((n, _) -> n + r * n * (1 - n / K) * dt, 2:length(t); init = N0)
        @test first(t) == 0 && t[2] - t[1] ≈ dt
        @test N ≈ [N0; euler]
        # Euler llega a la inflexión con 1-2 pasos de retraso: la tolerancia, en pasos
        @test abs(t_inflexion - log((K - N0) / N0) / r) <= 3dt
    end

    @testset "resuelve el SIR con paso adaptativo" begin
        (; sir) = entrega
        @test sir.retcode == entrega.ReturnCode.Success
        @test length(unique(diff(sir.t))) > 1             # el paso cambia: no es Euler
        @test sum(sir.u[end]) ≈ sum(sir.u[1]) rtol = 1e-6  # S + I + R se conserva
    end
end
