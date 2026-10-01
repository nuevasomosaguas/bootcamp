# Corrige la entrega de la semana 4: laboratorio_semana4.jl y el proyecto de cierre de la
# fase I, limpiar.sh y proyecto.jl, en esta carpeta, con el historial de Git:
#   julia --project=semana-04 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-04 --depwarn=yes semana-04/test_semana4.jl
using Test, Logging, LinearAlgebra, SHA

const script = joinpath(@__DIR__, "laboratorio_semana4.jl")
const proyecto = joinpath(@__DIR__, "proyecto.jl")
const resultados = joinpath(@__DIR__, "resultados")
const zip_ees = joinpath(@__DIR__, "datos", "datos_2022.zip")
const csv_ees = joinpath(@__DIR__, "datos", "ees2022.csv")
# La versión de la EES 2022 con la que se escribió la semana: si el INE revisa el archivo,
# el recuento deja de cuadrar, y esta suma lo dice antes.
const sha256_ees = "c52b716c156dbbe1a64026140cf8e303db4bde414437f4d1737f56fcaf609e10"
const entrega = Module(:Entrega)
const cierre = Module(:Cierre)

sin_regresion(archivo) = !occursin(r"\b(GLM|FixedEffectModels|MLJ\w*|lm)\b", read(archivo, String))
git(args...) = Cmd(`git $args`; dir = dirname(@__DIR__))
perdida(Q) = opnorm(Q' * Q - I)
hilbert(m, n) = [1 / (i + j - 1) for i in 1:m, j in 1:n]

# Lo que limpiar.sh debe dejar, leído aquí del ancho fijo según el diseño de registro
# (dr_EES_2022.json): TIPOJOR (28) = 1, DRELABAM (126-127) = 12 y salario bruto anual,
# RETRINOIN (146-155) + RETRIIN (156-165), positivo.
function filas_esperadas()
    filas = Tuple{Int, Int, Int, Float64}[]
    for r in eachline(`unzip -p $zip_ees md_EES_2022.txt`)
        r[28] == '1' && r[126:127] == "12" || continue
        salario = parse(Float64, strip(r[146:155])) + parse(Float64, strip(r[156:165]))
        salario > 0 || continue
        push!(filas, (r[18] == '6', parse(Int, r[23:23]), parse(Int, strip(r[24:25])), salario))
    end
    return filas
end

@testset "Semana 4" begin
    rm(resultados; force = true, recursive = true)

    @testset "estima sin paquetes de regresión" begin
        @test sin_regresion(script)
        @test sin_regresion(proyecto)
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
        # Relativo a lo que el redondeo permite: X \ y queda en 1-8, la ecuación normal en
        # 9-17 e inv(X' * X), por encima de 50.
        @test norm(X' * residuos, Inf) < 30 * eps() * opnorm(X) * norm(residuos)
    end

    @testset "test_descomposicion_varianza" begin
        (; ss_tot, ss_reg, ss_res) = entrega
        @test ss_reg + ss_res ≈ ss_tot rtol = 1e-12
    end

    @testset "proyecto: limpiar.sh deja la muestra de la EES" begin
        rm(csv_ees; force = true)
        @test success(Cmd(`sh limpiar.sh`; dir = @__DIR__))
        @test bytes2hex(open(sha256, zip_ees)) == sha256_ees
        lineas = readlines(csv_ees)
        @test lineas[1] == "mujer,estudios,antiguedad,salario"
        esperadas = filas_esperadas()
        leidas = [(parse(Int, a), parse(Int, b), parse(Int, c), parse(Float64, d))
                  for (a, b, c, d) in split.(lineas[2:end], ",")]
        @test length(leidas) == length(esperadas)
        @test first.(leidas, 3) == first.(esperadas, 3)
        @test all(abs(l[4] - e[4]) < 0.005 for (l, e) in zip(leidas, esperadas))   # al céntimo
    end

    @testset "proyecto: la ecuación de salarios con Gram-Schmidt modificado" begin
        @test_logs min_level = Logging.Warn Base.include(cierre, proyecto)
        (; X_ees, y_ees, β_ees) = cierre
        filas = filas_esperadas()
        a = Float64[f[3] for f in filas]
        X = [ones(length(filas)) [f[1] for f in filas] a a .^ 2 [[f[2] == k for f in filas] for k in 2:7]...]
        @test X_ees == X
        @test y_ees ≈ log.([f[4] for f in filas])
        @test β_ees ≈ X \ y_ees rtol = 1e-8
        @test cierre.minimos_cuadrados_mgs(X_ees, y_ees) ≈ β_ees
        @test 1e-12 < perdida(cierre.mgs(hilbert(12, 8))[1]) < 1e-6   # es Gram-Schmidt modificado
        @test count(endswith(".png"), readdir(resultados)) >= 2
    end

    @testset "proyecto: los datos no entran en Git" begin
        @test success(git("check-ignore", "-q", "semana-04/datos/datos_2022.zip"))
        @test success(git("check-ignore", "-q", "semana-04/datos/ees2022.csv"))
        @test isempty(readchomp(git("ls-files", "semana-04/datos")))
    end
end
