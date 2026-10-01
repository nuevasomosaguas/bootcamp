---
title: "Semana 10: Fecundidad y reproducción: la ecuación de Euler-Lotka y el efecto tempo"
date: 2027-08-30
weight: 10
---

**Módulo:** Demografía matemática y replicación empírica  
**Lecturas imprescindibles:** Kenneth W. Wachter, *Essential Demographic Methods*, caps. 4, 6 y 10 (la fecundidad de las cohortes y la del periodo, y las estructuras por edad estables); John Bongaarts y Griffith Feeney, «On the Quantum and Tempo of Fertility», *Population and Development Review*, 1998  
**De ampliación:** Samuel H. Preston, Patrick Heuveline y Michel Guillot, *Demography*, caps. 5 y 7 (fecundidad y reproducción, y la población estable), como consulta; Hans-Peter Kohler y Dimiter Philipov, «Variance Effects in the Bongaarts-Feeney Formula», *Demography*, 2001, la crítica de la fórmula del ejercicio 2; Henri Leridon, «Can Assisted Reproduction Technology Compensate for the Natural Decline in Fertility with Age? A Model Assessment», *Human Reproduction*, 2004, para el ejercicio 4  
**Herramientas:** Julia 1.11 o posterior, con `LinearAlgebra` (biblioteca estándar); `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl`, sujeto a integración continua, y prueba de la pizarra (*Blackboard Defence*)

> [!nota] Lo que esta semana da por sabido
> - **De la [prueba de nivel](../../diagnostico/):** los problemas A1 y A4 (ecuaciones exponenciales y logaritmos), D1 (derivar un producto con una exponencial) y D3 (la integral como suma). De semanas anteriores, la tabla de vida de la semana 9, el método de Newton de la semana 7 y la distribución beta de la semana 6.
> - **Nuevo para todos:** las tasas de fecundidad por edad, el indicador coyuntural, la tasa neta de reproducción, la ecuación de renovación, la ecuación de Euler-Lotka, la longitud de una generación y el efecto tempo.
> - **Para repasar:** el método de Newton de la semana 7, ejercicio 3: esta semana se aplica a una ecuación en una sola incógnita, como allí el multiplicador de Lagrange.

## 1. Marco conceptual: cuántas hijas tiene una recién nacida

La semana 9 contó cuántos de cada 100 000 nacidos llegan a cada edad. Esta semana se cuentan los nacimientos que esos supervivientes producen, y de las dos cosas juntas sale el ritmo al que una población crecería, o menguaría, si mantuviera para siempre su mortalidad y su fecundidad.

1. **La fecundidad del periodo.** La tasa de fecundidad a la edad $x$ es $f_x = B_x / W_x$, los nacimientos de madres de $x$ años entre los años-persona vividos por las mujeres de esa edad, que se aproximan por la media de la población a 1 de enero de dos años consecutivos. Su suma es el **indicador coyuntural de fecundidad** (ISF), los hijos que tendría una mujer que viviera hasta los 50 años con las tasas de ese año:

   $$
   \text{ISF} = \sum_{x=15}^{49} f_x
   $$

   El ISF de España fue 1.10 en 2024, de los más bajos de la Unión Europea, y la edad media a la maternidad, 32.6 años.

2. **La tasa neta de reproducción.** Las hijas que tendrá, de media, una recién nacida, contando con que puede morir antes de tenerlas:

   $$
   R_0 = \sum_x \frac{L_x}{l_0}\, f_x\, \delta, \qquad \varphi_x = \frac{L_x}{l_0}\, f_x\, \delta
   $$

   donde $L_x / l_0$, de la tabla de vida femenina, son los años que vive con edad $x$ una recién nacida, y $\delta$, la proporción de niñas entre los nacimientos, en torno a 0.485. Con $R_0 < 1$, cada generación de mujeres es más pequeña que la de sus madres.

