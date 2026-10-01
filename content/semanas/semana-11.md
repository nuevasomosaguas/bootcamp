---
title: "Semana 11: Autovalores y la matriz de Leslie: la población estable, la inercia y la migración"
date: 2027-09-06
weight: 11
---

**Módulo:** Demografía matemática y replicación empírica  
**Lecturas imprescindibles:** Gilbert Strang, *Linear Algebra and Its Applications*, cap. 5 (autovalores y autovectores); Kenneth W. Wachter, *Essential Demographic Methods*, caps. 5, 10 y 11 (la proyección, las estructuras por edad estables y la migración)  
**De ampliación:** Hal Caswell, *Matrix Population Models* (Sinauer, 2.ª ed., 2001), la referencia sobre las matrices de proyección, con su análisis de sensibilidad; Samuel H. Preston, Patrick Heuveline y Michel Guillot, *Demography*, caps. 6 y 7 (la proyección y la población estable), como consulta; Nathan Keyfitz, «On the Momentum of Population Growth», *Demography*, 1971; Thomas J. Espenshade, Leon F. Bouvier y W. Brian Arthur, «Immigration and the Stable Population Model», *Demography*, 1982  
**Herramientas:** Julia 1.11 o posterior, con `LinearAlgebra` y `Downloads` (biblioteca estándar); `unzip`; `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl`, sujeto a integración continua, y prueba de la pizarra (*Blackboard Defence*)

