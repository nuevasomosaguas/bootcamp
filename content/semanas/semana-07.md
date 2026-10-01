---
title: "Semana 7: Optimización en varias variables: gradiente, hessiana, Newton y Lagrange"
date: 2027-08-09
weight: 7
---

**Módulo:** Cimientos formales y programación  
**Texto de referencia:** Carl P. Simon y Lawrence Blume, *Mathematics for Economists*, caps. 14 a 19 (cálculo en varias variables, formas cuadráticas y optimización con y sin restricciones); Stephen Boyd y Lieven Vandenberghe, [*Convex Optimization*](https://web.stanford.edu/~boyd/cvxbook/), cap. 9, en abierto; E. T. Jaynes, *Probability Theory: The Logic of Science*, cap. 11 (el principio de máxima entropía)  
**Herramientas:** Julia 1.11 o posterior, con `LinearAlgebra` y `Random` (biblioteca estándar); `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl`, sujeto a integración continua, y prueba de la pizarra (*Blackboard Defence*)

> [!nota] Lo que esta semana da por sabido
> - **De la [prueba de nivel](../../diagnostico/):** el bloque D, en particular el problema D4, la derivada de la función logística, $\sigma' = \sigma(1 - \sigma)$; de la semana 3, resolver sistemas sin invertir matrices y el número de condición; de la semana 6, la verosimilitud.
> - **Nuevo para todos:** las derivadas parciales, el gradiente y la hessiana, el desarrollo de Taylor en varias variables, la máxima verosimilitud, el método de Newton y los multiplicadores de Lagrange.
> - **Para repasar:** el [cálculo multivariable de Khan Academy](https://es.khanacademy.org/math/multivariable-calculus) y 3Blue1Brown, [el descenso de gradiente](https://www.3blue1brown.com/lessons/gradient-descent).

## 1. Marco conceptual: subir una colina con un mapa de su curvatura

En la semana 4 el estimador tenía fórmula cerrada: la proyección de $\mathbf{y}$ sobre $\mathcal{C}(X)$. En cuanto la variable que se quiere explicar es dicotómica —tener o no un contrato indefinido, votar o no votar— la fórmula desaparece, y estimar es buscar el máximo de una función de varias variables.

1. **El gradiente y la hessiana.** Para $f: \mathbb{R}^p \to \mathbb{R}$, el gradiente $\nabla f$ es el vector de las derivadas parciales, la dirección de máxima subida, y la hessiana $H$ es la matriz de las derivadas segundas, la curvatura. El desarrollo de Taylor de segundo orden los reúne:

   $$
   f(\boldsymbol\beta + \mathbf{h}) \approx f(\boldsymbol\beta) + \nabla f(\boldsymbol\beta)^T \mathbf{h} + \tfrac{1}{2}\, \mathbf{h}^T H(\boldsymbol\beta)\, \mathbf{h}
   $$

   En un máximo, $\nabla f = \mathbf{0}$ (condición de primer orden) y $H$ es semidefinida negativa (de segundo orden). Si $H$ es definida negativa en todo el dominio, $f$ es estrictamente cóncava y su máximo, si existe, es único.

2. **La regresión logística.** Cada individuo $i$ tiene $y_i \in \{0, 1\}$ y regresores $\mathbf{x}_i$, y el modelo es $P(y_i = 1 \mid \mathbf{x}_i) = \sigma(\mathbf{x}_i^T\boldsymbol\beta)$, con $\sigma(z) = 1/(1 + e^{-z})$. La log-verosimilitud de la muestra, su gradiente y su hessiana son

   $$
   \ell(\boldsymbol\beta) = \sum_i \Big[ y_i\, \mathbf{x}_i^T\boldsymbol\beta - \log\big(1 + e^{\mathbf{x}_i^T\boldsymbol\beta}\big) \Big], \qquad
   \nabla \ell = X^T(\mathbf{y} - \mathbf{p}), \qquad
   H = -X^T W X
   $$

   con $\mathbf{p} = \sigma(X\boldsymbol\beta)$ y $W = \text{diag}\big(p_i(1 - p_i)\big)$. Como $W$ tiene la diagonal positiva, $H$ es definida negativa si $X$ tiene rango completo: $\ell$ es cóncava y el estimador de máxima verosimilitud es único.

3. **Dos maneras de subir.** El **ascenso de gradiente** da pasos fijos en la dirección de máxima subida, $\boldsymbol\beta \leftarrow \boldsymbol\beta + \alpha \nabla\ell$. Solo converge si $\alpha < 2/|\lambda_{\text{máx}}(H)|$, y entonces avanza al ritmo que marca la dirección menos curvada: cuanto mayor es $\kappa(H) = \lambda_{\text{máx}}/\lambda_{\text{mín}}$, más despacio. El **método de Newton** maximiza en cada paso el modelo de Taylor de segundo orden:

   $$
   \boldsymbol\beta \leftarrow \boldsymbol\beta - H^{-1} \nabla\ell = \boldsymbol\beta + (X^T W X)^{-1} X^T (\mathbf{y} - \mathbf{p})
   $$

   Cada paso es unos mínimos cuadrados ponderados por $W$ —la semana 4 con pesos—, se resuelve como sistema lineal, sin invertir, y cerca del máximo el error se eleva al cuadrado en cada iteración: la convergencia es cuadrática. Además, $-H^{-1}$ en el máximo estima la matriz de varianzas de $\hat{\boldsymbol\beta}$.

4. **Los multiplicadores de Lagrange.** Para maximizar $f(\mathbf{x})$ sujeta a $g_j(\mathbf{x}) = c_j$, en el óptimo el gradiente de $f$ es una combinación de los gradientes de las restricciones, $\nabla f = \sum_j \lambda_j \nabla g_j$. El ejemplo que cierra esta semana viene de Jaynes: de todas las distribuciones $\mathbf{p}$ sobre los valores $v_1, \dots, v_K$ con una media dada $\mu$, ¿cuál supone menos de lo que no se sabe? La de **máxima entropía**:

   $$
   \max_{\mathbf{p}} \; -\sum_k p_k \log p_k \quad \text{s. a.} \quad \sum_k p_k = 1, \quad \sum_k v_k\, p_k = \mu
   \qquad \implies \qquad p_k = \frac{e^{\lambda v_k}}{\sum_j e^{\lambda v_j}}
   $$

   El multiplicador $\lambda$ es la única incógnita, y se fija con la condición de la media.

## 2. Código base de referencia (`laboratorio_semana7.jl`)

El script genera 2000 individuos con coeficientes conocidos, programa la log-verosimilitud, el gradiente y la hessiana, y estima por ascenso de gradiente. La figura muestra lo despacio que baja la norma del gradiente.

```julia
using LinearAlgebra, Random, CairoMakie, Somosaguas

Random.seed!(7)

# 1. Datos sintéticos: la probabilidad de un contrato indefinido según los años de estudio
#    y el sexo, con coeficientes conocidos para poder comprobar la estimación
n = 2000
estudios = rand(8:18, n)
mujer = rand(n) .< 0.5
X = [ones(n) estudios mujer]
β_real = [-3.0, 0.25, -0.4]
σ(z) = 1 / (1 + exp(-z))                      # la función logística
y = rand(n) .< σ.(X * β_real)

# 2. La log-verosimilitud, su gradiente y su hessiana
softplus(z) = z > 0 ? z + log1p(exp(-z)) : log1p(exp(z))   # log(1 + eᶻ) sin desbordarse
logverosimilitud(β, X, y) = sum(y .* (X * β) .- softplus.(X * β))
gradiente(β, X, y) = X' * (y .- σ.(X * β))
function hessiana(β, X, y)
    p = σ.(X * β)
    return -X' * (X .* (p .* (1 .- p)))      # −XᵀWX, con W = diag(p(1 − p))
end

# 3. Ascenso de gradiente con paso fijo: β ← β + α ∇ℓ(β)
function ascenso_gradiente(X, y; α = 1e-5, iteraciones = 20_000)
    β = zeros(size(X, 2))
    normas = Float64[]
    for _ in 1:iteraciones
        g = gradiente(β, X, y)
        push!(normas, norm(g))
        β += α * g
    end
    return β, normas
end
β_gradiente, normas_gradiente = ascenso_gradiente(X, y)

# 4. La figura: la norma del gradiente en cada iteración, en escala logarítmica
set_theme!(tema_somosaguas())
fig = Figure(size = (900, 550))
ax = Axis(fig[1, 1]; yscale = log10,
    title = "El ascenso de gradiente avanza despacio: la hessiana está mal condicionada",
    xlabel = "Iteración", ylabel = "‖∇ℓ(β)‖",
    xticks = (0:5_000:20_000, ["0", "5000", "10 000", "15 000", "20 000"]))
lines!(ax, 1:length(normas_gradiente), normas_gradiente)
text!(ax, 10_000, normas_gradiente[10_000]; text = "Ascenso de gradiente, α = 10⁻⁵",
    align = (:left, :bottom), offset = (8, 8))
resultados = mkpath(joinpath(@__DIR__, "resultados"))
save(joinpath(resultados, "convergencia.png"), fig; px_per_unit = 1.5)
```

Con $\alpha = 10^{-5}$, 20 000 iteraciones dejan $\|\nabla\ell\| \approx 0.77$, y la estimación aún a $0.04$ del máximo. Con $\alpha = 3 \cdot 10^{-5}$, el ascenso diverge.

## 3. Ejercicios

### Ejercicio 1: el método de Newton

- **Tarea:** escribe `newton_logistica(X, y)`, que parte de $\boldsymbol\beta = \mathbf{0}$, aplica el paso de Newton resolviendo el sistema con `\` y se detiene cuando $\|\nabla\ell\| < 10^{-8}$. Devuelve `β, normas`, con la norma del gradiente en cada iteración. Añádela a la figura. Calcula los errores típicos, $\sqrt{\text{diag}(-H^{-1})}$ en $\hat{\boldsymbol\beta}$, y comprueba si los coeficientes verdaderos están a menos de dos errores típicos.
- **Pregunta causal:** Newton converge en cinco iteraciones. Escribe la sucesión de normas y comprueba que cada una es del orden del cuadrado de la anterior. ¿Por qué el paso de Newton no depende de un $\alpha$ elegido a mano?

### Ejercicio 2: el paso del gradiente y el condicionamiento

- **Tarea:** calcula los autovalores de la hessiana en $\hat{\boldsymbol\beta}$ y el umbral $2/|\lambda_{\text{máx}}|$. Ejecuta el ascenso con $\alpha = 2 \cdot 10^{-5}$ y $3 \cdot 10^{-5}$, y explica lo que pasa con el umbral. Después centra los años de estudio, `estudios .- mean(estudios)`, y repite: ¿cuánto bajan $\kappa(H)$ y el número de iteraciones?
- **Pregunta causal:** ¿por qué el ritmo del ascenso lo marca el autovalor más pequeño, y el paso máximo el más grande? Relaciónalo con el número de condición de la semana 3.

### Ejercicio 3: Lagrange y la máxima entropía

- **Tarea:** deduce en la pizarra, con los multiplicadores de Lagrange, que la distribución de máxima entropía con media $\mu$ es $p_k \propto e^{\lambda v_k}$. Escribe después `max_entropia(valores, μ)`, que halla $\lambda$ por el método de Newton sobre la ecuación $m(\lambda) = \mu$, donde $m(\lambda) = \sum_k v_k p_k(\lambda)$, y devuelve $\mathbf{p}$. Demuestra antes que $m'(\lambda)$ es la varianza de $v$ bajo $\mathbf{p}(\lambda)$.
- **El dado de Jaynes:** un dado cuya media, tras muchas tiradas, es 4.5 en lugar de 3.5. ¿Qué probabilidad asigna la máxima entropía a cada cara? Debe salir $\mathbf{p} \approx (0.054, 0.079, 0.114, 0.165, 0.240, 0.348)$.
- **Pregunta causal:** con $\mu = 3.5$, ¿qué distribución sale, y por qué? ¿En qué sentido es la de máxima entropía la que menos supone?

### Ejercicio 4: el contrato indefinido en la EES (sin entrega)

Con los microdatos de la Encuesta de Estructura Salarial de la semana 4, `TIPOCON` (posición 29) vale 1 si el contrato es indefinido y 2 si es temporal. Estima con tu `newton_logistica` la probabilidad de un contrato indefinido según el sexo, los estudios y la antigüedad, e interpreta $e^{\hat\beta_j}$ como un cociente de *odds*. Es materia para la pizarra, no para la integración continua.

## 4. Criterio de verificación por integración continua

La entrega es `semana-07/laboratorio_semana7.jl` en el repositorio de la asignatura. Con cada push, la integración continua ejecuta `semana-07/test_semana7.jl`, y el laboratorio se supera si el script:

1. Se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior y deja la figura en `semana-07/resultados/`.
2. Supera `test_gradiente` y `test_hessiana`: `gradiente` coincide con las diferencias finitas de `logverosimilitud` y con $X^T(\mathbf{y} - \mathbf{p})$, y `hessiana` es $-X^TWX$, simétrica y definida negativa.
3. Supera `test_newton`: `newton_logistica` alcanza $\|\nabla\ell\| < 10^{-8}$ en diez iteraciones o menos y coincide con un Newton de referencia escrito aparte.
4. Supera `test_max_entropia`: `max_entropia` resuelve el dado de Jaynes y otro problema que el test elige, con las restricciones exactas y la solución de referencia a $10^{-8}$.

Los tests leen `X`, `y`, `logverosimilitud`, `gradiente`, `hessiana`, `newton_logistica` y `max_entropia`: el script conserva esos nombres. Antes de enviarlo, el mismo test se pasa en la terminal:

```sh
julia --project=semana-07 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-07 --depwarn=yes semana-07/test_semana7.jl
```
