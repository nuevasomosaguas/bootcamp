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

Como la teoría espacial del voto, representamos a la población de votantes y a la oferta partidista como vectores continuos en un espacio de características de dimensión $d$.

Definimos el espacio político tridimensional $\mathbb{R}^3$ mediante los ejes:

1. **$x_1$ (eje económico):** $-1.0$ (intervencionismo estatal) $\leftrightarrow$ $+1.0$ (libre mercado).
2. **$x_2$ (eje valórico o social):** $-1.0$ (progresismo secular) $\leftrightarrow$ $+1.0$ (conservadurismo tradicional).
3. **$x_3$ (eje territorial):** $-1.0$ (autonomismo, descentralización) $\leftrightarrow$ $+1.0$ (centralismo estatista).

- Un votante $i$ es un vector $\mathbf{v}_i = [x_{i1}, x_{i2}, x_{i3}]^T \in [-1, 1]^3$. La sociedad completa se estructura en una **matriz de votantes** $\mathbf{V} \in \mathbb{R}^{N \times 3}$.
- Un partido $j$ es un vector $\mathbf{c}_j = [y_{j1}, y_{j2}, y_{j3}]^T \in [-1, 1]^3$. La oferta electoral se estructura en una **matriz de candidatos** $\mathbf{C} \in \mathbb{R}^{M \times 3}$.

Qué partido está más cerca de un votante depende de cómo se mida la cercanía, y la medida es una hipótesis sobre cómo vota la gente, no un detalle técnico. Hay tres clásicas:

1. **Proximidad** (Downs, 1957; Enelow y Hinich, 1984), la estándar: el votante elige al partido a menor distancia euclídea, $\|\mathbf{v}_i - \mathbf{c}_j\|_2$.
2. **Direccional** (Rabinowitz y Macdonald, 1989): el origen es la posición neutral y el votante elige al partido con mayor producto escalar, $\mathbf{v}_i \cdot \mathbf{c}_j$, sin normalizar. Cuentan la dirección y la intensidad: entre dos partidos en la misma dirección que el votante, gana el más alejado del centro.
3. **Similitud de coseno** ($\cos \theta$): solo la dirección, el ángulo entre las prioridades del votante y el programa del candidato.

$$
\text{Similitud}(\mathbf{v}_i, \mathbf{c}_j) = \cos(\theta_{ij}) = \frac{\mathbf{v}_i \cdot \mathbf{c}_j}{\|\mathbf{v}_i\|_2 \, \|\mathbf{c}_j\|_2}
$$

El coseno descarta la intensidad por completo: un votante centrista en $[0.05, 0.05, 0.05]$ queda perfectamente alineado, $\cos \theta = 1$, con un partido extremista en $[1, 1, 1]$. Y un votante en el origen no tiene dirección: su coseno no está definido.

El código base usa el coseno porque se calcula con la operación de esta semana: el alineamiento de $N = 1000$ votantes con $M = 5$ partidos se resuelve en **una sola multiplicación de matrices normalizadas por filas**,

$$
\mathbf{S} = \mathbf{\bar{V}} \, \mathbf{\bar{C}}^T \in \mathbb{R}^{1000 \times 5}
$$

y el ejercicio 1 calcula los otros dos modelos y compara.

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

# 3. Normalización por filas y producto matricial. Una fila en el origen no tiene
#    dirección: dividir por su norma, 0, daría NaN, y normalizar la rechaza.
function normalizar(X)
    n = norm.(eachrow(X))
    if any(==(0), n)
        throw(ArgumentError("una fila en el origen no tiene dirección"))
    end
    return X ./ n
end
S = normalizar(V) * normalizar(C)'

