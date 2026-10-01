---
title: "Semana 5: Cálculo continuo, tasas de cambio y dinámica de contagio social"
date: 2027-07-26
weight: 5
---

**Módulo:** Cimientos formales y programación  
**Texto de referencia:** Gilbert Strang, *Calculus*; 3Blue1Brown, *The Essence of Calculus*  
**De ampliación:** Robert May, «Simple mathematical models with very complicated dynamics», *Nature*, 1976; Damon Centola, *How Behavior Spreads: The Science of Complex Contagions*, 2018  
**Herramientas:** Julia 1.11 o posterior, con `OrdinaryDiffEqTsit5` para el integrador de paso adaptativo; `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl`, sujeto a integración continua, y prueba de la pizarra (*Blackboard Defence*)


> [!nota] Lo que esta semana da por sabido
> - **De la [prueba de nivel](../../diagnostico/):** los problemas A4 (exponencial y logaritmo) y D1 y D4 (derivadas, y la logística como ecuación entre una función y su derivada).
> - **Nuevo para todos:** las ecuaciones diferenciales, sus puntos fijos y su estabilidad, el método de Euler y los sistemas acoplados como el SIR.
> - **Para repasar:** 3Blue1Brown, [la derivada](https://www.3blue1brown.com/lessons/derivatives) y la serie sobre [ecuaciones diferenciales](https://www.3blue1brown.com/topics/differential-equations); el [libro de cálculo de Strang](https://ocw.mit.edu/courses/res-18-001-calculus-fall-2023/), en abierto en el MIT OpenCourseWare.

## 1. Marco conceptual: la derivada como motor de la dinámica social

Si en la fase I representamos la estructura estática de la población con vectores de características en $\mathbb{R}^d$, en la semana 5 abordamos la **evolución temporal de los estados sociales** a través de sus **tasas instantáneas de cambio**, con **ecuaciones diferenciales ordinarias** (EDO): no cuánto ha cambiado algo entre dos observaciones, sino el mecanismo que genera el cambio en cada instante.

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

5. **El método de Euler.** Sin solución exacta, se avanza por la tangente: $N_{k+1} = N_k + f(N_k)\,\Delta t$. Su error global es de orden 1, proporcional a $\Delta t$; el integrador `Tsit5` del ejercicio 3, de orden 5, lo reduce como $\Delta t^5$ cuando el paso es pequeño (con los pasos del ejercicio 2, la pendiente pasa de 4.2 entre los dos más largos a 5.0 entre los dos más cortos, y la de todos juntos es 4.7). Y un paso demasiado largo no solo pierde precisión: puede inventar dinámicas que la ecuación no tiene, como muestra el ejercicio 2.

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

### Ejercicio 2: el error de Euler y el caos de May

- **Tarea:** con la solución exacta del ejercicio 1, mide el error máximo, $\max_k |N_k - N(t_k)|$, de Euler y de `Tsit5` a paso fijo (`solve(ODEProblem((N, p, t) -> f(N), N0, (0.0, T)), Tsit5(); dt, adaptive = false)`) para $\Delta t = 0.4, 0.2, 0.1, 0.05, 0.025$, y dibújalo frente a $\Delta t$ en escala logarítmica.
- **Pregunta causal:** ¿qué pendientes salen, y por qué? Compáralas con las de Gram-Schmidt en la semana 2.
- **Tarea:** sube el paso de Euler hasta $r\,\Delta t = 1.5, 2.1, 2.5, 2.56$ y $2.7$, integra unos miles de pasos y dibuja los cien últimos valores de $N$ frente a $r\,\Delta t$.
- **Pregunta causal:** demuestra que, con $x_k = \dfrac{r\,\Delta t}{(1 + r\,\Delta t)\,K}\,N_k$, Euler sobre la logística es el mapa logístico, $x_{k+1} = a\,x_k(1 - x_k)$ con $a = 1 + r\,\Delta t$. ¿A partir de qué $r\,\Delta t$ oscila la trayectoria, y hacia dónde se vuelve caótica (May, 1976)? ¿Tiene la ecuación diferencial alguna de esas dinámicas?

### Ejercicio 3: el modelo epidemiológico SIR de normas y creencias

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
- **En la pizarra:** $S + I + R$ se conserva hasta el redondeo, aunque `Tsit5` cometa errores en cada variable. ¿Por qué? Suma las tres ecuaciones y piensa en cómo combina un método de Runge-Kutta las derivadas de cada etapa.

### Ejercicio 4: contrapeso informativo e inmunización de la población

Introduce un término de **inmunización o alfabetización crítica**, $v \, S(t)$: una proporción $v$ de susceptibles pasa por unidad de tiempo directamente a los escépticos, $R(t)$, sin haberse contagiado:

$$
\frac{dS}{dt} = -\beta S I - v S, \qquad \frac{dR}{dt} = \gamma I + v S
$$

- **Tarea:** simula el sistema con $v = 0.05$.
- **Pregunta causal:** ¿en qué porcentaje se reduce el pico de contagio, $I_{\text{máx}}$? El umbral de inmunidad de grupo no cambia con $v$: depende solo de $\beta$ y $\gamma$. Comprueba que, con y sin inmunización, el pico llega cuando $S(t) = \gamma / \beta$, es decir, cuando el número reproductivo efectivo, $\beta S(t) / \gamma$, cae a 1. ¿Qué cambia entonces la inmunización, si no el umbral?

### Ejercicio 5: contagio simple y complejo, o dónde falla el SIR como modelo social

El SIR supone **contagio simple**: un solo contacto basta, y la población está perfectamente mezclada. Muchas normas y conductas se propagan por **contagio complejo**: hace falta la exposición a varias fuentes, y la estructura de la red importa (Centola y Macy, 2007; Centola, 2010). Los modelos de umbral de Granovetter (1978) son la alternativa clásica.

- **Tarea:** coloca a $n = 1000$ personas en un anillo, cada una unida a sus dos vecinos de cada lado, y recablea cada lazo con probabilidad $p$ hacia una persona al azar: son los lazos largos. Siembra la conducta en cuatro vecinos consecutivos y, en rondas sucesivas, haz que la adopte quien tenga al menos $\theta$ vecinos que ya la adoptaron. Compara $\theta = 1$, contagio simple, con $\theta = 2$, complejo, para $p \in \{0, 0.01, 0.05, 0.2\}$, con 30 redes por caso: cuántas rondas dura la difusión y qué proporción adopta al final.
- **Pregunta causal:** ¿qué hacen los lazos largos con cada tipo de contagio? Relaciónalo con «la fuerza de los lazos débiles» de Granovetter (1973). ¿Por qué ningún modelo de EDO bien mezclado, como el SIR, puede producir el resultado del contagio complejo, y qué supuesto habría que abandonar? Un modelo matemáticamente elegante puede ser un mal modelo de la conducta humana.

## 4. Criterio de verificación por integración continua

La entrega es `semana-05/laboratorio_semana5.jl` en el repositorio de la asignatura. Con cada push, la integración continua ejecuta `semana-05/test_semana5.jl`, y el laboratorio se supera si el script:

1. Se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior.
2. Resuelve la logística por el método de Euler y el SIR del ejercicio 3 con el integrador de paso adaptativo, en una solución llamada `sir` que conserva la población, $S + I + R$ (el porqué es la pregunta de la pizarra del ejercicio 3).
3. Supera el test unitario `test_pico_inflexion`, que comprueba que `N` es la trayectoria de Euler con los `r`, `K`, `N0` y `dt` del script, y que `t_inflexion` está a menos de $3\,\Delta t$ del instante exacto, $\ln\big((K - N_0)/N_0\big)/r$: Euler llega con un retraso de entre 1 y 2 pasos. El test lee `N`, `t`, `r`, `K`, `N0`, `dt` y `t_inflexion`: el script conserva esos nombres del código base.
4. Deja el panel de dos gráficos, `semana-05/resultados/difusion_logistica.png`, de al menos 2000 píxeles de ancho.

Antes de enviarlo, el mismo test se pasa en la terminal:

```sh
julia --project=semana-05 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-05 --depwarn=yes semana-05/test_semana5.jl
```
