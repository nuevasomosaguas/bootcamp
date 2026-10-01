---
title: "Semana 8: Estructuras de datos y complejidad: listas, tablas hash y el coste de unir registros"
date: 2027-08-16
weight: 8
---

**Módulo:** Cimientos formales y programación  
**Texto de referencia:** Brian W. Kernighan y Rob Pike, *The Practice of Programming*, cap. 2 (algoritmos y estructuras de datos); Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest y Clifford Stein, *Introduction to Algorithms*, caps. 3, 10 y 11 (el coste, las estructuras elementales y las tablas hash); Joseph K. Blitzstein y Jessica Hwang, *Introduction to Probability*, cap. 1 (el problema del cumpleaños)  
**Herramientas:** Julia 1.11 o posterior, con `LinearAlgebra` y `Random` (biblioteca estándar); `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl`, sujeto a integración continua, y prueba de la pizarra (*Blackboard Defence*)

> [!nota] Lo que esta semana da por sabido
> - **De semanas anteriores:** la memoria por columnas de la semana 2, las reservas de memoria de la semana 3, la recta de mínimos cuadrados de la semana 4 y la probabilidad de la semana 6. De la [prueba de nivel](../../diagnostico/), el sumatorio del problema A2 y los logaritmos del bloque A.
> - **Nuevo para todos:** la notación $O$, las listas enlazadas, las tablas hash, las uniones de tablas y las variables indicadoras.
> - **Para repasar:** el capítulo 2 de Kernighan y Pike, y el capítulo 1 de Blitzstein y Hwang, en los [consejos](../../consejos/).

## 1. Marco conceptual: el coste de cruzar dos registros

Unir dos registros administrativos por una clave común —el padrón con el censo de conductores, la afiliación con la renta— es la operación más frecuente del trabajo con microdatos, y la forma de hacerla decide si tarda un segundo o un día. Esta semana medimos ese coste con los datos de la DGT de la semana 2: los conductores de cada municipio, en una tabla para los hombres y otra para las mujeres.

1. **El coste se cuenta, no se adivina.** Un algoritmo cuesta $O(f(n))$ si el número de operaciones que hace crece, como mucho, en proporción a $f(n)$. Si $T(n) = c\, n^k$, entonces $\log T = \log c + k \log n$: en una gráfica doble logarítmica, el coste es una recta cuya pendiente es el exponente, y se estima con los mínimos cuadrados de la semana 4.

2. **Vectores y listas enlazadas.** Un vector guarda sus elementos contiguos en memoria: el elemento $k$ está a una cuenta de distancia, $O(1)$, y recorrerlo aprovecha la memoria caché de la semana 2; insertar al principio obliga a mover todos los demás, $O(n)$. Una lista enlazada guarda cada elemento con un puntero al siguiente: insertar al principio cuesta $O(1)$, pero llegar al elemento $k$ exige recorrer los $k$ anteriores.

3. **Las tablas hash.** Una función hash convierte cada clave en un número; su resto módulo $m$ elige una de $m$ cubetas, y cada cubeta guarda la lista de las claves que caen en ella (encadenamiento). Con $n$ claves, la carga es $\alpha = n/m$, y si la función reparte bien, una búsqueda hace en promedio $O(1 + \alpha)$ comparaciones, sin importar cuántas claves haya.

4. **Tres maneras de unir.** Para unir una tabla de $n$ filas con otra de $m$ por su clave:

   | Método | Coste | Idea |
   | :--- | :--- | :--- |
   | Bucles anidados | $O(nm)$ | Cada fila de una contra cada fila de la otra |
   | Ordenar y fusionar | $O(n \log n + m \log m)$ | Ordenar las dos por la clave y recorrerlas a la vez, como una cremallera |
   | Tabla hash | $O(n + m)$ en promedio | Guardar una en una tabla hash y buscar en ella cada fila de la otra |

