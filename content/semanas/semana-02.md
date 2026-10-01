---
title: "Semana 2: Los cuatro subespacios, Gram-Schmidt y la consola POSIX"
date: 2027-07-05
weight: 2
---

**Módulo:** Cimientos formales y programación  
**Lecturas imprescindibles:** Gilbert Strang, *Linear Algebra and Its Applications*, caps. 2 y 3 (los cuatro subespacios, ortogonalidad y Gram-Schmidt; las proyecciones y los mínimos cuadrados son de la semana 3); Brian W. Kernighan y Rob Pike, *The Practice of Programming*, cap. 1 (el estilo)  
**De ampliación:** Strang, cap. 4 (determinantes), del que esta semana basta lo que dice el punto 2 de la sección 1; Lloyd N. Trefethen y David Bau, *Numerical Linear Algebra*, lecciones 7-10, un texto de posgrado, cuyas lecciones 8 y 9 (Gram-Schmidt y su experimento numérico) son las más cercanas al ejercicio 2; Kernighan y Pike, caps. 2-3, que siguen en la semana 3  
**Herramientas:** Julia 1.11 o posterior, con `LinearAlgebra` (biblioteca estándar); `sh`, `sed` y `awk`; `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl` y de un script de consola `.sh`, sujetos a integración continua, y prueba de la pizarra (*Blackboard Defence*)


