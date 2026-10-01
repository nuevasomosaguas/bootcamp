# Corrige el proyecto de replicación de la semana 12: comunidad.txt, limpiar.sh, proyecto.jl e
# informe.typ en esta carpeta, para la comunidad autónoma asignada:
#   julia --project=semana-12 -e 'using Pkg; Pkg.instantiate()'
#   julia --project=semana-12 --depwarn=yes semana-12/test_semana12.jl
using Test, Logging, LinearAlgebra, SHA, TOML

const proyecto = joinpath(@__DIR__, "proyecto.jl")
const informe = joinpath(@__DIR__, "informe.typ")
const resultados = joinpath(@__DIR__, "resultados")
const datos = joinpath(@__DIR__, "datos")
const zip_defunciones = joinpath(@__DIR__, "..", "semana-09", "datos", "datos_2024.zip")
const sha256_defunciones = "33682a2f2965f72863ff1a899fe98e747f828862eed17146aea0f8e6ced3d3c1"
const cierre = Module(:Cierre)

git(args...) = Cmd(`git $args`; dir = dirname(@__DIR__))
numero(s) = s == "\"\"" ? 0.0 : parse(Float64, replace(s, "." => "", "," => "."))
lineas(archivo) = [split(l, ';') for l in Iterators.drop(eachline(joinpath(datos, archivo)), 1)]
# Los paquetes permitidos: la biblioteca estándar y las figuras, ninguna caja negra
const permitidos = Set(["LinearAlgebra", "TOML", "Downloads", "SHA", "Random", "Statistics", "Printf",
                        "CairoMakie", "Somosaguas"])
function paquetes(archivo)
    nombres = String[]
    for l in eachline(archivo)
        m = match(r"^\s*(?:using|import)\s+([^:]+)", l)
        m === nothing || append!(nombres, strip.(split(m[1], ',')))
    end
    return nombres
end

# La referencia, independiente de la entrega: la tabla de vida de Lexis, Euler-Lotka y la
# migración residual de la comunidad, leídas aquí de los microdatos y de los archivos del INE
function referencia(c)
    w = c in ("18", "19") ? 90 : 95
    provincias = Set(p for (p, cc) in lineas("provincias.csv") if cc == c)
    registros = NamedTuple[]
    for l in Iterators.drop(eachline(`unzip -p $zip_defunciones CSV/MNPdefun_2024.tab`), 1)
        f = split(l, '\t')
        f[14] == "1" && f[15] in provincias || continue
        push!(registros, (sexo = f[5] == "6" ? "Mujeres" : "Hombres", g = parse(Int, f[4]), mn = parse(Int, f[3]),
                          md = parse(Int, f[6]), x = parse(Int, f[20])))
    end
    pob = lineas("poblacion_ccaa.csv")
    function P(sexo, año)
        p = zeros(w + 1)
        for (edad, cc, s, fecha, valor) in pob
            startswith(cc, c * " ") && s == sexo && fecha == "1 de enero de $año" || continue
            x = edad == "100 y más años" ? 100 : (m = match(r"^(\d+) años?$", edad)) === nothing ? -1 : parse(Int, m[1])
            x >= 0 && (p[min(x, w) + 1] += numero(valor))
        end
        return p
    end
    function tabla(sexo)
        rs = sexo == "Total" ? registros : filter(r -> r.sexo == sexo, registros)
        D, E, A = zeros(w + 1), (P(sexo, 2024) .+ P(sexo, 2025)) ./ 2, zeros(w + 1)
        for r in rs
            i = min(r.x, w) + 1; D[i] += 1
            cumplidos = r.g == 2024 - r.x
            a_i = cumplidos ? (r.md > r.mn ? (r.md - r.mn) / 12 : 1 / 36) : (r.mn > r.md ? 1 - (r.mn - r.md) / 12 : 1 - 1 / 36)
            A[i] += a_i + max(r.x - w, 0)
            E[i] += cumplidos && r.x <= w ? a_i : (r.md - 0.5) / 12 - 0.5    # triángulo inferior o superior
        end
        mx, ax = D ./ E, [d > 0 ? s / d : 0.5 for (s, d) in zip(A, D)]
        q = mx ./ (1 .+ (1 .- ax) .* mx); q[end] = 1
        l = [1; cumprod(1 .- q[1:end-1])]
        L = l .- l .* q .* (1 .- ax)
        return (; l, L, e0 = sum(L))
    end
    edad_madre(s) = s == "Menos de 15 años" ? 15 : s == "50 y más años" ? 49 : parse(Int, first(split(s)))
    nac = lineas("nacimientos_ccaa.csv")
    B(sexo) = (nb = zeros(w + 1); for (cc, s, edad, _, v) in nac
        startswith(cc, c * " ") && s == sexo && edad != "Todas las edades" && (nb[edad_madre(edad) + 1] += numero(v))
    end; nb)
    f = B("Total") ./ ((P("Mujeres", 2024) .+ P("Mujeres", 2025)) ./ 2)
    φ = tabla("Mujeres").L .* f .* (sum(B("Mujeres")) / sum(B("Total")))
    bajo, alto = -1.0, 1.0
    for _ in 1:200
        medio = (bajo + alto) / 2
        sum(exp.(-medio .* ((0:w) .+ 0.5)) .* φ) > 1 ? (bajo = medio) : (alto = medio)
    end
    muertas = Dict{Int, Int}()
    for r in registros
        r.sexo == "Mujeres" && (muertas[r.g] = get(muertas, r.g, 0) + 1)
    end
    P0, P1 = P("Mujeres", 2024), P("Mujeres", 2025)
    migracion = P1[1] - sum(B("Mujeres")) + get(muertas, 2024, 0) +
                sum(P1[x + 2] - P0[x + 1] + get(muertas, 2023 - x, 0) for x in 0:w-2) +
                P1[w + 1] - P0[w] - P0[w + 1] + sum(n for (g, n) in muertas if g <= 2024 - w)
    return (; registros, e0 = Dict(s => tabla(s).e0 for s in ("Total", "Hombres", "Mujeres")),
              isf = sum(f), R0 = sum(φ), r = (bajo + alto) / 2, migracion)
