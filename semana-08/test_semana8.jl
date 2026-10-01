# Corrige la entrega de la semana 8, laboratorio_semana8.jl en esta carpeta:
#   julia --project=semana-08 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-08 --depwarn=yes semana-08/test_semana8.jl
using Test, Logging, Random

const script = joinpath(@__DIR__, "laboratorio_semana8.jl")
const resultados = joinpath(@__DIR__, "resultados")
const entrega = Module(:Entrega)

@testset "Semana 8" begin
    rm(resultados; force = true, recursive = true)

    @testset "se ejecuta sin excepciones ni advertencias" begin
        @test_logs min_level = Logging.Warn Base.include(entrega, script)
    end

    @testset "deja la figura en resultados/" begin
        @test isdir(resultados) && any(endswith(".png"), readdir(resultados))
    end

    @testset "test_tabla_hash" begin
        (; TablaHash, insertar!, buscar) = entrega
        claves = unique(rand(Xoshiro(1), Int, 10_000))
        t = TablaHash{Int, Int}(2^14)
        for k in claves
            insertar!(t, k, 2k)
        end
        resultados_busqueda = [buscar(t, k) for k in claves]
        @test all(r[1] == 2k for (r, k) in zip(resultados_busqueda, claves))
        @test sum(last, resultados_busqueda) <= 2 * length(claves)   # carga 0.6: poco más de una comparación
        @test all(buscar(t, k)[1] === nothing for k in rand(Xoshiro(2), Int, 10))
        insertar!(t, claves[1], 0)                                   # una clave repetida sustituye su valor
        @test buscar(t, claves[1])[1] == 0
        @test sum(length, t.cubetas) == length(claves)
    end

    @testset "test_uniones" begin
        (; hombres, mujeres, unir_anidado, unir_hash, unir_ordenado) = entrega
        a, b = hombres[1:2000], mujeres[1:2000]
        anidado, c_anidado = unir_anidado(a, b)
        @test c_anidado == length(a) * length(b)
        @test Set(first(unir_hash(a, b))) == Set(anidado)
        @test Set(first(unir_ordenado(a, b))) == Set(anidado)
        pares_hash, c_hash = unir_hash(hombres, mujeres)
        pares_orden, c_orden = unir_ordenado(hombres, mujeres)
        @test Set(pares_hash) == Set(pares_orden) && length(pares_hash) == 8116
        @test c_hash <= 2 * length(mujeres)                          # unas pocas por búsqueda, no n
        @test c_orden <= length(hombres) + length(mujeres)
    end

    @testset "test_invertir" begin
        (; Nodo, invertir) = entrega
        lista = nothing
        for k in 1:200_000                                           # demasiado larga para la recursión
            lista = Nodo(k, lista)
        end
        r = invertir(lista)
        valores = Int[]
        while r !== nothing
            push!(valores, r.valor)
            r = r.siguiente
        end
        @test valores == 1:200_000
    end

    @testset "test_colisiones" begin
        (; TablaHash, insertar!, pares_en_colision) = entrega
        t = TablaHash{Int, Int}(2^14)
        for k in rand(Xoshiro(3), Int, 5000)
            insertar!(t, k, 0)
        end
        @test pares_en_colision(t) == sum(length(c) * (length(c) - 1) ÷ 2 for c in t.cubetas)
        n, m = sum(length, t.cubetas), length(t.cubetas)
        @test isapprox(pares_en_colision(t), n * (n - 1) / 2m; rtol = 0.2)   # el problema del cumpleaños
    end
end
