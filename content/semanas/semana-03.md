---
title: "Semana 3: Proyecciones, mínimos cuadrados por QR, memoria y Git"
date: 2027-07-12
weight: 3
---

**Módulo:** Cimientos formales y programación  
**Texto de referencia:** Gilbert Strang, *Linear Algebra and Its Applications*, cap. 3 (proyecciones y mínimos cuadrados); Lloyd N. Trefethen y David Bau, *Numerical Linear Algebra*, lecciones 11-19; Brian W. Kernighan y Rob Pike, *The Practice of Programming*, caps. 1-3; Scott Chacon y Ben Straub, *Pro Git*, caps. 2-3  
**Herramientas:** Julia 1.11 o posterior, con `LinearAlgebra` y `Random` (biblioteca estándar); `git` en la terminal; `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl` y de su historial de Git, sujetos a integración continua, y prueba de la pizarra (*Blackboard Defence*)


> [!nota] Lo que esta semana da por sabido
> - **De la [prueba de nivel](../../diagnostico/):** los problemas B2 (proyección sobre una recta), C4 ($X^TX$) y D2 (mínimos cuadrados con un solo número), y el Gram-Schmidt modificado de la semana 2.
> - **Nuevo para todos:** la proyección sobre un subespacio, los mínimos cuadrados con $QR$, la sustitución hacia atrás, la memoria de un programa y Git.
> - **Para repasar:** Strang, *18.06*, lecciones [15, proyecciones sobre subespacios](https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/resources/lecture-15-projections-onto-subspaces/) y [16, matrices de proyección y mínimos cuadrados](https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/resources/lecture-16-projection-matrices-and-least-squares/); los capítulos 2 y 3 de [*Pro Git*](https://git-scm.com/book/es/v2).

## 1. Marco conceptual: proyectar sin perder precisión ni memoria

En la semana 2, Gram-Schmidt construyó una base ortonormal de $\mathcal{C}(A)$. Esta semana la usamos para el problema central de la estadística: hallar el punto de un subespacio más cercano a un vector de datos.

1. **La proyección ortogonal.** Si las columnas de $Q \in \mathbb{R}^{m \times n}$ son una base ortonormal de $\mathcal{C}(A)$, la proyección de $\mathbf{b}$ sobre $\mathcal{C}(A)$ es

   $$
   \mathbf{p} = P\mathbf{b}, \qquad P = QQ^T
   $$

   $P$ es **simétrica**, $P^T = (QQ^T)^T = QQ^T = P$, e **idempotente**, $P^2 = Q(Q^TQ)Q^T = QQ^T = P$. Su complemento, $I - P$, proyecta sobre $\mathcal{N}(A^T)$: el residuo $\mathbf{b} - P\mathbf{b}$ es ortogonal a $\mathcal{C}(A)$, como dice el teorema fundamental de la semana 2. $P$ es de $m \times m$ y no hace falta formarla nunca: $Q(Q^T\mathbf{b})$ da lo mismo con $O(mn)$ operaciones y memoria en lugar de $O(m^2)$.

2. **Mínimos cuadrados con $QR$.** El $\mathbf{x}$ que minimiza $\|A\mathbf{x} - \mathbf{b}\|$ cumple la ecuación normal, $A^TA\mathbf{x} = A^T\mathbf{b}$. Formar $A^TA$ eleva al cuadrado el número de condición, $\kappa(A^TA) = \kappa(A)^2$, y el error de redondeo crece en proporción. Con $A = QR$, $A^TA = R^TR$ y la ecuación normal se reduce a un sistema triangular:

   $$
   R\mathbf{x} = Q^T\mathbf{b}
   $$

   que se resuelve por **sustitución hacia atrás**, de la última incógnita a la primera, sin invertir nada, con $O(n^2)$ operaciones:

   $$
   x_i = \frac{1}{r_{ii}} \Big( c_i - \sum_{j > i} r_{ij} x_j \Big), \qquad i = n, n-1, \dots, 1, \qquad \mathbf{c} = Q^T\mathbf{b}
   $$

3. **La trampa de Gram-Schmidt.** Si $Q$ sale de Gram-Schmidt modificado, $Q^T\mathbf{b}$ hereda su pérdida de ortogonalidad, $\varepsilon\,\kappa(A)$, y la solución vuelve a equivocarse como la ecuación normal. El remedio, de Björck, es aplicar MGS a la matriz ampliada $[A \; \mathbf{b}]$: la última columna de su $R$ es $Q^T\mathbf{b}$ calculado con la misma aritmética que $R$, y su último elemento es $\|A\mathbf{x} - \mathbf{b}\|$.

   $$
   [A \;\; \mathbf{b}] = [Q \;\; \mathbf{q}_{n+1}] \begin{bmatrix} R & \mathbf{c} \\ \mathbf{0}^T & \rho \end{bmatrix} \implies R\mathbf{x} = \mathbf{c}, \quad \rho = \|A\mathbf{x} - \mathbf{b}\|
   $$

4. **La memoria.** Cada matriz nueva se reserva en el *heap*, y reservar y liberar cuesta tiempo. En Julia, `A[:, 1:k]` copia las columnas; `view(A, :, 1:k)`, o `@views` delante de una expresión, las usa donde están. Las funciones terminadas en `!` escriben en un argumento que ya existe: `mul!(y, A, x)` calcula $A\mathbf{x}$ sin reservar `y`, y `ldiv!` resuelve un sistema en el sitio. `@allocated` mide los bytes que reserva una llamada y `@time`, su tiempo y sus reservas. La primera llamada a una función incluye su compilación: se mide la segunda.

## 2. Git en la terminal

Git guarda la historia de un repositorio como una cadena de *commits*, cada uno con su autor, su fecha y su mensaje. Se configura una vez por máquina y se trabaja en un ciclo corto.

| Orden | Qué hace |
| :--- | :--- |
| `git config --global user.name "Nombre Apellido"` y `user.email` | La identidad que firma cada commit |
| `git status`, `git diff` | Qué ha cambiado desde el último commit |
| `git add -p` | Elegir, trozo a trozo, qué cambios entran en el próximo commit |
| `git commit -m "Mensaje"` | Guardar esos cambios: un commit, una idea |
| `git switch -c rama` | Crear una rama y pasar a ella (antes, `git checkout -b`) |
| `git merge rama` | Fusionar `rama` con la actual |
| `git log --graph --oneline` | La historia, con sus ramas y fusiones |

`.gitignore` lista lo que Git no debe guardar: los resultados que el script rehace, los datos pesados, los binarios temporales. El del repositorio de la asignatura ya excluye `semana-*/resultados/`.

Si dos ramas cambian la misma línea, `git merge` se detiene con un **conflicto** y marca el archivo con `<<<<<<<`, `=======` y `>>>>>>>`. Se resuelve editando el archivo hasta dejar la versión buena, sin las marcas, y con `git add` y `git commit`.

## 3. Código base de referencia (`laboratorio_semana3.jl`)

El script ajusta un perfil de ingresos por edad con polinomios de grado creciente, cuyas matrices de Vandermonde están cada vez peor condicionadas, y compara tres maneras de resolver los mínimos cuadrados: la ecuación normal invertida, `A \ b` y $R\mathbf{x} = Q^T\mathbf{b}$ con la `qr` de Julia. Mide el error de cada una frente a $\kappa(A)$ y lo que reserva en memoria.

```julia
using LinearAlgebra, Random, CairoMakie, Somosaguas

Random.seed!(42)

# 1. Un perfil de ingresos por edad: un polinomio de grado g en la edad, reescalada a
#    [0, 1]. Sus columnas, 1, t, t², …, se parecen cada vez más y κ(A) se dispara.
m = 500
edad = sort(18 .+ 47 .* rand(m))
t = (edad .- 18) ./ 47
vandermonde(g) = [ti^k for ti in t, k in 0:g]
A = vandermonde(9)
x_real = ones(size(A, 2))
b = A * x_real   # sin ruido: todo el error de cada método es de redondeo

# 2. Tres maneras de resolver min ‖Ax − b‖
normal(A, b) = inv(A' * A) * (A' * b)          # la ecuación normal, con la inversa
barra(A, b) = A \ b                            # el operador de Julia: QR de Householder
function householder(A, b)                     # la misma QR, paso a paso: Rx = Qᵀb
    F = qr(A)
    return F.R \ (F.Q' * b)[1:size(A, 2)]      # F.Q' * b tiene m elementos: bastan los n primeros
end
metodos = ["Ecuación normal con inv" => normal, "A \\ b" => barra, "QR, Rx = Qᵀb" => householder]

# 3. El error relativo de cada método frente a κ(A), del grado 1 al 11
error_relativo(x, x₀) = norm(x - x₀) / norm(x₀)
grados = 1:11
κ = [cond(vandermonde(g)) for g in grados]
errores = Dict(nombre => [error_relativo(f(vandermonde(g), vandermonde(g) * ones(g + 1)), ones(g + 1))
                          for g in grados] for (nombre, f) in metodos)

# 4. Lo que cada método pide al heap, en bytes, en el problema de grado 9
asignaciones(f, A, b) = (f(A, b); @allocated f(A, b))   # la primera llamada compila
for (nombre, f) in metodos
    println(rpad(nombre, 24), asignaciones(f, A, b), " bytes")
end

# 5. La figura: el error de redondeo crece como κ(A)² con la ecuación normal y como κ(A) con QR
set_theme!(tema_somosaguas())
fig = Figure(size = (900, 550))
ax = Axis(fig[1, 1]; xscale = log10, yscale = log10,
    title = "La ecuación normal eleva al cuadrado el número de condición",
    xlabel = "Número de condición, κ(A)", ylabel = "Error relativo en x",
    xticks = (10.0 .^ (0:2:8), [rich("10", superscript(string(k))) for k in 0:2:8]))
for (nombre, _) in metodos
    e = max.(errores[nombre], eps())   # el suelo, eps(), para que el logaritmo exista
    scatterlines!(ax, κ, e)
    debajo = nombre == "A \\ b"   # A \ b y QR casi coinciden: una etiqueta arriba y otra abajo
    text!(ax, κ[end], e[end]; text = nombre, align = (:right, debajo ? :top : :bottom),
        offset = (-8, debajo ? -6 : 4))
end
resultados = mkpath(joinpath(@__DIR__, "resultados"))
save(joinpath(resultados, "minimos_cuadrados.png"), fig; px_per_unit = 1.5)
```

`F.Q` es la $Q$ completa, de $m \times m$, guardada de forma implícita: `F.Q' * b` tiene $m$ elementos, y $R\mathbf{x} = Q^T\mathbf{b}$ usa los $n$ primeros. Con la $Q$ de $m \times n$ que devuelve Gram-Schmidt, `Q' * b` ya tiene $n$.

La ecuación normal es el método que menos memoria reserva en el código base, unos 7,5 kB frente a los 47-82 kB de las dos factorizaciones $QR$, que copian $A$ entera: $A^TA$ es de $10 \times 10$. Es el más barato y el que más se equivoca.

## 4. Ejercicios

### Ejercicio 1: sustitución hacia atrás sin reservar memoria

- **Tarea:** escribe `sustitucion_atras!(x, R, c)`, que resuelve $R\mathbf{x} = \mathbf{c}$ para $R$ triangular superior, escribe la solución en `x` y la devuelve, sin reservar memoria: `@allocated` de la segunda llamada debe dar 0. Compárala con `R \ c`.
- **Pregunta causal:** cuenta las multiplicaciones que hace en función de $n$. ¿Por qué la versión que escribe `dot(R[i, i+1:end], x[i+1:end])` reserva memoria en cada fila, y cómo lo evita `@views`?

### Ejercicio 2: mínimos cuadrados con tu propio Gram-Schmidt

- **Tarea:** copia tu `mgs` de la semana 2. Escribe primero la versión directa, $R\mathbf{x} = Q^T\mathbf{b}$ con `Q, R = mgs(A)`, y mide su error en el problema de grado 9. Escribe después `minimos_cuadrados_mgs(A, b)`, que aplica `mgs` a `[A b]` y resuelve con `sustitucion_atras!` sobre `view`s de su $R$. Añade los dos métodos a la figura.
- **Pregunta causal:** la versión directa se equivoca en torno a $10^{-5}$, como la ecuación normal, y la ampliada en torno a $10^{-12}$, aunque las dos usan el mismo `mgs`. Explica por qué con la pérdida de ortogonalidad de la semana 2.

### Ejercicio 3: el proyector y las vistas

Añade ruido a los datos, `y = b .+ 0.1 .* randn(m)`, para que $\mathbf{y}$ no esté en $\mathcal{C}(A)$.

- **Tarea:** con la $Q$ de `mgs(vandermonde(3))`, forma $P = QQ^T$ y comprueba que es simétrica, que $\|P^2 - P\|$ es del orden de $\varepsilon$ y que su traza es 4, la dimensión de $\mathcal{C}(A)$. Comprueba que el residuo $\mathbf{y} - P\mathbf{y}$ está en $\mathcal{N}(A^T)$. Mide con `@allocated` cuánta memoria reservan `P * y` (con $P$ ya formada) y `Q * (Q' * y)`, y `A[:, 1:k] \ y` frente a `@views A[:, 1:k] \ y` para los submodelos de grado $k - 1$.
- **Pregunta causal:** ¿cuántos bytes ocupa $P$ con $m = 500$? ¿Y con los $m = 4 \cdot 10^7$ registros de un censo?

### Ejercicio 4: el historial en Git

- **Tarea:** en tu repositorio de la asignatura, con tu identidad configurada, haz el ejercicio 2 en una rama, `git switch -c mgs`, con commits pequeños preparados con `git add -p`, y fusiónala con `master`. Provoca un conflicto cambiando la misma línea en las dos ramas y resuélvelo en la terminal. Comprueba con `git status` que `semana-03/resultados/` no entra en el repositorio.
- **En la pizarra:** dibuja el grafo de `git log --graph --oneline` y explica qué commit tiene dos padres.

## 5. Criterio de verificación por integración continua

La entrega es `semana-03/laboratorio_semana3.jl` en el repositorio de la asignatura, con su historial. Con cada push, la integración continua ejecuta `semana-03/test_semana3.jl`, y el laboratorio se supera si:

1. El script se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior y deja la figura en `semana-03/resultados/`.
2. Supera el test unitario `test_sustitucion_atras`: `sustitucion_atras!` resuelve un sistema triangular de $50 \times 50$, devuelve el mismo `x` que recibe y no reserva memoria.
3. Supera el test unitario `test_minimos_cuadrados_mgs`: `minimos_cuadrados_mgs` coincide con `A \ b` en un problema bien condicionado y se equivoca en menos de $10^{-8}$ en el problema de grado 9 del código base, lo que la versión directa con $Q^T\mathbf{b}$ no consigue. El test lee `A`, `b` y `x_real`: el script conserva esos nombres.
4. Supera el test `test_historial_git`: el historial tiene al menos una fusión, y `semana-03/resultados/` está excluida por `.gitignore` y sin archivos en el repositorio.

Antes de enviarlo, el mismo test se pasa en la terminal, dentro del repositorio:

```sh
julia --project=semana-03 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-03 --depwarn=yes semana-03/test_semana3.jl
```
