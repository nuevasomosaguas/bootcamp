---
title: "Semana 5: Cálculo continuo, tasas de cambio y dinámica de contagio social"
date: 2027-07-26
weight: 5
---

**Módulo:** Cimientos formales y programación  
**Texto de referencia:** Gilbert Strang, *Calculus*; 3Blue1Brown, *The Essence of Calculus*  
**Herramientas:** Julia 1.11 o posterior, con `OrdinaryDiffEqTsit5` para el integrador de paso adaptativo; `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl`, sujeto a integración continua, y prueba de la pizarra (*Blackboard Defence*)

## 1. Marco conceptual: la derivada como motor de la dinámica social

Si en la fase I representamos la estructura estática de la población con vectores de características en $\mathbb{R}^d$, en la semana 5 abordamos la **evolución temporal de los estados sociales**. La sociología tradicional comete el error de comparar fotos fijas en el tiempo (estática comparativa); la ciencia social analítica estudia las **tasas instantáneas de cambio** mediante **ecuaciones diferenciales ordinarias** (EDO).

Consideremos la difusión de una creencia, una tecnología o una norma social en una población cerrada de tamaño $K$. Sea $N(t)$ el número de individuos que han adoptado la conducta en el instante $t$.

1. **Velocidad instantánea de cambio, $\frac{dN}{dt}$:** la variación neta de nuevos adoptantes por unidad de tiempo.
2. **La ecuación de difusión logística (modelo SI, o de Bass sin innovación externa):** la tasa de contagio es proporcional tanto al número de individuos informados ($N$) que transmiten la norma como al número de susceptibles ($K - N$) disponibles para adoptarla:

   $$
   \frac{dN}{dt} = r \, N(t) \left(1 - \frac{N(t)}{K}\right)
   $$

   donde $r > 0$ es la tasa intrínseca de contacto efectivo o de transmisión social.

3. **Puntos fijos y estabilidad:** los equilibrios se dan cuando la tasa de cambio se anula, $\frac{dN}{dt} = 0$:
   - $N^* = 0$: equilibrio **inestable**; basta un pequeño grupo semilla $N_0 > 0$ para desencadenar la epidemia de adopción.
   - $N^* = K$: equilibrio **estable**; saturación total de la sociedad.

4. **El punto de inflexión, $\frac{d^2N}{dt^2} = 0$:** derivando la tasa de cambio respecto al tiempo se demuestra que la velocidad máxima de contagio se alcanza exactamente en la mitad de la capacidad de carga:

   $$
   N(t_{\text{inflexión}}) = \frac{K}{2}
   $$

## 2. Código base de referencia (`laboratorio_semana5.jl`)

El script integra la ecuación logística por el método de Euler y dibuja el panel diagnóstico: la trayectoria y su derivada, lado a lado.

```julia
using CairoMakie, Somosaguas

# 1. Parámetros del modelo
r, K, N0 = 0.8, 1000.0, 10.0   # tasa de contagio, capacidad de carga y semilla en t = 0
T, dt = 15.0, 0.01             # horizonte temporal y paso de integración
t = 0:dt:T

# 2. Integración numérica por el método de Euler
f(N) = r * N * (1 - N / K)
N = zeros(length(t))
N[1] = N0
for k in 1:length(t)-1
    N[k+1] = N[k] + f(N[k]) * dt
end
dNdt = f.(N)
t_inflexion = t[argmax(dNdt)]

# 3. Panel diagnóstico: la trayectoria y su derivada, lado a lado
set_theme!(tema_somosaguas())
fig = Figure(size = (1400, 550))
ax1 = Axis(fig[1, 1]; title = "Trayectoria acumulada N(t)",
    xlabel = "Tiempo", ylabel = "Población de adoptantes")
lines!(ax1, t, N)
hlines!(ax1, [K, K / 2]; color = :gray, linestyle = :dash)
vlines!(ax1, [t_inflexion]; color = :gray, linestyle = :dot)
ax2 = Axis(fig[1, 2]; title = "Velocidad instantánea de cambio dN/dt",
    xlabel = "Tiempo", ylabel = "Nuevos adoptantes por unidad de tiempo")
lines!(ax2, t, dNdt)
vlines!(ax2, [t_inflexion]; color = :gray, linestyle = :dot)
resultados = mkpath(joinpath(@__DIR__, "resultados"))
save(joinpath(resultados, "difusion_logistica.png"), fig; px_per_unit = 1.5)
```