> [!nota] Lo que esta semana da por sabido
> - **De la [prueba de nivel](../../diagnostico/):** los problemas C1 (el producto de matrices) y C3 (el determinante), y el bloque D (derivar). De semanas anteriores, la tabla de vida de la semana 9, la ecuación de Euler-Lotka de la semana 10, el número de condición de la semana 3 y los autovalores de la hessiana de la semana 7, que allí se usaron sin definirlos.
> - **Nuevo para todos:** los autovalores y autovectores, la diagonalización, el método de la potencia, el teorema de Perron-Frobenius, la matriz de Leslie, la población estable, el valor reproductivo, la sensibilidad de $\lambda$, la inercia demográfica y la proyección con migración.
> - **Para repasar:** Strang, *18.06*, lecciones [21, autovalores y autovectores](https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/resources/lecture-21-eigenvalues-and-eigenvectors/), y [22, diagonalización y potencias de $A$](https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/resources/lecture-22-diagonalization-and-powers-of-a/); 3Blue1Brown, [autovectores y autovalores](https://www.3blue1brown.com/lessons/eigenvalues).

## 1. Marco conceptual: lo que queda tras multiplicar muchas veces

La semana 7 usó los autovalores de la hessiana sin definirlos: decían cuánto se curvaba la función en cada dirección. Esta semana se definen, y se usan para lo que más sirven en demografía: saber qué le pasa a una población cuando la misma matriz la multiplica año tras año.

1. **Autovalores y autovectores.** Un vector $\mathbf{w} \neq \mathbf{0}$ es un autovector de una matriz cuadrada $A$ si $A\mathbf{w} = \lambda \mathbf{w}$: la matriz solo lo estira, por el autovalor $\lambda$, que puede ser complejo. Como $(A - \lambda I)\mathbf{w} = \mathbf{0}$ con $\mathbf{w} \neq \mathbf{0}$, la matriz $A - \lambda I$ no es invertible, y los autovalores son las raíces del **polinomio característico**, $\det(A - \lambda I) = 0$: es el espacio nulo de la semana 2. Un autovector **por la izquierda** cumple $\mathbf{v}^T A = \lambda \mathbf{v}^T$, y es un autovector de $A^T$ con el mismo autovalor.

2. **Las potencias de $A$.** Si $A$ tiene $n$ autovectores independientes, $A = W \Lambda W^{-1}$, con los autovectores en las columnas de $W$ y los autovalores en la diagonal de $\Lambda$, y entonces $A^t = W \Lambda^t W^{-1}$. Un vector inicial $\mathbf{n}_0 = \sum_i c_i \mathbf{w}_i$ evoluciona como

   $$
   A^t \mathbf{n}_0 = \sum_i c_i \lambda_i^t\, \mathbf{w}_i = \lambda_1^t \left( c_1 \mathbf{w}_1 + \sum_{i \ge 2} c_i \left(\frac{\lambda_i}{\lambda_1}\right)^t \mathbf{w}_i \right)
   $$

   Si $|\lambda_1| > |\lambda_i|$ para todo $i \ge 2$, los demás términos se apagan como $|\lambda_2/\lambda_1|^t$: la dirección de $A^t \mathbf{n}_0$ tiende a la de $\mathbf{w}_1$, y su tamaño crece o mengua como $\lambda_1^t$. El **método de la potencia** es exactamente esto: multiplicar por $A$ y normalizar, hasta que el vector deja de cambiar. Cuanto más cerca de 1 está $|\lambda_2/\lambda_1|$, más iteraciones hacen falta, unas $\log \varepsilon / \log |\lambda_2/\lambda_1|$ para un error $\varepsilon$, como el número de condición de la semana 3 decidía la precisión.

3. **El teorema de Perron-Frobenius.** Una matriz de elementos no negativos es **irreducible** si desde cada estado se llega a cualquier otro, y **primitiva** si además alguna potencia $A^k$ tiene todos los elementos positivos. Si $A$ es primitiva, tiene un autovalor real y positivo $\lambda_1$, simple, estrictamente mayor en módulo que todos los demás, con autovectores por la derecha y por la izquierda de elementos positivos. Es la garantía de que el método de la potencia converge, y de que la dirección a la que converge tiene sentido demográfico.

4. **La matriz de Leslie.** Con edades de un año, $\mathbf{n}(t + 1) = A\, \mathbf{n}(t)$, donde $\mathbf{n}(t)$ es la población femenina por edad a 1 de enero. La subdiagonal guarda las supervivencias de una edad a la siguiente, $s_x = L_{x+1}/L_x$, y la primera fila, las hijas nacidas en el año por mujer de edad $x$ que llegan vivas al 1 de enero:

   $$
   A_{1,x} = \frac{L_0}{2\,l_0} \left( f_x + s_x f_{x+1} \right) \delta
   $$

   una mujer de edad $x$ pasa medio año, de media, con la fecundidad de $x$ y medio con la de $x + 1$, si sobrevive. Las edades posteriores a la última fértil no tienen hijas, y desde ellas no se vuelve a ninguna otra: la matriz entera es **reducible**. El teorema se aplica al bloque de las edades de 0 a 49, que es primitivo porque hay hijas a edades consecutivas, y su $\lambda_1$ es el de la matriz entera.

5. **La ecuación característica es la de Euler-Lotka.** Si $A\mathbf{w} = \lambda \mathbf{w}$, la subdiagonal da $w_{x+1} = s_x w_x / \lambda$, es decir, $w_x = w_0\, \lambda^{-x} \prod_{y<x} s_y$, y la primera fila, $\lambda w_0 = \sum_x A_{1,x} w_x$:

   $$
   1 = \sum_x A_{1,x} \left(\prod_{y<x} s_y\right) \lambda^{-(x+1)}
   $$

   Con $\lambda = e^r$, es una versión discreta de la ecuación de la semana 10, y su raíz debe dar casi la misma $r$. La **estructura estable**, $\mathbf{w}$, es la población por edad a la que tiende cualquier población con esas tasas, y el autovector por la izquierda, $\mathbf{v}$, es el **valor reproductivo** de Fisher: cuántas hijas futuras, descontadas al ritmo $\lambda$, vale una mujer de cada edad. El cociente $\rho = \lambda_1 / |\lambda_2|$, el **amortiguamiento**, dice a qué velocidad se olvida la estructura inicial.

6. **La sensibilidad de $\lambda$.** Al derivar $A\mathbf{w} = \lambda \mathbf{w}$ respecto a un elemento $a_{ij}$ y multiplicar por $\mathbf{v}^T$ por la izquierda, los términos con $\partial \mathbf{w}$ se cancelan, porque $\mathbf{v}^T A = \lambda \mathbf{v}^T$, y queda

   $$
   \frac{\partial \lambda}{\partial a_{ij}} = \frac{v_i\, w_j}{\mathbf{v}^T \mathbf{w}}, \qquad e_{ij} = \frac{a_{ij}}{\lambda} \frac{\partial \lambda}{\partial a_{ij}}
   $$

   La **elasticidad** $e_{ij}$ es la sensibilidad proporcional: cuánto cambia $\lambda$, en porcentaje, si $a_{ij}$ cambia un 1 %. Las elasticidades suman 1.

7. **La migración.** España no es una población cerrada. Con un vector de migración neta por edad $\mathbf{m}$, la proyección es afín, $\mathbf{n}(t + 1) = A\,\mathbf{n}(t) + \mathbf{m}$. Si $\lambda_1 < 1$, la población no se extingue: tiende a la **población estacionaria** $\mathbf{n}^* = A\mathbf{n}^* + \mathbf{m}$, es decir,

   $$
   \mathbf{n}^* = (I - A)^{-1}\, \mathbf{m} = \sum_{k \ge 0} A^k\, \mathbf{m}
   $$

   la suma de los migrantes de todos los años anteriores, con lo que queda de cada cohorte. Espenshade, Bouvier y Arthur lo demostraron para cualquier población con fecundidad por debajo del reemplazo: la estructura final no depende de la de partida, solo de las tasas y de la migración.

## 2. Código base de referencia (`laboratorio_semana11.jl`)

El script construye la matriz de Leslie femenina de 2024 con los datos de las semanas 9 y 10 y proyecta sin migración, desde el 1 de enero de 2025, cincuenta años.

```julia
using LinearAlgebra, Downloads, CairoMakie, Somosaguas

# 1. Los datos de las semanas 9 y 10: la población a 1 de enero, la tabla de vida femenina,
#    los nacimientos por edad de la madre y sexo del nacido, y los microdatos de defunciones,
#    que se descargan si no están
datos9 = joinpath(@__DIR__, "..", "semana-09", "datos")
datos10 = joinpath(@__DIR__, "..", "semana-10", "datos")
zip_defunciones = joinpath(datos9, "datos_2024.zip")
isfile(zip_defunciones) ||
    Downloads.download("https://www.ine.es/ftp/microdatos/mnp_defun/datos_2024.zip", zip_defunciones)
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

edad_madre(s) = s == "Menos de 15 años" ? 15 : s == "50 y más años" ? 49 : parse(Int, first(split(s)))
function nacimientos(año; sexo = "Total")
    b = zeros(101)
    for (_, s, edad, periodo, valor) in filas(joinpath(datos10, "nacimientos.csv"))
        s == sexo && periodo == string(año) && edad != "Todas las edades" && (b[edad_madre(edad) + 1] += numero(valor))
    end
    return b
end

# 2. La matriz de Leslie femenina de 2024, con 101 grupos de edad: 0, …, 99 y 100 y más.
#    La subdiagonal, la supervivencia de una edad a la siguiente, sₓ = Lₓ₊₁/Lₓ; el grupo
#    abierto retiene a los suyos con la misma proporción que recibe a los de 99, T₁₀₀/T₉₉.
#    La primera fila, las hijas nacidas en el año por mujer de cada edad que sobreviven al
#    1 de enero: la media de la fecundidad de la edad x y de la x + 1, por la supervivencia
#    de las recién nacidas, L₀/2l₀.
L = tabla_ine("Mujeres", 2024, "Población estacionaria") ./ 100_000
Tv = tabla_ine("Mujeres", 2024, "Tiempo por vivir") ./ 100_000
f = nacimientos(2024) ./ ((poblacion("Mujeres", 2024) .+ poblacion("Mujeres", 2025)) ./ 2)
δ = sum(nacimientos(2024; sexo = "Mujeres")) / sum(nacimientos(2024))
s = [L[2:100] ./ L[1:99]; Tv[101] / Tv[100]]
A = zeros(101, 101)
for x in 0:99
    A[x + 2, x + 1] = s[x + 1]
    A[1, x + 1] = L[1] / 2 * (f[x + 1] + s[x + 1] * f[x + 2]) * δ
end
A[101, 101] = s[100]

# 3. La proyección sin migración desde el 1 de enero de 2025: n(t + 1) = A n(t)
n0 = poblacion("Mujeres", 2025)
proyeccion = [n0]
for t in 1:50
    push!(proyeccion, A * proyeccion[end])
end

# 4. La figura: la estructura por edad en 2025 y la proyectada para 2075
set_theme!(tema_somosaguas())
fig = Figure(size = (900, 550))
ax = Axis(fig[1, 1]; title = "Sin migración, la población femenina de 2075 sería un 41 % menor y más vieja",
    xlabel = "Edad", ylabel = "Mujeres (miles)")
lines!(ax, 0:100, n0 ./ 1000; label = "1 de enero de 2025")
lines!(ax, 0:100, proyeccion[end] ./ 1000; label = "2075, sin migración")
axislegend(ax; position = :lt)
resultados = mkpath(joinpath(@__DIR__, "resultados"))
save(joinpath(resultados, "proyeccion.png"), fig; px_per_unit = 1.5)
```

Sin migración, las 25.04 millones de mujeres de 2025 serían 14.74 millones en 2075, y las de 65 años o más pasarían del 22.9 % al 42.9 %. La proyección cerrada no es una predicción: es lo que dicen las tasas de 2024 si nadie entrara ni saliera, y el ejercicio 4 muestra por qué ese supuesto falla justo en España.

## 3. Ejercicios

### Ejercicio 1: el método de la potencia

- **Tarea:** escribe `metodo_potencia(A; tol = 1e-12)`, que parte de un vector uniforme, multiplica por `A` y normaliza para que sus elementos sumen 1, hasta que la norma 1 entre dos vectores seguidos es menor que `tol`. Devuelve `λ, w, iteraciones`. Aplícalo a la matriz de Leslie, y comprueba con `eigvals` el autovalor dominante: $\lambda = 0.981042$, y $\log \lambda = -0.019140$, frente a la $r = -0.019142$ de Euler-Lotka de la semana 10. Calcula `amortiguamiento`, $\rho = \lambda_1/|\lambda_2|$, con `eigvals`.
- **Pregunta causal:** el método necesita 1594 iteraciones. Con $\rho = 1.0157$, ¿cuántas predice la fórmula del punto 2? El segundo autovalor es complejo, $0.9495 - 0.1771i$: ¿qué periodo de oscilación da su argumento, en años, y con qué magnitud de la semana 10 se parece? ¿Cuántos años tarda en reducirse a la mitad la huella de la estructura inicial? Proyecta la estructura de 2025 y mira cuánto se parece a $\mathbf{w}$ en 2075 y en 2225.
- **En la pizarra:** con $A = \begin{bmatrix} 0 & 1.5 & 0.5 \\ 0.8 & 0 & 0 \\ 0 & 0.5 & 0 \end{bmatrix}$, calcula a mano el polinomio característico, $\lambda^3 - 1.2\lambda - 0.2$, comprueba que $\lambda = -1$ es una raíz y halla las otras dos. Deduce el autovector dominante por la derecha, $\mathbf{w} \propto (1,\; 0.8/\lambda,\; 0.4/\lambda^2)$, y por la izquierda, $\mathbf{v} \propto (1,\; \lambda/0.8,\; 0.5/\lambda)$. ¿Es primitiva la matriz? ¿Y si $a_{13}$ fuera 0?

### Ejercicio 2: el valor reproductivo y la sensibilidad

- **Tarea:** calcula `v`, el valor reproductivo, con `metodo_potencia` sobre `Matrix(A')`, normalizado para que `v[1] == 1`. Escribe `sensibilidad(A, v, w)`, que devuelve la matriz de las $\partial\lambda/\partial a_{ij}$, y guarda `S` y `E`, la de las elasticidades.
- **Pregunta causal:** en los manuales, el valor reproductivo crece desde el nacimiento hasta el comienzo de la edad fértil y después baja. En España, con las tasas de 2024, es máximo al nacer y baja desde ahí: 0.75 a los 15 años, 0.56 a los 25 y 0.40 a los 30. ¿Por qué? Piensa en qué hace el descuento $\lambda^{-t}$ cuando $\lambda < 1$, y en lo poco que le queda por delante a una mujer de 30 años con un ISF de 1.1. La mayor sensibilidad de $\lambda$ a una supervivencia es la del primer año de vida. ¿Y a una fecundidad? Sale a los 78 años: ¿por qué es una pregunta sin sentido, y por qué la elasticidad no tiene ese problema? Las elasticidades de la fecundidad suman 0.0301: compara su inverso, 33.2, con la edad media de las madres en la población estable.
- **En la pizarra:** deduce la fórmula de la sensibilidad derivando $A\mathbf{w} = \lambda \mathbf{w}$. ¿Por qué todas las supervivencias anteriores a los 15 años tienen la misma elasticidad?

### Ejercicio 3: la inercia demográfica

- **Tarea:** construye `A1`, la matriz con la fecundidad dividida por $R_0$, y comprueba que su autovalor dominante es exactamente 1: demuestra en la pizarra por qué, con la ecuación característica del punto 5. Escribe `inercia(A1, n0)`, que devuelve el cociente entre la población a la que tiende `n0` con `A1` y la población inicial, sin proyectar: con $\lambda = 1$, el límite de $A_1^t \mathbf{n}_0$ es $\mathbf{w}\,(\mathbf{v}^T \mathbf{n}_0)/(\mathbf{v}^T \mathbf{w})$. Guarda `M`, la inercia de la población femenina de 2025: 0.830.
- **Pregunta causal:** si la fecundidad subiera de golpe al reemplazo en 2025 y no hubiera migración, la población femenina aún bajaría un 17 %. ¿Por qué? Para la población estable de 2024, la inercia exacta es 0.5334, y la fórmula de Keyfitz, $M = \frac{b\, e_0}{r\, \mu} \cdot \frac{R_0 - 1}{R_0}$, con la tasa bruta de natalidad de la población estable, $b = 1 / \sum_x e^{-r(x + 1/2)} L_x / l_0$, y la edad media a la maternidad $\mu$ de la semana 10, da 0.5334 también: compruébalo. ¿Por qué la población real tiene mucha menos inercia que la estable, 0.83 frente a 0.53? Compara cuántas mujeres de menos de 30 años tiene cada una.

### Ejercicio 4: la migración

- **Tarea:** calcula `m`, la migración neta femenina de 2024 por edad al final del año, por el **método residual**: lo que la población del 1 de enero de 2025 tiene de más o de menos respecto a la del 1 de enero de 2024 envejecida un año y descontadas las muertes de cada generación. Para la generación nacida en el año $g$, con $x = 2024 - g - 1$ años el 1 de enero de 2024,

  $$
  m_{x+1} = P_{2025,\,x+1} - P_{2024,\,x} + D_{2024}(g)
  $$

  donde $D_{2024}(g)$ son las mujeres residentes nacidas en $g$ fallecidas en 2024, que salen de los microdatos de la semana 9 por el año de nacimiento: el paralelogramo del diagrama de Lexis. Las nacidas en 2024 dan $m_0$, con los nacimientos de niñas en lugar de $P_{2024}$, y el grupo abierto reúne a las de 99 y más. Escribe `poblacion_estacionaria(A, m)`, que resuelve $(I - A)\,\mathbf{n} = \mathbf{m}$ con `\`. Deben salir 305 948 migrantes netas, y una población estacionaria de 35.24 millones de mujeres.
- **Pregunta causal:** casi la mitad de las migrantes netas tiene entre 20 y 39 años. Con la migración de 2024 repetida cada año, la población femenina no menguaría: tendería a 35.24 millones. Pero las de 65 años o más serían el 32.4 %, frente al 22.9 % de 2025: ¿por qué la migración frena la caída de la población y no su envejecimiento? Es la conclusión del informe de Naciones Unidas sobre la migración de reemplazo, de 2000. ¿Qué supuesto de la proyección es el más frágil: la fecundidad, la mortalidad o la migración constante?
- **En la pizarra:** demuestra que $\sum_{k \ge 0} A^k$ converge a $(I - A)^{-1}$ si todos los autovalores de $A$ tienen módulo menor que 1. ¿Qué le pasaría a la proyección con migración si $\lambda_1 > 1$?

## 4. Criterio de verificación por integración continua

La entrega es `semana-11/laboratorio_semana11.jl` en el repositorio de la asignatura, que lee los datos de las semanas 9 y 10. Con cada push, la integración continua ejecuta `semana-11/test_semana11.jl`, y el laboratorio se supera si el script:

1. Se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior y deja la figura en `semana-11/resultados/`.
2. Supera `test_leslie`: `A` es la matriz de Leslie que el test construye por su cuenta, y el logaritmo de su autovalor dominante queda a menos de $10^{-5}$ de la $r$ de Euler-Lotka.
3. Supera `test_potencia`: `metodo_potencia` da el autovalor dominante y un autovector positivo que suma 1, de la matriz de Leslie y de otra matriz que el test elige; `amortiguamiento` es $\lambda_1 / |\lambda_2|$.
4. Supera `test_sensibilidad`: `v` es el autovector por la izquierda con `v[1] == 1`; `S` coincide con las diferencias finitas de $\lambda$ en varios elementos, y las elasticidades `E` suman 1.
5. Supera `test_inercia`: `inercia` y `M` coinciden con la proyección de 3000 años con la fecundidad de reemplazo, también desde otra población inicial.
6. Supera `test_migracion`: `m` es la migración residual que el test calcula de los microdatos, y `poblacion_estacionaria` cumple $\mathbf{n} = A\mathbf{n} + \mathbf{m}$.

Los tests leen `A`, `metodo_potencia`, `amortiguamiento`, `λ`, `w`, `v`, `sensibilidad`, `S`, `E`, `inercia`, `M`, `m` y `poblacion_estacionaria`: el script conserva esos nombres. Antes de enviarlo, el mismo test se pasa en la terminal:

```sh
julia --project=semana-11 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-11 --depwarn=yes semana-11/test_semana11.jl
```