> [!nota] Lo que esta semana da por sabido
> - **De la [prueba de nivel](../../diagnostico/):** el bloque C (sistemas por Gauss y determinantes) y la semana 1. Quien cursó Ciencias Sociales no vio determinantes.
> - **Nuevo para todos:** los subespacios, la independencia lineal, la base, la dimensión, el rango y el espacio nulo; Gram-Schmidt y la factorización $QR$; el número de condición y el error de redondeo; la consola POSIX.
> - **Para repasar:** Strang, *18.06*, lecciones [9, independencia, base y dimensión](https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/resources/lecture-9-independence-basis-and-dimension/), [10, los cuatro subespacios](https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/resources/lecture-10-the-four-fundamental-subspaces/) y [17, Gram-Schmidt](https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/resources/lecture-17-orthogonal-matrices-and-gram-schmidt/); 3Blue1Brown, [combinaciones lineales](https://www.3blue1brown.com/lessons/span) y [transformaciones lineales](https://www.3blue1brown.com/lessons/linear-transformations); las dos primeras lecciones de [*The Missing Semester*](https://missing.csail.mit.edu/2026/).

## 1. Marco conceptual: la geometría de una matriz

En la semana 1, una matriz era una tabla de vectores: votantes o partidos. Esta semana es un operador, $A \in \mathbb{R}^{m \times n}$, que lleva $\mathbb{R}^n$ a $\mathbb{R}^m$, y su geometría entera se lee en cuatro subespacios.

1. **Los cuatro subespacios fundamentales.** Sea $r$ el rango de $A$:

   | Subespacio | Vive en | Dimensión |
   | :--- | :--- | :--- |
   | Espacio columna, $\mathcal{C}(A)$ | $\mathbb{R}^m$ | $r$ |
   | Espacio nulo, $\mathcal{N}(A)$ | $\mathbb{R}^n$ | $n - r$ |
   | Espacio fila, $\mathcal{C}(A^T)$ | $\mathbb{R}^n$ | $r$ |
   | Espacio nulo izquierdo, $\mathcal{N}(A^T)$ | $\mathbb{R}^m$ | $m - r$ |

   El **teorema fundamental del álgebra lineal** dice que los subespacios de cada lado son complementos ortogonales:

   $$
   \mathcal{C}(A^T)^\perp = \mathcal{N}(A), \qquad \mathcal{C}(A)^\perp = \mathcal{N}(A^T)
   $$

   La razón cabe en una línea: $A\mathbf{x} = \mathbf{0}$ dice que $\mathbf{x}$ es ortogonal a cada fila de $A$.

2. **El determinante.** Para $A$ cuadrada, $|\det A|$ es el volumen del paralelepípedo que generan sus columnas, y $\det A = 0$ si y solo si las columnas son linealmente dependientes, es decir, si $\mathcal{N}(A) \neq \{\mathbf{0}\}$ y $A$ no es invertible.

3. **Gram-Schmidt y la factorización $QR$.** Si $A$ tiene **rango completo por columnas** ($r = n$), Gram-Schmidt construye una base ortonormal de $\mathcal{C}(A)$: a cada columna $\mathbf{a}_j$ le resta sus proyecciones sobre las columnas $\mathbf{q}_1, \dots, \mathbf{q}_{j-1}$ ya construidas, y normaliza lo que queda. El resultado es

   $$
   A = QR, \qquad Q^T Q = I_n, \qquad R \text{ triangular superior con } r_{jj} > 0
   $$

   y $R$ es invertible precisamente porque $A$ tiene rango completo; si no lo tiene, algún $r_{jj}$ es cero y la normalización divide por cero. Como $|\det Q| = 1$, el determinante de una $A$ cuadrada sale de la diagonal de $R$: $|\det A| = \prod_j r_{jj}$.

4. **Clásico frente a modificado.** Gram-Schmidt **clásico** (CGS) calcula $r_{ij} = \mathbf{q}_i^T \mathbf{a}_j$ con la columna original; el **modificado** (MGS), $r_{ij} = \mathbf{q}_i^T \mathbf{v}$ con lo que queda de ella tras restar las proyecciones anteriores. En aritmética exacta dan lo mismo. En punto flotante no: la pérdida de ortogonalidad, $\|Q^T Q - I\|$, crece como $\varepsilon\,\kappa(A)^2$ en el clásico y como $\varepsilon\,\kappa(A)$ en el modificado, donde $\varepsilon \approx 2 \cdot 10^{-16}$. MGS **reduce** la pérdida, no la evita; las reflexiones de Householder, que usa la `qr` de Julia, la mantienen en $\varepsilon$ para cualquier $\kappa(A)$. Las dos cotas valen solo mientras son menores que 1: cuando $\varepsilon\,\kappa(A)^2$ llega a 1, hacia $\kappa \approx 10^8$, CGS ya ha perdido la ortogonalidad por completo y $\|Q^T Q - I\|$ se estanca en el orden de la unidad.

5. **La memoria por columnas.** Julia guarda las matrices por columnas (*column-major*): `A[i, j]` y `A[i + 1, j]` son vecinos en memoria, y `A[i, j]` y `A[i, j + 1]` están a $m$ posiciones. El procesador lee la memoria en líneas de caché, de 64 bytes (ocho `Float64`) en la mayoría de los procesadores x86 y de 128 en los Mac con procesador Apple: recorrer una matriz por columnas aprovecha cada línea entera, y recorrerla por filas trae una línea por elemento. El *prefetcher* del procesador, que adelanta las lecturas que prevé, suaviza la diferencia, y cuánto depende de la máquina. Gram-Schmidt trabaja con columnas enteras y por eso las recorre en memoria contigua.

## 2. La consola POSIX

POSIX es el estándar que comparten las consolas de Unix: un script que solo usa lo que fija el estándar funciona igual en `sh`, `dash`, `bash` o `zsh`. La integración continua lo ejecuta con `sh`, que en Ubuntu es `dash`, una consola POSIX estricta.

| Escritura | Qué hace |
| :--- | :--- |
| `orden > archivo` | La salida estándar (descriptor 1) a `archivo`, que se vacía antes |
| `orden >> archivo` | La salida estándar, añadida al final de `archivo` |
| `orden 2> errores` | Los errores (descriptor 2) a `errores` |
| `orden > archivo 2>&1` | Las dos salidas al mismo archivo: primero se redirige la 1, luego la 2 a donde apunte la 1 |
| `orden1 \| orden2` | La salida de `orden1` es la entrada de `orden2` |

`orden &> archivo` no es POSIX: es una extensión de `bash`. En `dash` se lee como `orden &` (ejecutar en segundo plano) seguido de `> archivo` (vaciar el archivo), y no redirige nada. La redirección la interpreta la consola en la que se escribe la orden, no la que ejecuta el script: `sh flujo.sh &> todo.txt`, escrito en `bash` o `zsh`, funciona, aunque el script lo ejecute `dash`.

Tres herramientas bastan para transformar texto por columnas sin abrir un editor:

- **`sed`** edita línea a línea: `sed 1d` borra la primera (la cabecera), `sed 's/,/ /g'` cambia cada coma por un espacio.
- **`awk`** procesa por campos: `awk -F, '$3 > 1e-6 { print $1 }'` imprime el primer campo de las filas cuyo tercero supera $10^{-6}$; `awk -F, '{ s += $2 } END { print s / NR }'` acumula y promedia.
- **`xargs`** convierte líneas en argumentos: `ls resultados/*.png | xargs du -h` pasa cada figura a `du`.

## 3. Código base de referencia (`laboratorio_semana2.jl`)

El script programa Gram-Schmidt clásico, mide su pérdida de ortogonalidad en matrices de Hilbert cada vez peor condicionadas, la compara con la de Householder y deja la tabla en `resultados/ortogonalidad.csv` y la figura en `resultados/ortogonalidad.png`.

```julia
using LinearAlgebra, CairoMakie, Somosaguas

# 1. Gram-Schmidt clásico: A = QR, con Q de columnas ortonormales y R triangular superior.
#    Cada columna de A se proyecta sobre las columnas de Q ya construidas y se le resta
#    esa proyección; lo que queda, normalizado, es la nueva columna de Q.
function cgs(A)
    m, n = size(A)
    Q, R = zeros(m, n), zeros(n, n)
    for j in 1:n
        v = A[:, j]
        for i in 1:j-1
            R[i, j] = dot(view(Q, :, i), view(A, :, j))   # contra la columna original
            v .-= R[i, j] .* view(Q, :, i)
        end
        R[j, j] = norm(v)   # cero si A no tiene rango completo por columnas
        Q[:, j] = v ./ R[j, j]
    end
    return Q, R
end

# 2. La pérdida de ortogonalidad, ‖QᵀQ − I‖, frente al número de condición de A,
#    en matrices de Hilbert de 2n × n, cada vez peor condicionadas
hilbert(m, n) = [1 / (i + j - 1) for i in 1:m, j in 1:n]
perdida(Q) = opnorm(Q' * Q - I)
ns = 2:12
κ = [cond(hilbert(2n, n)) for n in ns]
e_cgs = [perdida(cgs(hilbert(2n, n))[1]) for n in ns]
e_householder = [perdida(Matrix(qr(hilbert(2n, n)).Q)) for n in ns]   # la qr de Julia

# 3. La tabla, en texto plano, para la consola
resultados = mkpath(joinpath(@__DIR__, "resultados"))
open(joinpath(resultados, "ortogonalidad.csv"), "w") do io
    println(io, "n,kappa,cgs,householder")
    for fila in zip(ns, κ, e_cgs, e_householder)
        println(io, join(fila, ","))
    end
end

# 4. La figura: pérdida de ortogonalidad frente a κ(A), en escala logarítmica
set_theme!(tema_somosaguas())
fig = Figure(size = (900, 550))
ax = Axis(fig[1, 1]; xscale = log10, yscale = log10,
    title = "Gram-Schmidt clásico pierde la ortogonalidad",
    xlabel = "Número de condición, κ(A)", ylabel = "‖QᵀQ − I‖",
    xticks = (10.0 .^ (0:3:15), [rich("10", superscript(string(k))) for k in 0:3:15]))
for (nombre, e, alineacion) in [("Gram-Schmidt clásico", e_cgs, (:right, :top)),
                                ("Householder (qr)", e_householder, (:right, :bottom))]
    scatterlines!(ax, κ, max.(e, eps()))   # el suelo, eps(), para que el logaritmo exista
    text!(ax, κ[end], max(e[end], eps()); text = nombre, align = alineacion,
        offset = (0, alineacion[2] == :top ? -10 : 6))
end
save(joinpath(resultados, "ortogonalidad.png"), fig; px_per_unit = 1.5)
```

## 4. Ejercicios

### Ejercicio 1: el censo de conductores de la DGT, casi sin rango completo

`semana-02/datos/censo_conductores_municipal202512.txt` es el [censo de conductores de la DGT](https://www.dgt.es/menusecundario/dgt-en-cifras/dgt-en-cifras-resultados/dgt-en-cifras-detalle/Microdatos-de-censo-de-conductores-segun-provincia-municipio-y-sexo-mensual/) a 31 de diciembre de 2025, tal como lo publica la Dirección General de Tráfico: una fila por municipio de residencia y sexo, con los campos separados por `|` y tres recuentos, los conductores con algún permiso en vigor (`NUM_PERMISO`), con alguna licencia (`NUM_LICENCIA`) y con algún permiso o licencia (`NUM_LICENCIA_PERMISO`). El archivo tiene finales de línea de Windows, `\r\n`.

- **En la consola:** cuenta las filas que da `awk -F'|' '$6 == "919"'` sobre el archivo tal cual y después de `sed 's/\r$//'`, y explica la diferencia. Con `sed` y un acumulador de `awk`, escribe el total de conductores por provincia.
- **En Julia:** forma $A \in \mathbb{R}^{16\,286 \times 3}$ con los tres recuentos y calcula su rango, sus valores singulares (`svdvals`) y $\kappa(A)$. Calcula $A\mathbf{v}$ para $\mathbf{v} = (1, 1, -1)$: ¿qué cuenta cada elemento? Si nadie tuviera a la vez permiso y licencia, ¿cuál sería $\mathcal{N}(A)$, y cuáles las dimensiones de los cuatro subespacios?
- **Pregunta causal:** $A$ tiene rango 3, pero $\kappa(A) \approx 10^5$ y $\|A\mathbf{v}\| / \|A\| \approx 5 \cdot 10^{-5}$. ¿Qué dice ese vector casi nulo de los datos, y qué dice el segundo valor singular, también pequeño? ¿Por qué el determinante de $A^TA$, sin escala, no sirve para decidir si una matriz es «casi singular»?

### Ejercicio 2: Gram-Schmidt modificado

- **Tarea:** escribe `mgs(A)`, que devuelve `Q, R` como `cgs` pero calcula cada $r_{ij}$ contra lo que queda de la columna, no contra la original. Añade su pérdida de ortogonalidad a la figura, y a la tabla como quinta columna, `mgs`, después de las que hay.
- **Pregunta causal:** en la escala logarítmica de la figura, la pendiente de CGS es 2 hasta que se satura, la de MGS es 1 y la de Householder es 0. Explica las tres pendientes. ¿Por qué el cambio de una sola variable en el bucle cambia el exponente de $\kappa(A)$? ¿Por qué se aplana la curva de CGS a partir de $\kappa \approx 10^8$, y a partir de qué $\kappa$ se aplanaría la de MGS?

### Ejercicio 3: la memoria por columnas

- **Tarea:** escribe dos funciones que sumen los elementos de una matriz de $5000 \times 5000$ con dos bucles anidados, una con el índice de fila en el bucle interior y otra con el de columna. Mide las dos con `@elapsed`, después de ejecutar cada una una vez para que Julia la compile.
- **Pregunta causal:** ¿cuántas veces más lenta es la suma por filas? Explícalo con las líneas de caché de tu procesador (`getconf LEVEL1_DCACHE_LINESIZE` en Linux, `sysctl hw.cachelinesize` en macOS) y compara tu cociente con el de tus compañeros. ¿Qué orden de bucles usa `cgs`?

### Ejercicio 4: la tabla en la consola

- **Tarea:** escribe `flujo.sh`, un script POSIX que lea `resultados/ortogonalidad.csv` y escriba en la salida estándar, una por línea, las $n$ en que Gram-Schmidt clásico pierde la ortogonalidad, $\|Q^TQ - I\| > 10^{-6}$. Usa `sed` para quitar la cabecera y `awk` para filtrar.
- **En la terminal:** guarda la lista en `perdidas.txt` y los errores en `errores.log` con una sola orden; añade después la media de $\log_{10} \kappa$ al final de `perdidas.txt` con un acumulador de `awk`, que no tiene `log10`: $\log_{10} x$ es `log(x) / log(10)`. Ejecuta `sh flujo.sh &> todo.txt` dentro de `dash`, con `dash -c 'sh flujo.sh &> todo.txt'`, y explica qué ha pasado; ejecútalo después en tu consola habitual y explica por qué ahí funciona.

## 5. Criterio de verificación por integración continua

La entrega son `semana-02/laboratorio_semana2.jl` y `semana-02/flujo.sh` en el repositorio de la asignatura. Con cada push, la integración continua ejecuta `semana-02/test_semana2.jl`, y el laboratorio se supera si:

1. El script de Julia se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior y deja la figura y la tabla en `semana-02/resultados/`.
2. Supera el test unitario `test_mgs`: `mgs` factoriza una matriz aleatoria con $QR = A$, $\|Q^TQ - I\| < 10^{-12}$ y $R$ triangular superior de diagonal positiva, y en una matriz de Hilbert de $12 \times 8$ ($\kappa \approx 6 \cdot 10^8$) pierde la ortogonalidad como Gram-Schmidt modificado: más que Householder y mucho menos que el clásico.
3. Supera el test unitario `test_flujo_posix`: `sh flujo.sh`, ejecutado en `dash`, escribe exactamente las $n$ de la tabla con pérdida mayor que $10^{-6}$.

Antes de enviarlo, el mismo test se pasa en la terminal:

```sh
julia --project=semana-02 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-02 --depwarn=yes semana-02/test_semana2.jl
```