end

e0_ine(c, sexo) = numero(only(f[6] for f in lineas("tablas_mortalidad_ccaa.csv")
                              if startswith(f[1], c * " ") && f[2] == sexo && f[3] == "0 años" && f[4] == "Esperanza de vida"))

@testset "Semana 12" begin
    rm(resultados; force = true, recursive = true)
    c = strip(read(joinpath(@__DIR__, "comunidad.txt"), String))

    @testset "la comunidad y los microdatos" begin
        @test c in [lpad(i, 2, '0') for i in 1:19]
        rm(joinpath(datos, "defunciones.csv"); force = true)
        @test success(Cmd(`sh limpiar.sh $c`; dir = @__DIR__))     # descarga el zip si no está
        @test bytes2hex(open(sha256, zip_defunciones)) == sha256_defunciones
    end

    ref = referencia(c)

    @testset "limpiar.sh deja las defunciones de residentes de la comunidad" begin
        lineas_csv = readlines(joinpath(datos, "defunciones.csv"))
        @test lineas_csv[1] == "sexo,anio_nac,mes_nac,mes_def,edad"
        @test lineas_csv[2:end] == ["$(r.sexo == "Mujeres" ? "M" : "H"),$(r.g),$(r.mn),$(r.md),$(r.x)" for r in ref.registros]
    end

    @testset "proyecto.jl, sin cajas negras" begin
        @test all(in(permitidos), paquetes(proyecto))
        @test_logs min_level = Logging.Warn Base.include(cierre, proyecto)
        @test any(endswith(".png"), readdir(resultados))
    end

    p = TOML.parsefile(joinpath(resultados, "proyecto.toml"))

    @testset "la tabla de vida replica la del INE" begin
        tolerancia = c in ("18", "19") ? 0.02 : 0.01         # Ceuta y Melilla, con muy pocas defunciones
        for (k, s, sine) in (("ambos", "Total", "Ambos sexos"), ("hombres", "Hombres", "Hombres"), ("mujeres", "Mujeres", "Mujeres"))
            @test p["e0"][k] ≈ e0_ine(c, sine) atol = tolerancia
            @test p["e0"][k] ≈ ref.e0[s] atol = 1e-3
        end
    end

    @testset "la fecundidad, R₀ y la tasa intrínseca" begin
        @test p["isf"] ≈ ref.isf rtol = 1e-8
        @test p["R0"] ≈ ref.R0 rtol = 1e-4
        @test p["r"] ≈ ref.r atol = 1e-5
        @test log(p["lambda"]) ≈ p["r"] atol = 1e-5         # la ecuación característica de Leslie
        @test p["amortiguamiento"] > 1
    end

    @testset "la proyección y la migración" begin
        @test p["migracion_neta"] ≈ ref.migracion atol = 0.5
        for k in ("mujeres_2025", "cerrada_2055", "migracion_2055")
            @test length(p[k]) == 3
        end
        @test sum(p["cerrada_2055"]) < sum(p["mujeres_2025"])  # con λ < 1, la población cerrada mengua
        @test sum(p["estable"]) ≈ 1
    end

    @testset "el informe, en dos páginas como mucho" begin
        @test occursin("toml(", read(informe, String))
        @test success(Cmd(`typst compile informe.typ 'resultados/informe-{p}.png'`; dir = @__DIR__))
        @test 1 <= count(startswith("informe-"), readdir(resultados)) <= 2
    end

    @testset "los microdatos no entran en Git" begin
        @test success(git("check-ignore", "-q", "semana-12/datos/defunciones.csv"))
        @test isempty(readchomp(git("ls-files", "semana-12/datos/defunciones.csv")))
    end
end