3. **La ecuación de renovación y la de Euler-Lotka.** Sea $B(t)$ el número de niñas que nacen en el instante $t$, $p(a)$ la probabilidad de sobrevivir hasta la edad $a$ y $m(a)$ la tasa de fecundidad en hijas. Las madres de los nacimientos de hoy nacieron hace $a$ años:

   $$
   B(t) = \int_0^\infty B(t - a)\, p(a)\, m(a)\, da
   $$

   Si los nacimientos crecen a un ritmo constante, $B(t) = B_0 e^{rt}$, al sustituir se cancela $B_0 e^{rt}$ y queda la **ecuación de Euler-Lotka**, con una sola incógnita, la **tasa intrínseca de crecimiento** $r$:

   $$
   1 = \int_0^\infty e^{-ra}\, p(a)\, m(a)\, da \qquad \approx \qquad 1 = \sum_x e^{-r(x + 1/2)}\, \varphi_x
   $$

   En la versión discreta, la integral de cada año de edad se aproxima por su valor en el punto medio. El lado derecho, $\psi(r) + 1$, es estrictamente decreciente en $r$, porque cada término lo es, y va de $+\infty$ a 0: la ecuación tiene una sola raíz real. Con $r = 0$ vale $R_0$, así que $r$ tiene el signo de $\log R_0$.

4. **La longitud de una generación.** El tiempo $T$ en el que la población se multiplica por $R_0$ a la tasa $r$: $e^{rT} = R_0$, es decir, $T = \log R_0 / r$. Queda cerca de la edad media a la maternidad de la cohorte, $\mu = \sum_x (x + 1/2)\,\varphi_x / R_0$, y por eso $r \approx \log R_0 / \mu$.

5. **El efecto tempo.** Si las mujeres retrasan la maternidad, los nacimientos que habrían tenido este año se aplazan al siguiente, y el ISF del periodo baja aunque cada mujer acabe teniendo los mismos hijos. Bongaarts y Feeney corrigen el ISF de cada orden de nacimiento $i$ —primer hijo, segundo, tercero, cuarto y siguientes— por el ritmo $c_i$ al que crece la edad media a la maternidad de ese orden, en años por año:

   $$
   \text{ISF}^* = \sum_i \frac{\text{ISF}_i}{1 - c_i}, \qquad c_i(t) = \frac{\bar{x}_i(t + 1) - \bar{x}_i(t - 1)}{2}
   $$

   El supuesto es fuerte: dentro de cada orden, el calendario entero se desplaza en bloque, a todas las edades por igual, y sin cambiar de forma.

## 2. Código base de referencia (`laboratorio_semana10.jl`)