# 4. Voto por máximo alineamiento angular (argmax de cada fila)
votos = argmax.(eachrow(S))
cuotas = [count(==(j), votos) for j in 1:5] ./ length(votos)
```

## 3. Ejercicios

### Ejercicio 1: proximidad, dirección y ángulo

- **Tarea:** calcula el voto de los mismos 1000 votantes con los tres modelos de la sección 1: el coseno del código base; el direccional, el `argmax` de cada fila de $\mathbf{V}\mathbf{C}^T$, sin normalizar; y el de proximidad, el `argmin` de cada fila de la matriz de distancias $D_{ij} = \|\mathbf{v}_i - \mathbf{c}_j\|_2$. La distancia también sale de una multiplicación de matrices: $\|\mathbf{v}_i - \mathbf{c}_j\|_2^2 = \|\mathbf{v}_i\|_2^2 - 2\,\mathbf{v}_i \cdot \mathbf{c}_j + \|\mathbf{c}_j\|_2^2$. Dibuja las cuotas de los cinco partidos en los tres modelos en un gráfico de barras agrupadas.
- **Pregunta causal:** ¿qué partido depende más del modelo, y por qué? Relaciónalo con la norma de su vector, lo lejos que está su programa del centro.

### Ejercicio 2: el regreso de Downs y Hotelling

El *Partido D (Liberal Reformista)* observa sus resultados y decide mover su programa para capturar votos del *Partido A*: su vector pasa de $[0.6, -0.3, 0.1]$ a $[-0.3, -0.4, 0.4]$.

- **Tarea:** modifica la matriz $\mathbf{C}$, recalcula el voto con los tres modelos y calcula la variación porcentual de la cuota de voto de todos los partidos en cada uno.
- **Pregunta causal:** ¿qué partido sufre la mayor fuga de votantes en cada modelo? ¿En cuáles le sale a cuenta el movimiento al *Partido D*, y en cuál no? El argumento de Downs y Hotelling, que lleva a los partidos hacia el votante mediano, está formulado con distancias: explica geométricamente por qué el mismo movimiento se juzga distinto con la distancia, con el ángulo y con el producto escalar, comparando la norma del nuevo $\mathbf{c}_D$ con la de $\mathbf{c}_A$.

### Ejercicio 3: un cuarto eje y la maldición de la dimensión

Añade un cuarto eje al espacio político: **$x_4$ (transición ecológica):** $-1.0$ (negacionismo, productivismo) $\leftrightarrow$ $+1.0$ (ecologismo radical).

- **Tarea:** redefine la matriz de candidatos $\mathbf{C} \in \mathbb{R}^{5 \times 4}$ y la matriz de votantes $\mathbf{V} \in \mathbb{R}^{1000 \times 4}$. Asigna valores al cuarto eje respetando las correlaciones esperadas (por ejemplo, el *Partido C* adopta $+0.9$ y el *Partido B*, $-0.5$).
- **Pregunta causal:** recalcula la simulación de voto. ¿Cómo altera la introducción de una dimensión ortogonal adicional la polarización previa del voto en el eje económico-territorial?
- **La maldición de la dimensión:** no aparece al pasar de tres ejes a cuatro, sino con muchos, cuando los cosenos entre puntos cualesquiera se amontonan alrededor de cero y dejan de discriminar. Genera 1000 pares de vectores aleatorios con `randn` en $d = 3$, $4$, $50$ y $100$, calcula el coseno de cada par y dibuja sus histogramas. Compara su desviación típica con $1/\sqrt{d}$. En un espacio de cien ejes, ¿qué le queda al coseno para distinguir a un votante afín de uno cualquiera?

### Ejercicio 4: ortogonalidad, abstención y estrategia de nicho

Con `argmax`, todo votante vota siempre a alguien: el modelo no tiene abstención. Añádela con un umbral: el votante se abstiene si su mejor coseno no llega a $\tau = 0.7$. Calcula la abstención con los cinco partidos.

Diseña un nuevo candidato, el *Partido F*, cuyo vector $\mathbf{c}_F$ sea **estrictamente ortogonal** al programa del *Partido B (Conservador Mercado)*: $\mathbf{c}_F \cdot \mathbf{c}_B = 0$.

- **Tarea:** el sistema homogéneo $\mathbf{c}_B \cdot \mathbf{c}_F = 0$ tiene una ecuación y tres incógnitas, así que sus soluciones no son un vector sino un plano entero. Resuélvelo con dos variables libres para hallar una base $\{\mathbf{u}_1, \mathbf{u}_2\}$ del plano (puedes comprobarla con `nullspace(c_B')`), recorre la familia $\mathbf{c}_F(\varphi) = \cos\varphi \, \mathbf{u}_1 + \sin\varphi \, \mathbf{u}_2$ en una rejilla de $\varphi \in [0, 2\pi)$ y, con el umbral, elige el $\varphi$ que da más votos al *Partido F*.
- **Pregunta causal:** ¿qué parte de esos votos viene de la abstención y qué parte de los demás partidos? ¿A qué votantes atiende un programa ortogonal al de B? En la semana 7, ese máximo se busca con derivadas en lugar de con una rejilla.

## 4. Criterio de verificación por integración continua

La entrega es `semana-01/laboratorio_semana1.jl` en el repositorio de la asignatura. Con cada push, la integración continua ejecuta `semana-01/test_semana1.jl`, y el laboratorio se supera si el script:

1. Se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior.
2. Deja el diagnóstico gráfico tridimensional y el gráfico de barras electoral en PNG, en `semana-01/resultados/` (`joinpath(@__DIR__, "resultados")`).
3. Supera el test unitario `test_normas_unitarias`, que garantiza $\|\mathbf{\bar{V}}_i\|_2 = 1.0 \pm 10^{-7}$ para todo $i$. El test llama a `normalizar(V)`: el script conserva esos dos nombres del código base.
4. Conserva el `normalizar` del código base, que rechaza con un `ArgumentError` una matriz con una fila en el origen en lugar de devolver `NaN`.

Antes de enviarlo, el mismo test se pasa en la terminal:

```sh
julia --project=semana-01 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-01 --depwarn=yes semana-01/test_semana1.jl
```
