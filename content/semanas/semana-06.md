---
title: "Semana 6: Probabilidad, inferencia bayesiana y simulación Monte Carlo"
date: 2027-08-02
weight: 6
---

**Módulo:** Cimientos formales y programación  
**Texto de referencia:** Joseph K. Blitzstein y Jessica Hwang, *Introduction to Probability* (Harvard Stat 110); E. T. Jaynes, *Probability Theory: The Logic of Science*; Jeff Gill, *Bayesian Social Science Statistics*  
**Herramientas:** Julia 1.11 o posterior, con `Random` y `Statistics` (biblioteca estándar); `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl`, sujeto a integración continua, y prueba de la pizarra (*Blackboard Defence*)


> [!nota] Lo que esta semana da por sabido
> - **De la [prueba de nivel](../../diagnostico/):** el bloque E (Bayes, binomial, esperanza y normal) y el problema D3 (la integral como área: una densidad suma 1).
> - **Nuevo para todos:** el teorema de Bayes con densidades, la distribución beta, las *priors* conjugadas y la simulación Monte Carlo.
> - **Para repasar:** 3Blue1Brown, [el teorema de Bayes](https://www.3blue1brown.com/lessons/bayes-theorem); Blitzstein y Hwang, capítulos 2 a 5, y el 8 para la distribución beta, en los [consejos](../../consejos/).

## 1. Marco conceptual: la probabilidad como extensión de la lógica en condiciones de incertidumbre

La estadística frecuentista trata los parámetros sociales desconocidos (la tasa real de apoyo a una medida, la heredabilidad de un rasgo o la efectividad de una política) como constantes fijas, y define la probabilidad como la frecuencia relativa a lo largo de repeticiones del mismo procedimiento. Es el razonamiento de Gauss-Markov y de la simulación con $\mathbf{X}$ fija de la semana 4, y es correcto en su terreno: dice cómo se comporta un método de estimación.

La **inferencia bayesiana**, respaldada por el teorema de Cox y formalizada por Jaynes, responde a otra pregunta, qué creer del parámetro con estos datos, y trata la probabilidad como una **medida cuantitativa del grado de creencia racional** dada la información disponible.

1. **El teorema de Bayes para parámetros continuos.** Sea $\theta \in [0, 1]$ el parámetro social de interés (por ejemplo, la proporción real de individuos de una población que alberga una preferencia latente) y $D$ los datos observados en una muestra de campo:

   $$
   P(\theta \mid D) = \frac{P(D \mid \theta) \, P(\theta)}{P(D)} \propto P(D \mid \theta) \, P(\theta)
   $$

   - **$P(\theta)$, la *prior* o creencia a priori:** la distribución que formaliza el conocimiento o la incertidumbre sobre el parámetro antes de ver los nuevos datos.
   - **$P(D \mid \theta)$, la verosimilitud (*likelihood*):** la probabilidad de haber observado exactamente la muestra $D$ si el parámetro real fuera $\theta$. Para procesos de conteo dicotómico sigue una distribución binomial:

     $$
     P(k \mid n, \theta) = \binom{n}{k} \theta^k (1 - \theta)^{n - k}
     $$

   - **$P(\theta \mid D)$, la *posterior* o distribución a posteriori:** la síntesis actualizada que combina la evidencia empírica con la información previa.

2. **La familia conjugada beta-binomial.** Si la *prior* es una distribución beta de parámetros de forma $\alpha$ y $\beta$, $\theta \sim \text{Beta}(\alpha, \beta)$, la actualización ante $k$ éxitos en $n$ ensayos tiene solución analítica directa:

   $$
   \theta \mid k \sim \text{Beta}(\alpha + k, \; \beta + n - k)
   $$

   La esperanza a posteriori es un promedio ponderado exacto entre la media de la *prior* y la estimación de máxima verosimilitud de la muestra, $\hat{p} = k/n$:

   $$
   \mathbb{E}[\theta \mid k] = \frac{\alpha + k}{\alpha + \beta + n}
   $$

3. **Muestreo Monte Carlo e intervalos de credibilidad.** La distribución a posteriori permite extraer, por simulación Monte Carlo, **intervalos de credibilidad del 95 %**: dados el modelo y la *prior*, la probabilidad de que el parámetro real $\theta$ esté en el intervalo $[a, b]$ es del 95 %. Un intervalo de confianza del 95 % dice otra cosa: el procedimiento que lo construye acierta en el 95 % de las muestras. El ejercicio 4 compara los dos. El código base calcula el intervalo central, entre los percentiles 2,5 y 97,5; el intervalo de máxima densidad (HDI) coincide con él cuando la posterior es simétrica.

## 2. Código base de referencia (`laboratorio_semana6.jl`)

El script estima la prevalencia real de una actitud o norma social tabú a partir de una encuesta: aproxima la posterior sobre una rejilla (*grid approximation*) y la explora con 100 000 extracciones Monte Carlo, obtenidas por inversión de su función de distribución acumulada.

```julia
using CairoMakie, Somosaguas
using Random, Statistics

Random.seed!(42)

# 1. Espacio del parámetro: los puntos medios de mil intervalos de [0, 1]. Sin los
#    extremos: con k = 0, 0 * log(0) daría NaN, y un solo NaN contamina la posterior entera
p = 0.0005:0.001:0.9995

# 2. Prior informada Beta(α, β), normalizada sobre la rejilla
α, β = 3, 6
prior = @. p^(α - 1) * (1 - p)^(β - 1)
prior ./= sum(prior)

# 3. Datos: n = 200 encuestados, k = 75 respuestas afirmativas.
#    Verosimilitud binomial en escala logarítmica, para no salir del rango de Float64
n, k = 200, 75
logL = @. k * log(p) + (n - k) * log(1 - p)
verosimilitud = exp.(logL .- maximum(logL))

# 4. Teorema de Bayes: posterior ∝ verosimilitud × prior
posterior = verosimilitud .* prior
posterior ./= sum(posterior)

# 5. Monte Carlo: 100 000 extracciones de la posterior por inversión de su función
#    de distribución acumulada, F
F = cumsum(posterior)
F ./= F[end]
muestras = p[searchsortedfirst.(Ref(F), rand(100_000))]
media = mean(muestras)
intervalo = quantile(muestras, [0.025, 0.975])   # intervalo de credibilidad central del 95 %

# 6. Panel diagnóstico: la actualización de creencias y la simulación, lado a lado
set_theme!(tema_somosaguas())
fig = Figure(size = (1400, 550))
ax1 = Axis(fig[1, 1]; title = "Actualización bayesiana de creencias",
    xlabel = "Proporción real en la población, p", ylabel = "Densidad de probabilidad")
vspan!(ax1, intervalo...; color = (:gray, 0.15))
escala = length(p)   # de probabilidad por punto de la rejilla a densidad
lines!(ax1, p, prior .* escala)
lines!(ax1, p, verosimilitud .* maximum(posterior) .* escala)
lines!(ax1, p, posterior .* escala)
text!(ax1, 0.27, maximum(prior) * escala; text = "Prior Beta(3, 6)", align = (:right, :bottom), offset = (0, 6))
text!(ax1, 0.34, 9; text = "Verosimilitud, 75 de 200", align = (:right, :center))
text!(ax1, 0.405, 9; text = "Posterior", align = (:left, :center))
vlines!(ax1, [media]; color = :black)
ax2 = Axis(fig[1, 2]; title = "Simulación Monte Carlo, 100 000 extracciones",
    xlabel = "Valor de p simulado", ylabel = "Densidad")
hist!(ax2, muestras; bins = 0:0.005:1, normalization = :pdf)   # 5 puntos de la rejilla por barra
xlims!(ax2, extrema(muestras)...)
vlines!(ax2, [media]; color = :black)
vlines!(ax2, intervalo; color = :gray, linestyle = :dot)
resultados = mkpath(joinpath(@__DIR__, "resultados"))
save(joinpath(resultados, "inferencia_bayesiana.png"), fig; px_per_unit = 1.5)
```

## 3. Ejercicios

### Ejercicio 1: resistencia a la evidencia y sensibilidad a las *priors* dogmáticas

Dos analistas se enfrentan a la misma muestra empírica, $n = 200$ y $k = 75$:

- **Analista A (agnóstico):** adopta una *prior* uniforme, $\text{Beta}(1, 1)$. Uniforme en $\theta$ no quiere decir sin prejuicios: deja de serlo si se reparametriza, por ejemplo en log-odds, $\log\frac{\theta}{1 - \theta}$. La alternativa clásica es la *prior* de Jeffreys, $\text{Beta}(\tfrac{1}{2}, \tfrac{1}{2})$.
- **Analista B (dogmático):** mantiene una *prior* muy concentrada en torno a la hipótesis de que la norma no existe, $\text{Beta}(1, 100)$.

1. **Tarea:** modifica el script para simular las distribuciones a posteriori de ambos analistas, y la de un tercero con la *prior* de Jeffreys.
2. **Pregunta causal:** suponiendo que la proporción de la muestra se mantiene en $0.375$, ¿cuántas observaciones adicionales necesitaría el analista B para que la media de su posterior quede a menos de $\pm 0.02$ de ella? Explica, con la media a posteriori de la sección 1, por qué una *prior* $\text{Beta}(\alpha, \beta)$ pesa como $\alpha + \beta$ observaciones ficticias. ¿Importa aquí la diferencia entre la uniforme y la de Jeffreys?

### Ejercicio 2: actualización secuencial, individuo a individuo (*online learning*)

Con observaciones independientes, la verosimilitud de la muestra es el producto de las de cada observación, y procesar 200 observaciones en bloque equivale exactamente a actualizar la distribución a posteriori **individuo a individuo**: la *posterior* tras la observación $i$ es la *prior* de la observación $i + 1$.

1. **Tarea:** escribe un bucle `for` que recorra un vector de 200 respuestas individuales, `0` o `1` (por ejemplo, `shuffle([ones(Int, 75); zeros(Int, 125)])`), y dibuja la evolución de la media a posteriori $\mathbb{E}[\theta_t]$ para $t \in \{1, \dots, 200\}$, junto con el estrechamiento de la banda de credibilidad del 95 %.
2. **Pregunta causal:** demuestra empíricamente que la desviación típica a posteriori disminuye a ritmo $\mathcal{O}(1/\sqrt{n})$, es decir, la varianza a ritmo $\mathcal{O}(1/n)$.
3. **En la pizarra:** la primera actualización tiene $n = 1$ y $k = 0$ o $k = 1$. ¿Qué habría pasado con una rejilla que incluyera $0$ y $1$? Pruébalo.

### Ejercicio 3: decisión bajo incertidumbre con una función de pérdida asimétrica

Un regulador público debe decidir si financia un programa de intervención social. Implantar la medida cuando la prevalencia real es $p < 0.40$ cuesta **500 000 €** (falso positivo); no intervenir cuando es $p \ge 0.40$ cuesta **2 000 000 €** (falso negativo).

1. **Tarea:** con las 100 000 muestras Monte Carlo del modelo, evalúa la **pérdida esperada** de ambas decisiones:

   $$
   \begin{aligned}
   L(\text{intervenir}) &= 500\,000 \cdot P(p < 0.40 \mid \text{datos}) \\
   L(\text{no intervenir}) &= 2\,000\,000 \cdot P(p \ge 0.40 \mid \text{datos})
   \end{aligned}
   $$

2. **Pregunta causal:** aunque la estimación puntual de la prevalencia sea $\mathbb{E}[p \mid \text{datos}] = 0.373$, por debajo del umbral, ¿cuál es la decisión óptima, la que minimiza la pérdida esperada? Demuestra por qué la decisión racional exige considerar toda la distribución a posteriori y no un mero valor promedio.

### Ejercicio 4: intervalo de confianza e intervalo de credibilidad

1. **Tarea:** calcula el intervalo de confianza del 95 % de la proporción, $\hat{p} \pm 1.96\sqrt{\hat{p}(1 - \hat{p})/n}$, y compáralo con el de credibilidad del código base. Repite la comparación con una muestra de $n = 16$ y $k = 6$, la misma proporción, con la *prior* del código base y con la del analista B.
2. **Pregunta causal:** ¿cuándo casi coinciden los dos intervalos y cuándo se separan? ¿Qué pregunta responde cada uno?

### Ejercicio 5: la respuesta aleatorizada de Warner

El código base supone que todo el mundo responde con sinceridad. En una pregunta tabú, el problema principal no es la *prior*, sino el sesgo de deseabilidad social. La respuesta aleatorizada de Warner (1965) lo evita con un mecanismo de azar que solo ve el encuestado: con probabilidad $\pi$ contesta a «¿sostienes la norma?» y, si no, a «¿no la sostienes?». Nadie sabe a qué pregunta respondió cada uno, y la probabilidad de un «sí» pasa a ser una mezcla conocida de $\theta$ y del azar:

$$
\lambda(\theta) = \pi\,\theta + (1 - \pi)(1 - \theta)
$$

1. **Tarea:** con $\pi = 0.7$ y 90 «síes» de 200, cambia solo la verosimilitud: $\lambda(\theta)$ en lugar de $\theta$. Compara la posterior con la del código base.
2. **Pregunta causal:** ¿cuánto se ensancha la posterior, y cuántos encuestados que respondieran directamente darían la misma precisión? ¿Por qué el mecanismo no sirve con $\pi = 0.5$? El modelo de medición importa tanto como el de inferencia, y el marco bayesiano lo incorpora sin cambiar nada más.

## 4. Criterio de verificación por integración continua

La entrega es `semana-06/laboratorio_semana6.jl` en el repositorio de la asignatura. Con cada push, la integración continua ejecuta `semana-06/test_semana6.jl`, y el laboratorio se supera si el script:

1. Se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior.
2. Deja el panel de gráficos comparativos en PNG, en `semana-06/resultados/`.
3. Supera el test unitario `test_bayes_conjugada`, que comprueba que la media de las 100 000 muestras Monte Carlo coincide con la solución analítica de la beta conjugada, $\frac{\alpha + k}{\alpha + \beta + n}$, con un error relativo menor del 0,1 %. El test lee `α`, `β`, `k`, `n` y `muestras`: el script conserva esos nombres del código base, y la *prior* se construye a partir de `α` y `β`.
4. Calcula las pérdidas esperadas del ejercicio 3 a partir de las muestras, sin atajos, en `perdida_intervenir` y `perdida_no_intervenir`.

Antes de enviarlo, el mismo test se pasa en la terminal:

```sh
julia --project=semana-06 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-06 --depwarn=yes semana-06/test_semana6.jl
```
