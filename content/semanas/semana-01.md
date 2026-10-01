---
title: "Semana 1: Alineamiento electoral y geometría vectorial en ℝ³"
date: 2027-06-28
weight: 1
---

**Módulo:** Cimientos formales y programación  
**Texto de referencia:** Gilbert Strang, *Linear Algebra and Its Applications*  
**Herramientas:** Julia 1.11 o posterior, con `LinearAlgebra` y `Random` (biblioteca estándar); `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl`, sujeto a integración continua, y prueba de la pizarra (*Blackboard Defence*)


> [!nota] Lo que esta semana da por sabido
> - **De la [prueba de nivel](../../diagnostico/):** los bloques A (funciones y sumatorios), B (vectores, norma y producto escalar) y C (producto de matrices). Quien cursó Matemáticas Aplicadas a las Ciencias Sociales no vio vectores: el bloque B, antes de empezar.
> - **Nuevo para todos:** los vectores de $\mathbb{R}^n$ con $n > 3$, la normalización por filas de una matriz y la programación en Julia, que empieza en la sección 0.
> - **Para repasar:** 3Blue1Brown, [vectores](https://www.3blue1brown.com/lessons/vectors), [producto de matrices](https://www.3blue1brown.com/lessons/matrix-multiplication) y [producto escalar](https://www.3blue1brown.com/lessons/dot-products); el capítulo 8 de Gintis, en los [consejos](../../consejos/).

## 0. Primeros pasos en Julia

Si nunca has programado, empieza aquí; si ya programas en otro lenguaje, lee el bloque de código y sigue. Con el entorno ya instalado (ver el [entorno de trabajo](https://nuevasomosaguas.github.io/entorno.html)), escribe `julia` en la terminal y se abre el REPL, la consola interactiva: escribes una expresión, pulsas Intro y Julia responde. `?` antes de un nombre muestra su ayuda (`?norm`), `]` abre el gestor de paquetes y `;` ejecuta una orden de la terminal sin salir; la tecla de borrar vuelve al modo normal.

Escribe estas líneas una a una y comprueba el resultado:

```julia
x = 3                      # un entero (Int64)
y = 2.5                    # un número real (Float64)
v = [1, 2, 3]              # un vector columna: comas entre elementos
fila = [1 2 3]             # una matriz de 1 × 3: espacios entre columnas
A = [1 2; 3 4]             # una matriz de 2 × 2: ; entre filas

v[1]                       # 1: Julia cuenta desde 1, no desde 0
A[2, 1]                    # 3: fila 2, columna 1
A[:, 2]                    # [2, 4]: la columna 2 entera

A * [1, 1]                 # [3, 7]: producto de matriz por vector
v .* v                     # [1, 4, 9]: el punto aplica la operación elemento a elemento
v .^ 2                     # [1, 4, 9]
sqrt.(v)                   # [1.0, 1.414, 1.732]: con un punto, cualquier función

using LinearAlgebra        # la biblioteca estándar de álgebra lineal
dot(v, v), norm(v)         # (14, 3.742): producto escalar y norma

cuadrado(t) = t^2          # una función en una línea
function media(z)          # una función de varias líneas
    s = 0.0
    for zi in z            # un bucle que recorre z
        s += zi
    end
    return s / length(z)
end
cuadrado(4), media([1, 2, 6])   # (16, 3.0)

[i^2 for i in 1:5]         # [1, 4, 9, 16, 25]: un vector construido con un bucle
```

`v * v` da un error, `MethodError`: el producto de matrices de un vector columna por otro no está definido. Lo que se quería decir es `v .* v`, elemento a elemento, o `v' * v`, fila por columna, que da el producto escalar, 14. Leer el mensaje de error entero, aunque sea largo, es parte del oficio: dice qué operación no existe y con qué tipos se intentó.

**De la consola al script.** Lo que escribes en el REPL se pierde al cerrarlo; lo que se entrega es un archivo `.jl`. Se ejecuta con `julia --project=semana-01 semana-01/laboratorio_semana1.jl`: `--project` le dice a Julia qué paquetes usar, los del `Project.toml` de la carpeta, que se instalan una vez con `julia --project=semana-01 -e 'using Pkg; Pkg.instantiate()'`. El test de la sección 4 se ejecuta igual.

**Para practicar, sin entrega:**

1. Calcula la norma de $(3, 4)$ con `norm` y con `sqrt(sum(v .^ 2))`. Las dos deben dar 5.
2. Escribe `unitario(v) = v / norm(v)` y comprueba que `norm(unitario([3, 4]))` da 1.
3. Calcula $AB$ y $BA$ con las matrices del problema C1 de la [prueba de nivel](../../diagnostico/) y comprueba tus cuentas a mano.
4. Escribe una función que reciba un vector y devuelva el número de elementos mayores que su media. Pruébala con `[1, 2, 6]`: debe dar 1.

## 1. Marco conceptual y geometría del espacio político

La sociología contemplativa aborda las preferencias electorales mediante categorías cualitativas imprecisas. En la Nueva Somosaguas representamos a la población de votantes y a la oferta partidista como vectores continuos en un espacio de características de dimensión $d$.

Definimos el espacio político tridimensional $\mathbb{R}^3$ mediante los ejes:

1. **$x_1$ (eje económico):** $-1.0$ (intervencionismo estatal) $\leftrightarrow$ $+1.0$ (libre mercado).
2. **$x_2$ (eje valórico o social):** $-1.0$ (progresismo secular) $\leftrightarrow$ $+1.0$ (conservadurismo tradicional).
3. **$x_3$ (eje territorial):** $-1.0$ (autonomismo, descentralización) $\leftrightarrow$ $+1.0$ (centralismo estatista).

- Un votante $i$ es un vector $\mathbf{v}_i = [x_{i1}, x_{i2}, x_{i3}]^T \in [-1, 1]^3$. La sociedad completa se estructura en una **matriz de votantes** $\mathbf{V} \in \mathbb{R}^{N \times 3}$.
- Un partido $j$ es un vector $\mathbf{c}_j = [y_{j1}, y_{j2}, y_{j3}]^T \in [-1, 1]^3$. La oferta electoral se estructura en una **matriz de candidatos** $\mathbf{C} \in \mathbb{R}^{M \times 3}$.

La proximidad ideológica no se mide con la distancia euclídea simple, que se ve distorsionada por la intensidad o magnitud del sesgo, sino con la **similitud de coseno** ($\cos \theta$), que evalúa el alineamiento angular entre las prioridades del votante y el programa del candidato:

$$
\text{Similitud}(\mathbf{v}_i, \mathbf{c}_j) = \cos(\theta_{ij}) = \frac{\mathbf{v}_i \cdot \mathbf{c}_j}{\|\mathbf{v}_i\|_2 \, \|\mathbf{c}_j\|_2}
$$

Gracias a las propiedades del álgebra matricial, la simulación del alineamiento de $N = 1000$ votantes con $M = 5$ partidos se resuelve en **una sola multiplicación de matrices normalizadas por filas**:

$$
\mathbf{S} = \mathbf{\bar{V}} \, \mathbf{\bar{C}}^T \in \mathbb{R}^{1000 \times 5}
$$

## 2. Código base de referencia (`laboratorio_semana1.jl`)

```julia
using LinearAlgebra, Random

# 1. Matriz de candidatos C (5×3): una fila por partido
partidos = ["A (Socialdemócrata Centralista)", "B (Conservador Mercado)",
            "C (Izquierda Verde Autonómica)", "D (Liberal Reformista)",
            "E (Tradicionalista Regional)"]
C = [-0.6 -0.4  0.5
      0.8  0.7  0.6
     -0.8 -0.8 -0.7
      0.6 -0.3  0.1
      0.2  0.8 -0.8]

# 2. Matriz de votantes V (1000×3): tres bloques gaussianos de covarianza diagonal
Random.seed!(42)
bloque(μ, σ², n) = μ' .+ randn(n, 3) .* sqrt.(σ²)'
V = clamp.([bloque([-0.5, -0.4,  0.2], [0.15, 0.15, 0.20], 400)
            bloque([ 0.6,  0.5,  0.3], [0.20, 0.15, 0.15], 400)
            bloque([ 0.0, -0.5, -0.6], [0.25, 0.20, 0.15], 200)], -1, 1)

# 3. Normalización por filas y producto matricial
normalizar(X) = X ./ norm.(eachrow(X))
S = normalizar(V) * normalizar(C)'

# 4. Voto por máximo alineamiento angular (argmax de cada fila)
votos = argmax.(eachrow(S))
cuotas = [count(==(j), votos) for j in 1:5] ./ length(votos)
```

## 3. Ejercicios

### Ejercicio 1: dinámica del espacio político y el regreso de Downs y Hotelling

El *Partido D (Liberal Reformista)* observa sus resultados y decide mover su programa para capturar votos del *Partido A*: su vector pasa de $[0.6, -0.3, 0.1]$ a $[-0.3, -0.4, 0.4]$.

- **Tarea:** modifica la matriz $\mathbf{C}$, recalcula la matriz de alineamiento $\mathbf{S}$ y calcula la variación porcentual de la cuota de voto de todos los partidos.
- **Pregunta causal:** ¿qué partido sufre la mayor fuga de votantes? Explica el fenómeno geométrico analizando la variación de los ángulos $\theta$ en el subespacio socioeconómico.

### Ejercicio 2: expansión dimensional y la maldición de la dimensión al añadir un eje climático ($\mathbb{R}^4$)

Añade un cuarto eje al espacio político: **$x_4$ (transición ecológica):** $-1.0$ (negacionismo, productivismo) $\leftrightarrow$ $+1.0$ (ecologismo radical).

- **Tarea:** redefine la matriz de candidatos $\mathbf{C} \in \mathbb{R}^{5 \times 4}$ y la matriz de votantes $\mathbf{V} \in \mathbb{R}^{1000 \times 4}$. Asigna valores al cuarto eje respetando las correlaciones esperadas (por ejemplo, el *Partido C* adopta $+0.9$ y el *Partido B*, $-0.5$).
- **Pregunta causal:** recalcula la simulación de voto. ¿Cómo altera la introducción de una dimensión ortogonal adicional la polarización previa del voto en el eje económico-territorial?

### Ejercicio 3: ortogonalidad y estrategia de nicho

Diseña un nuevo candidato, el *Partido F*, cuyo vector $\mathbf{c}_F$ sea **estrictamente ortogonal** al programa del *Partido B (Conservador Mercado)*: $\mathbf{c}_F \cdot \mathbf{c}_B = 0$.

- **Tarea:** escribe una función que resuelva el sistema homogéneo para hallar un vector ortogonal no nulo $\mathbf{c}_F$, normalízalo y determina qué porcentaje del electorado abstencionista o mal atendido captura este nuevo actor.

## 4. Criterio de verificación por integración continua

La entrega es `semana-01/laboratorio_semana1.jl` en el repositorio de la asignatura. Con cada push, la integración continua ejecuta `semana-01/test_semana1.jl`, y el laboratorio se supera si el script:

1. Se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior.
2. Deja el diagnóstico gráfico tridimensional y el gráfico de barras electoral en PNG, en `semana-01/resultados/` (`joinpath(@__DIR__, "resultados")`).
3. Supera el test unitario `test_normas_unitarias`, que garantiza $\|\mathbf{\bar{V}}_i\|_2 = 1.0 \pm 10^{-7}$ para todo $i$. El test llama a `normalizar(V)`: el script conserva esos dos nombres del código base.

Antes de enviarlo, el mismo test se pasa en la terminal:

```sh
julia --project=semana-01 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-01 --depwarn=yes semana-01/test_semana1.jl
```