## 3. Ejercicios

### Ejercicio 1: inestabilidad y sensibilidad a la semilla inicial $N_0$

- **Tarea:** con $K = 1000$ y $r = 0.8$, simula el sistema para tres semillas iniciales, $N_0 \in \{1, 10, 100\}$.
- **Pregunta causal:** ¿cómo afecta el tamaño del núcleo inicial $N_0$ al tiempo necesario para alcanzar la velocidad máxima de difusión, $t_{\text{inflexión}}$? Demuestra analíticamente la relación logarítmica despejando $t$ de la solución exacta:

  $$
  N(t) = \frac{K}{1 + \left(\frac{K - N_0}{N_0}\right) e^{-rt}}
  $$

### Ejercicio 2: el modelo epidemiológico SIR de normas y creencias

Sustituye la ecuación logística por un sistema no lineal de tres ecuaciones diferenciales acopladas que modele la dinámica entre **susceptibles** ($S$), **infectados o creyentes** ($I$) y **recuperados o escépticos** ($R$):

$$
\begin{aligned}
\frac{dS}{dt} &= -\beta S I \\
\frac{dI}{dt} &= \beta S I - \gamma I \\
\frac{dR}{dt} &= \gamma I
\end{aligned}
$$

- **Tarea:** resuelve el sistema con el integrador de paso adaptativo `Tsit5()` de `OrdinaryDiffEqTsit5` (`solve(ODEProblem(f, u0, tspan), Tsit5())`), con condiciones iniciales $S(0) = 990$, $I(0) = 10$, $R(0) = 0$, $\beta = 0.001$ y una tasa de abandono o desilusión $\gamma = 0.2$.
- **Pregunta causal:** calcula el **número reproductivo básico**, $R_0 = \frac{\beta \, S(0)}{\gamma}$. ¿Qué condición debe cumplirse para que la creencia desencadene una epidemia social en lugar de extinguirse asintóticamente?

### Ejercicio 3: contrapeso informativo e inmunización de la población

Introduce un término de **inmunización o alfabetización crítica**, $v \, S(t)$: una proporción $v$ de susceptibles pasa por unidad de tiempo directamente a los escépticos, $R(t)$, sin haberse contagiado:

$$
\frac{dS}{dt} = -\beta S I - v S, \qquad \frac{dR}{dt} = \gamma I + v S
$$

- **Tarea:** simula el sistema con $v = 0.05$.
- **Pregunta causal:** ¿en qué porcentaje se reduce el pico de contagio, $I_{\text{máx}}$? Demuestra cómo la educación continua desplaza el umbral de inmunidad de rebaño.

## 4. Criterio de verificación por integración continua

La entrega es `semana-05/laboratorio_semana5.jl` en el repositorio de la asignatura. Con cada push, la integración continua ejecuta `semana-05/test_semana5.jl`, y el laboratorio se supera si el script:

1. Se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior.
2. Resuelve la logística por el método de Euler y el SIR del ejercicio 2 con el integrador de paso adaptativo, en una solución llamada `sir` que conserva la población, $S + I + R$.
3. Supera el test unitario `test_pico_inflexion`, que comprueba que el pico de la derivada de la logística se da cuando $N(t) \in [0.499 \, K, \; 0.501 \, K]$. El test lee `N`, `dNdt` y `K`: el script conserva esos nombres del código base.
4. Deja el panel de dos gráficos en PNG de al menos 2000 píxeles de ancho, en `semana-05/resultados/`.

Antes de enviarlo, el mismo test se pasa en la terminal:

```sh
julia --project=semana-05 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-05 --depwarn=yes semana-05/test_semana5.jl
```