**Los datos.** En `semana-10/datos/`, en el formato de las tablas del INE: `nacimientos.csv`, las filas del total nacional de la tabla [6508](https://www.ine.es/jaxiT3/Tabla.htm?t=6508) del Movimiento Natural de la Población, por sexo del nacido y edad de la madre, de 2015 a 2024, y `nacimientos_orden.csv`, las de la tabla [31949](https://www.ine.es/jaxiT3/Tabla.htm?t=31949), por edad de la madre y orden de nacimiento. La población y la tabla de vida femenina son las de la semana 9.

```julia
using LinearAlgebra, CairoMakie, Somosaguas

# 1. Los datos: la población y las tablas de mortalidad de la semana 9, y los nacimientos por
#    edad de la madre y por orden, en el formato del INE
datos9 = joinpath(@__DIR__, "..", "semana-09", "datos")
datos = joinpath(@__DIR__, "datos")
numero(s) = parse(Float64, replace(s, "." => "", "," => "."))
filas(archivo) = (split(l, ';') for l in Iterators.drop(eachline(archivo), 1))

function poblacion(sexo, año)
    p = zeros(101)
    for (edad, s, fecha, valor) in filas(joinpath(datos9, "poblacion.csv"))
        s == sexo && fecha == "1 de enero de $año" || continue
        if edad == "100 y más años"
            p[101] = numero(valor)
        elseif (m = match(r"^(\d+) años?$", edad)) !== nothing && parse(Int, m[1]) < 100
            p[parse(Int, m[1]) + 1] = numero(valor)
        end
    end
    return p
end

function tabla_ine(sexo, año, funcion)
    v = zeros(101)
    for (s, edad, f, periodo, valor) in filas(joinpath(datos9, "tablas_mortalidad.csv"))
        s == sexo && f == funcion && periodo == string(año) && (v[parse(Int, first(split(edad))) + 1] = numero(valor))
    end
    return v
end

# 2. Los nacimientos por edad de la madre, de 0 a 100 para casar con la población. Por
#    convención, los de madres de menos de 15 años se cuentan a los 15, y los de 50 y más, a los 49.
edad_madre(s) = s == "Menos de 15 años" ? 15 : s == "50 y más años" ? 49 : parse(Int, first(split(s)))
function nacimientos(año; sexo = "Total")
    b = zeros(101)
    for (_, s, edad, periodo, valor) in filas(joinpath(datos, "nacimientos.csv"))
        s == sexo && periodo == string(año) && edad != "Todas las edades" && (b[edad_madre(edad) + 1] += numero(valor))
    end
    return b
end
function nacimientos_orden(año, orden)
    b = zeros(101)
    for (_, edad, o, periodo, valor) in filas(joinpath(datos, "nacimientos_orden.csv"))
        o == orden && periodo == string(año) && edad != "Todas las edades" && (b[edad_madre(edad) + 1] += numero(valor))
    end
    return b
end

# 3. Las tasas de fecundidad por edad: los nacimientos entre los años-persona vividos por las
#    mujeres de cada edad, que se aproximan por la media de la población a 1 de enero de dos años
mujeres(año) = (poblacion("Mujeres", año) .+ poblacion("Mujeres", año + 1)) ./ 2
fecundidad(año) = nacimientos(año) ./ mujeres(año)
edades = 0:100
años = 2015:2024
isf = [sum(fecundidad(t)) for t in años]                  # el indicador coyuntural, hijos por mujer
edad_media = [sum((edades .+ 0.5) .* fecundidad(t)) / sum(fecundidad(t)) for t in años]

# 4. La figura: las tasas por edad en 2015 y en 2024
set_theme!(tema_somosaguas())
fig = Figure(size = (900, 550))
ax = Axis(fig[1, 1]; title = "La fecundidad baja en todas las edades menores de 40 años",
    xlabel = "Edad de la madre", ylabel = "Nacimientos por mujer y año")
for t in (2015, 2024)
    lines!(ax, 15:49, fecundidad(t)[16:50]; label = "$t, $(round(sum(fecundidad(t)); digits = 2)) hijos por mujer")
end
axislegend(ax; position = :rt)
resultados = mkpath(joinpath(@__DIR__, "resultados"))
save(joinpath(resultados, "fecundidad.png"), fig; px_per_unit = 1.5)
```

El ISF baja de 1.337 en 2015 a 1.105 en 2024, y la edad media a la maternidad sube de 31.89 a 32.61 años, aunque desde 2021 apenas se mueve. Quedan a menos de una centésima de los que publica el INE en sus [Indicadores Demográficos Básicos](https://www.ine.es/jaxiT3/Tabla.htm?t=1407), 1.33 y 1.10, que no se calculan exactamente así: esta semana no replica el ISF al decimal, sino que lo usa.

## 3. Ejercicios

### Ejercicio 1: la tasa intrínseca de crecimiento

- **Tarea:** calcula `δ`, la proporción de niñas entre los nacimientos de 2024; `φ`, el vector de $\varphi_x$ de 0 a 100 años con la tabla de vida femenina de 2024, y `R0`. Escribe `euler_lotka(φ)`, que resuelve $\sum_x e^{-r(x + 1/2)}\, \varphi_x = 1$ por el método de Newton desde $r = 0$, con la derivada calculada a mano, para un vector `φ` de cualquier longitud cuyo primer elemento es la edad 0. Guarda `r` y `T`. Deben salir $\delta = 0.4851$, $R_0 = 0.5326$, $r = -0.019142$ y $T = 32.91$ años.
- **Pregunta causal:** con $r = -0.0191$, ¿en cuántos años se reduciría a la mitad la población si mantuviera para siempre la mortalidad y la fecundidad de 2024, sin migración? Es el supuesto de población cerrada, y en España no se cumple: todo su crecimiento reciente viene de la inmigración, que la semana 11 añade a la proyección. Compara $r$ con $\log R_0 / \mu$, $-0.01932$, y explica por qué se parecen tanto con la aproximación de Coale, $T \approx \mu - r\sigma^2/2$, donde $\sigma^2 = \sum_x (x + 1/2 - \mu)^2\,\varphi_x / R_0$ es la varianza de la edad en $\varphi$: deben salir $\mu = 32.60$, $\sigma^2 = 32.6$ y $T \approx 32.913$, frente al 32.910 exacto. ¿Qué pesa más en $R_0$, la mortalidad o la fecundidad? Calcula el $R_0$ que habría con mortalidad nula antes de los 50 años y compáralo.
- **En la pizarra:** deduce la ecuación de Euler-Lotka a partir de la de renovación. Demuestra que tiene una sola raíz real, y por qué Newton converge desde $r = 0$: ¿qué signo tienen $\psi'$ y $\psi''$? Con $R_0 < 1$, como en 2024, $r = 0$ queda a la derecha de la raíz: ¿por qué el primer paso se pasa a la izquierda, a $-0.0269$, y desde ahí sube de forma monótona? ¿Y con $R_0 > 1$? ¿Qué devuelve tu función con un $\varphi$ todo cero, o con $R_0 = 0.001$, cuyo primer paso es $r \approx -30.6$, y dónde aparece el `NaN`? Deduce también la aproximación de Coale: desarrolla hasta el segundo orden en $r$ el logaritmo de $\sum_x e^{-r(x + 1/2)}\, \varphi_x / R_0 = 1/R_0$, y sale $\log R_0 \approx r\mu - r^2\sigma^2/2$.

### Ejercicio 2: el efecto tempo

- **Tarea:** escribe `bongaarts_feeney(año)`, que devuelve el $\text{ISF}^*$ de un año con cuatro órdenes: primero, segundo, tercero, y cuarto y siguientes juntos. La edad media a la maternidad de cada orden es $\bar{x}_i = \sum_x (x + 1/2)\, f_{x,i} / \text{ISF}_i$, con las tasas de cada orden calculadas sobre todas las mujeres de la edad, no solo sobre las que ya tienen los hijos anteriores. Guarda `isf_ajustado`, los valores de 2016 a 2023: 2015 y 2024 no tienen el año anterior y el siguiente que pide $c_i$.
- **Pregunta causal:** en 2016 y 2019, el ajuste sube el ISF en una décima, de 1.34 a 1.43 y de 1.24 a 1.33: la edad media al primer hijo crecía un año cada diez. En 2022 y 2023 no lo mueve, de 1.159 a 1.161 y de 1.121 a 1.121: la edad media al primer hijo se ha estancado en torno a 31.5 años. ¿Qué dice eso de la explicación de la baja fecundidad española por el aplazamiento? ¿Y qué pasa en 2020 y 2021, cuando el ajuste da 1.45 y 1.39? Busca en los nacimientos mensuales de 2021 la causa, y explica qué supuesto de Bongaarts y Feeney falla.
- **En la pizarra:** si todas las mujeres retrasan un mes cada año el nacimiento de su primer hijo, ¿cuánto baja el ISF del primer orden, aunque todas acaben teniéndolo? Deduce el factor $1 - c$.

### Ejercicio 3: la cohorte frente al periodo (sin entrega)

- **En la pizarra:** el ISF de 2024 es el de una mujer ficticia que tuviera a cada edad la fecundidad de 2024. Las mujeres nacidas en 1975 tuvieron sus hijos entre 1990 y 2025: ¿qué datos harían falta para calcular su descendencia final, y por qué puede ser mayor que cualquier ISF de esos años? La [Human Fertility Database](https://www.humanfertility.org/) la publica para España, con registro gratuito. ¿Qué es más útil para planificar las plazas escolares de 2030, el ISF o la descendencia final? ¿Y para saber si las mujeres españolas quieren menos hijos que sus madres?

### Ejercicio 4: el reloj biológico y la reproducción asistida (sin entrega)

El aplazamiento tiene un límite que no es social, sino biológico. Leridon simuló con Monte Carlo la reproducción de mujeres que empiezan a buscar un embarazo a distintas edades, con la probabilidad mensual de concebir, el riesgo de aborto espontáneo y el de esterilidad, que crecen con la edad. El 75 % de las que empiezan a los 30 años tiene en un año una concepción que acaba en un nacimiento; el 66 % a los 35 y el 44 % a los 40. En cuatro años, el 91 %, el 84 % y el 64 %. Y la reproducción asistida, con el éxito observado tras dos ciclos de fecundación *in vitro*, recupera solo la mitad de los nacimientos que se pierden al aplazar el primer intento de los 30 a los 35 años, y menos del 30 % de los que se pierden al aplazarlo de los 35 a los 40.

- **En la pizarra:** si cada mes la probabilidad de concebir fuera la misma, $p$, el tiempo hasta la concepción sería geométrico. ¿Qué $p$ da un 75 % en doce meses? Con ese $p$, ¿qué porcentaje habría en 48 meses? Sale el 99.6 %, no el 91 % de Leridon: ¿qué dos cosas del modelo de Leridon faltan? Si $p$ varía entre las parejas como una beta, la prior de la semana 6, la probabilidad de no haber concebido en $n$ meses es $B(\alpha, \beta + n)/B(\alpha, \beta)$: dedúcelo. Entre las parejas que siguen sin concebir tras $n$ meses, $p$ se distribuye como una $\text{Beta}(\alpha, \beta + n)$: es la posterior de la semana 6 con $k = 0$ éxitos en $n$ intentos, y su media, $\alpha/(\alpha + \beta + n)$, baja con $n$. ¿Por qué, entonces, la probabilidad mensual de las que no han concebido tras un año es menor que al principio, aunque la de cada pareja no cambie? Es la razón de que la fecundidad que se observa caiga con el tiempo de espera.

## 4. Criterio de verificación por integración continua

La entrega es `semana-10/laboratorio_semana10.jl` en el repositorio de la asignatura, que lee los datos de `semana-09/datos/` y `semana-10/datos/`. Con cada push, la integración continua ejecuta `semana-10/test_semana10.jl`, y el laboratorio se supera si el script:

1. Se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior y deja la figura en `semana-10/resultados/`.
2. Supera `test_fecundidad`: `fecundidad(2024)` e `isf` coinciden con las tasas que el test calcula por su cuenta de los archivos del INE.
3. Supera `test_euler_lotka`: `φ`, `R0`, `r` y `T` son los de 2024; `euler_lotka` da la raíz con un error menor que $10^{-12}$, también en problemas que el test elige y cuya raíz se conoce, como todas las hijas a los 30 años o $R_0 = 1$.
4. Supera `test_bongaarts_feeney`: `isf_ajustado` y `bongaarts_feeney` coinciden con un ajuste de referencia, con los cuatro órdenes del ejercicio 2.

Los tests leen `fecundidad`, `isf`, `φ`, `R0`, `r`, `T`, `euler_lotka`, `isf_ajustado` y `bongaarts_feeney`: el script conserva esos nombres. Antes de enviarlo, el mismo test se pasa en la terminal:

```sh
julia --project=semana-10 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-10 --depwarn=yes semana-10/test_semana10.jl
```