5. **Las colisiones y el problema del cumpleaños.** Dos claves distintas colisionan si caen en la misma cubeta. Con $n$ claves repartidas al azar en $m$ cubetas, sea $I_{ij}$ la variable indicadora de que las claves $i$ y $j$ colisionan, con $\mathbb{E}[I_{ij}] = P(I_{ij} = 1) = 1/m$. Por la linealidad de la esperanza, que no exige independencia,

   $$
   \mathbb{E}[\text{pares en colisión}] = \sum_{i < j} \mathbb{E}[I_{ij}] = \binom{n}{2} \frac{1}{m}
   $$

   y la probabilidad de que no colisione ningún par es $\prod_{i=1}^{n-1} (1 - i/m) \approx e^{-n^2/2m}$. Con $m = 365$ días y $n = 23$ personas, ya es más probable que dos cumplan años el mismo día que lo contrario.

## 2. Código base de referencia (`laboratorio_semana8.jl`)

El script lee el censo de conductores de la DGT de la semana 2 en dos tablas, une hombres y mujeres por municipio con bucles anidados, mide el tiempo de esa unión para tamaños crecientes y estima la pendiente del coste. Define también las dos estructuras de datos que los ejercicios completan: la tabla hash con encadenamiento y la lista enlazada.

```julia
using LinearAlgebra, Random, CairoMakie, Somosaguas

# 1. El censo de conductores de la DGT de la semana 2: una fila por municipio y sexo, con
#    finales de línea \r\n. Los hombres y las mujeres, en dos tablas de (municipio, conductores).
archivo = joinpath(@__DIR__, "..", "semana-02", "datos", "censo_conductores_municipal202512.txt")
campos = [split(rstrip(l, '\r'), '|') for l in readlines(archivo)[2:end]]
tabla(sexo) = [(String(c[2]), parse(Int, c[6])) for c in campos if c[3] == sexo]
hombres, mujeres = tabla("V"), tabla("M")

# 2. La unión por bucles anidados: cada fila de a contra cada fila de b, n·m comparaciones
function unir_anidado(a, b)
    pares = Tuple{String, Int, Int}[]
    comparaciones = 0
    for (clave_a, x) in a, (clave_b, z) in b
        comparaciones += 1
        clave_a == clave_b && push!(pares, (clave_a, x, z))
    end
    return pares, comparaciones
end

# 3. Una tabla hash con encadenamiento: m cubetas, cada una un vector de pares clave => valor
struct TablaHash{K, V}
    cubetas::Vector{Vector{Pair{K, V}}}
end
TablaHash{K, V}(m::Integer) where {K, V} = TablaHash{K, V}([Pair{K, V}[] for _ in 1:m])
cubeta(t::TablaHash, clave) = t.cubetas[mod(hash(clave), length(t.cubetas)) + 1]

# 4. Una lista enlazada: cada nodo guarda su valor y el nodo siguiente, o nothing al final
struct Nodo{T}
    valor::T
    siguiente::Union{Nodo{T}, Nothing}
end

# 5. El coste de los bucles anidados, medido: el tiempo frente al tamaño, en escala doble
#    logarítmica, donde la pendiente es el exponente de n
tamaños = [250, 500, 1000, 2000, 4000, 8000]
unir_anidado(hombres[1:10], mujeres[1:10])                  # la primera llamada compila
tiempos = [minimum(@elapsed(unir_anidado(hombres[1:k], mujeres[1:k])) for _ in 1:3) for k in tamaños]
pendiente = ([ones(length(tamaños)) log.(tamaños)] \ log.(tiempos))[2]

set_theme!(tema_somosaguas())
fig = Figure(size = (900, 550))
ax = Axis(fig[1, 1]; xscale = log10, yscale = log10,
    title = "Unir por bucles anidados cuesta n²",
    xlabel = "Municipios en cada tabla, n", ylabel = "Tiempo (segundos)",
    xticks = (tamaños, string.(tamaños)))
scatterlines!(ax, tamaños, tiempos)
text!(ax, tamaños[end], tiempos[end]; text = "Bucles anidados, pendiente $(round(pendiente; digits = 2))",
    align = (:right, :bottom), offset = (-10, 4))
resultados = mkpath(joinpath(@__DIR__, "resultados"))
save(joinpath(resultados, "complejidad.png"), fig; px_per_unit = 1.5)
```

Las dos tablas tienen 8169 y 8117 filas, y los bucles anidados hacen $8169 \times 8117 = 66\,307\,773$ comparaciones para encontrar los 8116 municipios que están en las dos. La pendiente medida es 1.99.

## 3. Ejercicios

### Ejercicio 1: la tabla hash

