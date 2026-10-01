---
title: "Semana 9: La tabla de vida: replicar al INE con los microdatos de defunciones"
date: 2027-08-23
weight: 9
---

**Módulo:** Demografía matemática y replicación empírica  
**Lecturas imprescindibles:** Kenneth W. Wachter, *Essential Demographic Methods*, caps. 2, 3 y 7 (periodos y cohortes, la mortalidad de las cohortes y la del periodo); INE, [*Tablas de mortalidad. Metodología*](https://www.ine.es/metodologia/t20/t2020319a.pdf) (noviembre de 2023), doce páginas que son la especificación de lo que se replica  
**De ampliación:** Samuel H. Preston, Patrick Heuveline y Michel Guillot, *Demography: Measuring and Modeling Population Processes*, cap. 3 (la tabla de vida), como consulta; Eduardo E. Arriaga, «Measuring and Explaining the Change in Life Expectancies», *Demography*, 1984, el artículo de la descomposición del ejercicio 2; Joshua R. Goldstein y Ronald D. Lee, «Demographic Perspectives on the Mortality of COVID-19 and Other Epidemics», *PNAS*, 2020, para el ejercicio 4  
**Herramientas:** Julia 1.11 o posterior, con `Downloads`, `TOML` y `SHA` (biblioteca estándar); `unzip`; [Typst](https://typst.app/docs/) 0.15; `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl` y de una ficha en Typst, sujetos a integración continua, y prueba de la pizarra (*Blackboard Defence*)

> [!nota] Lo que esta semana da por sabido
> - **De la [prueba de nivel](../../diagnostico/):** el bloque A (exponenciales, logaritmos y sumatorios) y el problema E1 (la probabilidad condicionada). De semanas anteriores, contar registros por clave, de la semana 8, y la probabilidad de la semana 6.
> - **Nuevo para todos:** la tabla de vida, el diagrama de Lexis, la exposición al riesgo, la esperanza de vida temporal, la descomposición de Arriaga y Typst.
> - **Para repasar:** la probabilidad condicionada y la regla del producto, en el capítulo 2 de Blitzstein y Hwang, y el [tutorial de Typst](https://typst.app/docs/tutorial/), una hora.

## 1. Marco conceptual: una cohorte que no existe

Las semanas 9 a 12 son un solo proyecto de replicación. Cada semana construye una pieza con datos reales de España —la tabla de vida, la fecundidad, la matriz de Leslie— y la semana 12 las reúne para una comunidad autónoma, con un informe en Typst. La regla es la del programa: se reconstruye de forma exacta un resultado publicado, y el resultado publicado es el test. Esta semana, la tabla de mortalidad de España de 2024 del INE.

1. **La tabla de vida de periodo.** Somete a una cohorte ficticia de $l_0 = 100\,000$ nacidos a la mortalidad por edad de un solo año. Con edades enteras $x$, la tasa $m_x$ es el cociente entre las defunciones con $x$ años cumplidos y los años-persona vividos con esa edad; $q_x$, la probabilidad de morir antes de cumplir $x + 1$ sabiendo que se ha llegado a $x$, una probabilidad condicionada; y $a_x$, los años que vive, de media, en ese último año quien muere con edad $x$. Las demás funciones salen de ellas:

   $$
   l_{x+1} = l_x (1 - q_x), \qquad d_x = l_x q_x, \qquad L_x = l_x - d_x + a_x d_x, \qquad T_x = \sum_{y \ge x} L_y, \qquad e_x = \frac{T_x}{l_x}
   $$

   Por la regla del producto, $l_x / l_0 = \prod_{y < x} (1 - q_y)$ es la probabilidad de llegar con vida a la edad $x$. La relación entre la tasa y la probabilidad se deduce de $d_x = m_x L_x$:

   $$
   q_x = \frac{m_x}{1 + (1 - a_x)\, m_x}
   $$

2. **La esperanza de vida temporal.** Los años que vive, de media, entre las edades $x$ y $x + n$ quien llega a $x$:

   $$
   e_{x:\overline{n}|} = \frac{T_x - T_{x+n}}{l_x}
   $$

   Con $x = 0$ y $n = 65$, cuánto de la vida antes de la jubilación se pierde por la mortalidad; si nadie muriera antes, valdría 65.

3. **El diagrama de Lexis y la exposición.** En un diagrama con el tiempo en abscisas y la edad en ordenadas, cada vida es una diagonal. Los fallecidos en el año $t$ con edad $x$ son de dos generaciones: la de $t - x$, que cumple $x$ años durante $t$ y muere después de cumplirlos (el triángulo inferior, $D_1$), y la de $t - x - 1$, que tenía $x$ años el 1 de enero y muere antes de cumplir $x + 1$ (el superior, $D_2$). Si los cumpleaños de los supervivientes se reparten de manera uniforme a lo largo del año, el INE estima la exposición, los años-persona vividos con edad $x$ durante $t$, como

   $$
   m_x = \frac{D_x}{\dfrac{P_{t,x} - D_{2,x}}{2} + \displaystyle\sum_{i \in D_2} b_{2,i} + \dfrac{P_{t+1,x}}{2} + \sum_{i \in D_1} b_{1,i}}
   $$

   donde $P_{t,x}$ es la población con $x$ años el 1 de enero de $t$, $b_{2,i}$ es lo que vivió en el año el fallecido $i$ del triángulo superior, desde el 1 de enero hasta su muerte, y $b_{1,i}$, lo que vivió el del inferior desde su cumpleaños hasta su muerte. Los supervivientes de la generación $t - x - 1$ viven, de media, medio año con edad $x$, y los de la generación $t - x$, que siguen con edad $x$ el 1 de enero de $t + 1$, otro medio. La aproximación de los manuales, $D_x / \tfrac{1}{2}(P_{t,x} + P_{t+1,x})$, olvida lo que vivieron los fallecidos.

4. **El grupo abierto.** La última edad, 100 y más años, cierra la tabla: $q_{100+} = 1$ y $L_{100+} = a_{100+}\, l_{100+}$. Hasta 2015, el INE tomaba $a_{100+} = 1/m_{100+}$, lo que vale en una población estacionaria; desde entonces, $a_{100+}$ es la media observada de los años vividos después de los 100 por quienes mueren con 100 o más, y $e_{100+} = a_{100+}$.

5. **La descomposición de Arriaga.** Entre dos tablas, la diferencia de esperanza de vida al nacer se reparte exactamente entre las edades. La contribución de la edad $x < \omega$, con $\omega$ el grupo abierto, es

   $$
   \Delta_x = \underbrace{\frac{l_x^1}{l_0}\left(\frac{L_x^2}{l_x^2} - \frac{L_x^1}{l_x^1}\right)}_{\text{efecto directo}} + \underbrace{\frac{T_{x+1}^2}{l_0}\left(\frac{l_x^1}{l_x^2} - \frac{l_{x+1}^1}{l_{x+1}^2}\right)}_{\text{efecto indirecto}}, \qquad \Delta_\omega = \frac{l_\omega^1}{l_0}\left(\frac{T_\omega^2}{l_\omega^2} - \frac{T_\omega^1}{l_\omega^1}\right)
   $$

   El efecto directo son los años que se ganan o pierden dentro de la edad $x$; el indirecto, los que viven después quienes ahora sobreviven a $x$, o dejan de vivir quienes ya no sobreviven. Los términos se cancelan en cadena, y $\sum_x \Delta_x = e_0^2 - e_0^1$ sin aproximación.

6. **Typst.** Un lenguaje de marcas para documentos científicos, con las fórmulas de LaTeX y una sintaxis más corta, que compila en un segundo. Lee datos con `toml()`, `csv()` o `json()`: el script de Julia deja los resultados en `resultados/` y el documento los lee, de modo que ningún número del informe se copia a mano. Es el formato del informe de la semana 12, y esta semana empieza con una ficha de una página.

## 2. Código base de referencia (`laboratorio_semana9.jl`)

**Los datos.** Tres archivos. Los dos primeros están en `semana-09/datos/`, en el formato de las tablas del INE (separados por `;`, con punto de millares y coma decimal): `poblacion.csv`, las filas de la tabla [56934](https://www.ine.es/jaxiT3/Tabla.htm?t=56934) de la Estadística Continua de Población a 1 de enero de 2015 a 2025, y `tablas_mortalidad.csv`, las de la tabla [27153](https://www.ine.es/jaxiT3/Tabla.htm?t=27153) de 2019, 2020 y 2024. El tercero son los [microdatos de defunciones de 2024](https://www.ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736177008&menu=resultados&idp=1254735573002), una fila por fallecido, con el mes y el año de nacimiento y de defunción pero sin el día, que el INE suprime por el secreto estadístico. Su zip, `datos_2024.zip` (28 MB), no entra en el repositorio: el script lo descarga la primera vez, y el test comprueba su suma SHA-256, `33682a2f2965f72863ff1a899fe98e747f828862eed17146aea0f8e6ced3d3c1`. Las semanas 11 y 12 lo vuelven a usar.

El script lee las tres fuentes, define la tabla de vida y construye la tabla ingenua: todas las defunciones del archivo, la población media del año como exposición, $a_x = 1/2$ y el cierre anterior a 2015.

```julia
using LinearAlgebra, Downloads, TOML, CairoMakie, Somosaguas

# 1. Los microdatos de defunciones de 2024 del INE, una fila por fallecido. El zip no entra en
#    el repositorio: se descarga la primera vez.
datos = joinpath(@__DIR__, "datos")
zip_defunciones = joinpath(datos, "datos_2024.zip")
isfile(zip_defunciones) ||
    Downloads.download("https://www.ine.es/ftp/microdatos/mnp_defun/datos_2024.zip", zip_defunciones)

# 2. Los números del INE llevan punto de millares y coma decimal: 1.603.077 y 84,009718
numero(s) = parse(Float64, replace(s, "." => "", "," => "."))

# 3. La población a 1 de enero por edad simple: 0, …, 99 y el grupo abierto de 100 y más.
#    El archivo mezcla edades simples con agregados («85 y más años», «100 y más años»):
#    se toman las simples hasta 99 y el agregado de 100 y más.
function poblacion(sexo, año)
    p = zeros(101)
    for linea in Iterators.drop(eachline(joinpath(datos, "poblacion.csv")), 1)
        edad, s, fecha, valor = split(linea, ';')
        s == sexo && fecha == "1 de enero de $año" || continue
        if edad == "100 y más años"
            p[101] = numero(valor)
        elseif (m = match(r"^(\d+) años?$", edad)) !== nothing && parse(Int, m[1]) < 100
            p[parse(Int, m[1]) + 1] = numero(valor)
        end
    end
    return p
end

# 4. Las tablas de mortalidad publicadas por el INE: una función por edad, de 0 a 100 y más
function tabla_ine(sexo, año, funcion)
    v = zeros(101)
    for linea in Iterators.drop(eachline(joinpath(datos, "tablas_mortalidad.csv")), 1)
        s, edad, f, periodo, valor = split(linea, ';')
        s == sexo && f == funcion && periodo == string(año) || continue
        v[parse(Int, first(split(edad))) + 1] = numero(valor)
    end
    return v
end

# 5. Las defunciones, leídas del CSV del zip, separado por tabuladores: columnas 3 a 6, el mes
#    y el año de nacimiento, el sexo y el mes de la defunción; 14, el lugar de residencia
#    (1, España); 15, la provincia de residencia, y 20, la edad en años cumplidos.
defunciones = map(Iterators.drop(eachline(`unzip -p $zip_defunciones CSV/MNPdefun_2024.tab`), 1)) do linea
    c = split(linea, '\t')
    (mes_nacimiento = parse(Int, c[3]), año_nacimiento = parse(Int, c[4]),
     sexo = c[5] == "6" ? "Mujeres" : "Hombres", mes_defuncion = parse(Int, c[6]),
     residente = c[14] == "1", provincia = String(c[15]), edad = parse(Int, c[20]))
end

# 6. La tabla de vida a partir de las tasas mₓ y de los años vividos por quienes mueren, aₓ.
#    La última edad es el grupo abierto: todos mueren en él, q = 1.
function tabla_vida(m, a; l0 = 100_000)
    q = m ./ (1 .+ (1 .- a) .* m)
    q[end] = 1
    l = l0 .* [1; cumprod(1 .- q[1:end-1])]
    d = l .* q
    L = l .- d .+ a .* d
    T = reverse(cumsum(reverse(L)))
    return (; m, a, q, l, d, L, T, e = T ./ l)
end

# 7. La tabla ingenua: todas las defunciones por edad, la población media del año como
#    exposición, a = 1/2 y, en el grupo abierto, a = 1/m
D = zeros(101)
for r in defunciones
    D[min(r.edad, 100) + 1] += 1
end
P0, P1 = poblacion("Total", 2024), poblacion("Total", 2025)
m_ingenua = D ./ ((P0 .+ P1) ./ 2)
a_ingenua = [fill(0.5, 100); 1 / m_ingenua[end]]
ingenua = tabla_vida(m_ingenua, a_ingenua)
e0_ine = tabla_ine("Ambos sexos", 2024, "Esperanza de vida")[1]

# 8. La figura: las tasas por edad, en escala logarítmica, frente a las del INE
set_theme!(tema_somosaguas())
fig = Figure(size = (900, 550))
ax = Axis(fig[1, 1]; yscale = log10,
    title = "La mortalidad crece de forma exponencial con la edad a partir de los 30 años",
    xlabel = "Edad", ylabel = "Tasa de mortalidad, mₓ")
edades = 0:100
lines!(ax, edades, tabla_ine("Ambos sexos", 2024, "Tasa de mortalidad") ./ 1000; label = "INE")
scatter!(ax, edades, m_ingenua; markersize = 5, label = "Tabla ingenua")
axislegend(ax; position = :lt)
resultados = mkpath(joinpath(@__DIR__, "resultados"))
save(joinpath(resultados, "mortalidad.png"), fig; px_per_unit = 1.5)
```

El archivo trae 436 118 defunciones. La tabla ingenua da $e_0 = 83.880$; el INE publica 84.010. En la figura apenas se distinguen, y sin embargo la diferencia, 0.13 años, es más de la mitad de lo que ganó la esperanza de vida de España entre 2023 y 2024, 0.24. El INE publica las tasas por mil: de ahí el `./ 1000`.

## 3. Ejercicios

### Ejercicio 1: la exposición de Lexis

- **Tarea:** escribe `tasas_lexis(registros, P0, P1, año)`, que devuelve `m, a`, los dos vectores de la fórmula del punto 3, con el grupo abierto en la última edad, $w = $ `length(P0) - 1`. Como los microdatos no traen el día, aproxima las fechas por meses: $b_1 = (\text{mes de defunción} - \text{mes de nacimiento})/12$ si el fallecido murió en un mes posterior al de su cumpleaños, y $1/36$ si murió el mismo mes; $b_2 = (\text{mes de defunción} - \tfrac{1}{2})/12$. Los años vividos desde el último cumpleaños dan $a_x$: $b_1$ en el triángulo inferior, y $1 - (\text{mes de nacimiento} - \text{mes de defunción})/12$ en el superior, o $1 - 1/36$ si coinciden los meses. En el grupo abierto se suman además los años por encima de $w$, $x - w$, y el triángulo inferior es solo el de quienes cumplen $w$ años durante el año: los que ya tenían $w$ o más el 1 de enero son del superior aunque cumplan años, porque ya estaban en el grupo. Una edad sin defunciones toma $a_x = 1/2$. Con ella, construye `residentes`, las defunciones de residentes en España; `replicada`, la tabla de ambos sexos, y `por_sexo`, un diccionario `"Hombres" => tabla, "Mujeres" => tabla`. Debe salir $e_0 = 84.0096$, frente al 84.0097 del INE; 81.3847 y 86.5282 para hombres y mujeres, frente a 81.3848 y 86.5284.
- **Pregunta causal:** la tabla ingenua se separa del INE 0.13 años por cuatro decisiones. Cámbialas de una en una sobre `replicada` y mide cuánto mueve cada una $e_0$: contar a los no residentes (debe dar 83.902), la población media como exposición (83.977), $a_x = 1/2$ en todas las edades salvo el cierre (84.010) y el cierre con $a_{100+} = 1/m_{100+}$ (84.019). ¿Cuál pesa más? Los 2807 fallecidos no residentes son el 0.6 % del total, y bajan $e_0$ más de lo que esa proporción sugiere: compara su edad con la de los residentes. ¿Quiénes son, y por qué su muerte no tiene exposición en el denominador?
- **En la pizarra:** deduce $q_x = m_x / (1 + (1 - a_x)\,m_x)$ y la exposición de Lexis, con el diagrama dibujado. ¿Por qué $1/36$ de año cuando el cumpleaños y la muerte caen en el mismo mes? Si se olvida la regla de los triángulos del grupo abierto, $m_{100+}$ se separa un 2 % del del INE y $e_0$ no se mueve: ¿por qué, desde 2015, la tasa del grupo abierto no interviene en la esperanza de vida?

### Ejercicio 2: la esperanza de vida temporal y la caída de 2020

- **Tarea:** escribe `esperanza_temporal(t, x, n)`, que devuelve $e_{x:\overline{n}|}$ de una tabla `t` con campos `l` y `T`, y `arriaga(t1, t2)`, que devuelve el vector de las contribuciones $\Delta_x$ de cada edad, de 0 al grupo abierto, con tablas que tengan los campos `l`, `L` y `T`. Aplícala a las tablas de 2019 y 2020 que publica el INE: la esperanza de vida cayó 1.250 años, y las contribuciones deben sumar eso mismo. Agrúpalas: de 0 a 14 años, $+0.016$; de 15 a 44, $-0.057$; de 45 a 64, $-0.144$; de 65 a 74, $-0.254$; de 75 a 84, $-0.432$, y de 85 en adelante, $-0.378$.
- **Pregunta causal:** las edades de 65 en adelante explican el 85 % de la caída. Calcula $e_{0:\overline{65}|}$ en los dos años (63.90 y 63.84) y $e_{65}$ (21.52 y 20.35): ¿qué mide cada una, y por qué la primera apenas se mueve? ¿Por qué la contribución de los niños es positiva? Descompón también la diferencia entre mujeres y hombres en 2024, 5.14 años: ¿qué edades la explican?
- **En la pizarra:** demuestra que $\sum_x \Delta_x = e_0^2 - e_0^1$. Sustituye $\Delta_x$, separa los dos efectos y observa qué términos se cancelan en cadena.

### Ejercicio 3: la ficha de replicación en Typst

- **Tarea:** al final del script, escribe con `TOML.print` el archivo `resultados/semana9.toml`, con tu $e_0$ y la del INE, de ambos sexos, de los hombres y de las mujeres. Escribe después `semana-09/ficha.typ`: una página con un título, una frase que diga qué se replica, una tabla con las tres esperanzas de vida replicadas, las del INE y su diferencia, y la figura. El documento lee los números con `toml()` y no copia ninguno a mano. Empieza así, y complétalo con el [tutorial](https://typst.app/docs/tutorial/):

  ```typst
  #set page(paper: "a4", margin: 2cm)
  #set text(lang: "es", size: 11pt)
  #let r = toml("resultados/semana9.toml").e0
  #let f(x) = str(calc.round(x, digits: 4))

  = Tabla de mortalidad de España, 2024
  ```

  Compílalo desde `semana-09/` con `typst compile ficha.typ`, que deja `ficha.pdf`.
- **Pregunta causal:** si el INE revisara la población de 2025 y cambiaras el CSV, ¿qué tendrías que tocar para que la ficha diga la verdad? ¿Y si los números estuvieran escritos a mano en la ficha?

### Ejercicio 4: periodo y cohorte (sin entrega)

- **En la pizarra:** la esperanza de vida al nacer de 2020, 82.28 años, no es lo que vivirá de media nadie nacido en 2020: ¿por qué? ¿Qué mide entonces? Wachter (cap. 2) distingue el periodo de la cohorte, y el diagrama de Lexis lo dibuja: ¿qué recorre la tabla de periodo, y qué recorrería una de cohorte? Goldstein y Lee calcularon, para un escenario de un millón de muertes por covid en Estados Unidos, que cada fallecido perdería de media 11.7 años de vida y que la esperanza de vida de periodo de 2020 caería 2.9 años, mientras que la vida que le queda por delante a una persona cualquiera apenas cambiaría. Si la esperanza de vida de España cayó 1.25 años, ¿quiere decir que cada español perdió 1.25 años de vida? ¿Qué pasaría con la $e_0$ de 2021 si la mortalidad volviera a la de 2019, y qué dice eso de lo que mide?

## 4. Criterio de verificación por integración continua

La entrega es `semana-09/laboratorio_semana9.jl` y `semana-09/ficha.typ` en el repositorio de la asignatura. Con cada push, la integración continua ejecuta `semana-09/test_semana9.jl`, y la semana se supera si:

1. El script se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior y deja la figura en `semana-09/resultados/`.
2. El zip de los microdatos tiene la suma SHA-256 de la sección 2, y `.gitignore` lo excluye del repositorio.
3. Supera `test_tabla_vida`: con las tasas y los $a_x$ del INE, `tabla_vida` reproduce la esperanza de vida publicada en todas las edades, de 2019 y de 2024.
4. Supera `test_lexis`: `residentes` son todas las defunciones de residentes, y solo ellas; `replicada` y `por_sexo` quedan a menos de 0.002 años de la $e_0$ del INE, y las tasas de `replicada`, a menos de un 0.2 % de las suyas en todas las edades, también en el grupo abierto; `tasas_lexis`, llamada por el test con las mujeres, da sus tasas y su $a_{100+}$.
5. Supera `test_arriaga`: `arriaga` suma la diferencia de $e_0$ entre 2019 y 2020, y entre hombres y mujeres en 2024, y coincide edad a edad con una descomposición de referencia; `esperanza_temporal` da $e_{x:\overline{n}|}$.
6. Supera `test_ficha`: `ficha.typ` lee sus números con `toml()` y compila con Typst en una sola página.

Los tests leen `defunciones`, `poblacion`, `tabla_vida`, `tasas_lexis`, `residentes`, `replicada`, `por_sexo`, `arriaga` y `esperanza_temporal`: el script conserva esos nombres. Antes de enviarlo, el mismo test se pasa en la terminal, dentro del repositorio; la primera vez, el script descarga los 28 MB de los microdatos:

```sh
julia --project=semana-09 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-09 --depwarn=yes semana-09/test_semana9.jl
```