- **Tarea:** escribe `insertar!(t, clave, valor)`, que añade el par a su cubeta o sustituye el valor si la clave ya está, y `buscar(t, clave)`, que devuelve `valor, comparaciones`, o `nothing, comparaciones` si la clave no está, contando las comparaciones de claves que hace. Con ellas, escribe `unir_hash(a, b)`, que guarda `a` en una tabla de `nextpow(2, length(a))` cubetas, busca en ella cada fila de `b` y devuelve `pares, comparaciones`, con los pares en la forma `(municipio, hombres, mujeres)`.
- **Pregunta causal:** la unión por hash de las dos tablas completas hace del orden de $12\,000$ comparaciones, frente a 66 millones. Añade sus tiempos a la figura: ¿qué pendiente sale, y por qué no es exactamente 1?

### Ejercicio 2: ordenar y fusionar

- **Tarea:** escribe `unir_ordenado(a, b)`, que ordena las dos tablas por la clave con `sort` y las recorre a la vez con dos índices, avanzando el de la clave menor. Devuelve `pares, comparaciones`, contando solo las comparaciones de la fusión.
- **Pregunta causal:** la fusión hace menos comparaciones que la tabla hash, unas $8000$. ¿Por qué no es entonces la más barata? ¿Cuándo convendría a pesar de todo, por ejemplo si las tablas ya llegan ordenadas o no caben en memoria?

### Ejercicio 3: la lista enlazada

- **Tarea:** escribe `invertir(lista)`, que devuelve una lista nueva con los mismos valores en orden inverso, con un bucle. Pruébala con una lista de 200 000 nodos. Escribe después la versión recursiva, en una línea, y ejecútala con la misma lista.
- **Pregunta causal:** ¿por qué la versión recursiva termina en `StackOverflowError`? Mide cuánto tarda en llegar al elemento 100 000 una lista y cuánto un vector, y explica la diferencia con la memoria de la semana 2.

### Ejercicio 4: las colisiones y el cumpleaños

- **Tarea:** escribe `pares_en_colision(t)`, que cuenta los pares de claves que comparten cubeta, $\sum_b \binom{n_b}{2}$. Compáralo con $\binom{n}{2}/m$ para los códigos de municipio de la DGT y para 5000 claves aleatorias en $2^{14}$ cubetas. Calcula después, para el problema del cumpleaños, la probabilidad de que no colisione nadie con $n = 23$ y $m = 365$, exacta y aproximada.
- **Pregunta causal:** demuestra en la pizarra la fórmula de la esperanza con variables indicadoras. ¿Por qué no hace falta que las colisiones sean independientes? ¿Cuántas cubetas harían falta para que la probabilidad de no tener ninguna colisión con los 8169 municipios fuera la mitad?

## 4. Criterio de verificación por integración continua

La entrega es `semana-08/laboratorio_semana8.jl` en el repositorio de la asignatura, que lee los datos de `semana-02/datos/`. Con cada push, la integración continua ejecuta `semana-08/test_semana8.jl`, y el laboratorio se supera si el script:

1. Se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior y deja la figura en `semana-08/resultados/`.
2. Supera `test_tabla_hash`: con 10 000 claves en $2^{14}$ cubetas, `buscar` devuelve el valor de cada clave con dos comparaciones o menos de media, `nothing` para las que no están, e `insertar!` sustituye el valor de una clave repetida sin duplicarla.
3. Supera `test_uniones`: `unir_hash` y `unir_ordenado` dan los mismos pares que `unir_anidado`, los 8116 municipios, con no más de $2m$ y de $n + m$ comparaciones, respectivamente.
4. Supera `test_invertir`: `invertir` da la vuelta a una lista de 200 000 nodos, demasiado larga para una versión recursiva.
5. Supera `test_colisiones`: `pares_en_colision` cuenta los pares de cada cubeta y, con 5000 claves aleatorias, queda a menos de un 20 % de $\binom{n}{2}/m$.

Los tests leen `hombres`, `mujeres`, `unir_anidado`, `TablaHash`, `Nodo`, `insertar!`, `buscar`, `unir_hash`, `unir_ordenado`, `invertir` y `pares_en_colision`: el script conserva esos nombres. Antes de enviarlo, el mismo test se pasa en la terminal:

```sh
julia --project=semana-08 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-08 --depwarn=yes semana-08/test_semana8.jl
```
