---
title: "Semana 12: El proyecto de replicación: una comunidad autónoma, de los microdatos al informe"
date: 2027-09-13
weight: 12
---

**Módulo:** Demografía matemática y replicación empírica  
**Lecturas imprescindibles:** INE, [*Tablas de mortalidad. Metodología*](https://www.ine.es/metodologia/t20/t2020319a.pdf), sección 3, las tablas de las comunidades autónomas; las guías de las semanas 9, 10 y 11  
**De ampliación:** INE, [*Proyecciones de Población 2024-2074. Metodología*](https://www.ine.es/metodologia/t20/meto_propob_2024_2074.pdf), para la sección 4; la [documentación de Typst](https://typst.app/docs/), para el informe  
**Herramientas:** Julia 1.11 o posterior, con la biblioteca estándar; `sh`, `curl`, `unzip` y `awk`; `git`; Typst 0.15; `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** el ejercicio de replicación empírica del programa: un repositorio reproducible, con un script de consola, un script de Julia y un informe de dos páginas en Typst, sujetos a integración continua, y una defensa individual en la pizarra

> [!nota] Lo que esta semana da por sabido
> - **De semanas anteriores:** la tabla de vida de Lexis de la semana 9, la ecuación de Euler-Lotka de la 10 y la matriz de Leslie de la 11; la consola de la semana 2, Git de la 3 y el proyecto de cierre de la semana 4, con su `limpiar.sh`, que esta semana se repite con otros datos.
> - **Nuevo para todos:** nada de contenido. La semana es de oficio: reunir tres piezas en una canalización que se ejecuta de principio a fin en limpio, y explicarla por escrito y de viva voz.

## 1. El proyecto

El programa lo resume en una frase: el proyecto es de replicación, no de creación libre. Cada estudiante recibe una comunidad autónoma, con su código del INE, y reconstruye para ella la tabla de mortalidad de 2024 que publica el INE, a partir de los microdatos de defunciones; calcula su tasa intrínseca de crecimiento y su matriz de Leslie, y proyecta su población femenina treinta años, sin migración y con la de 2024. La tabla del INE es el test: la esperanza de vida al nacer replicada debe coincidir con la publicada.

Las diecinueve comunidades y ciudades autónomas se pueden replicar. Con el método de la semana 9 y el grupo abierto que el INE usa en sus tablas autonómicas —95 y más años, y 90 y más en Ceuta y Melilla—, las diecisiete comunidades quedan a menos de 0.002 años de la $e_0$ publicada, y Ceuta y Melilla, a menos de 0.01. Sus tasas intrínsecas van de $-0.0286$ en Canarias, con un ISF de 0.82, a $-0.0139$ en la Región de Murcia, con 1.32: ninguna llega a $r = 0$.

**Los datos.** En `semana-12/datos/`, en el formato de las tablas del INE, solo de 2024 y de las comunidades:

| Archivo | Tabla del INE | Contenido |
| :--- | :--- | :--- |
| `poblacion_ccaa.csv` | [56940](https://www.ine.es/jaxiT3/Tabla.htm?t=56940) | Población por comunidad, sexo y edad simple a 1 de enero de 2024 y de 2025 |
| `nacimientos_ccaa.csv` | [6509](https://www.ine.es/jaxiT3/Tabla.htm?t=6509) | Nacimientos de 2024 por comunidad de residencia de la madre, sexo y edad de la madre |
| `tablas_mortalidad_ccaa.csv` | [27154](https://www.ine.es/jaxiT3/Tabla.htm?t=27154) | Las tablas de mortalidad de 2024 de cada comunidad, abreviadas: 0, 1 a 4, 5 a 9 y así hasta el grupo abierto |
| `provincias.csv` | | El código de cada provincia y el de su comunidad |

Los microdatos de defunciones son los de la semana 9, en `semana-09/datos/datos_2024.zip`. Dos trampas nuevas: el INE escribe `""` en las celdas sin datos, como las edades sin nacimientos de las comunidades pequeñas, y en ellas hay edades sin defunciones, cuya $a_x$ se toma igual a $1/2$. Y la tabla 27154 es abreviada, pero de ella solo se compara la $e_0$: la tabla replicada es de edad simple, como en la semana 9.

## 2. Los entregables

Todos en `semana-12/`, en el repositorio de la asignatura:

1. **`comunidad.txt`**, con el código de dos cifras de la comunidad asignada, de `01`, Andalucía, a `19`, Melilla, en el orden de las tablas del INE.

2. **`limpiar.sh`**, un script POSIX que se ejecuta desde `semana-12/` con el código como argumento, `sh limpiar.sh 13`. Si el zip de los microdatos no está, lo descarga con `curl`. Con `unzip -p` y `awk`, escribe `datos/defunciones.csv`, con la cabecera `sexo,anio_nac,mes_nac,mes_def,edad` y una fila por cada fallecido residente en una provincia de la comunidad, en el orden del zip: `sexo` es `H` o `M`, y los meses van sin el cero de delante. Como en la semana 4, empieza con `export LC_ALL=C`, y la integración continua lo ejecuta con `dash`.

3. **`proyecto.jl`**, que lee `datos/defunciones.csv` y los archivos del INE y construye, sin más paquetes que la biblioteca estándar, `CairoMakie` y `Somosaguas`:
   - las tablas de vida de 2024 de ambos sexos, de los hombres y de las mujeres, con la exposición de Lexis y el grupo abierto del INE;
   - la fecundidad por edad, $R_0$ y la tasa intrínseca $r$, por Euler-Lotka;
   - la matriz de Leslie femenina, hasta el grupo abierto, con su autovalor dominante, su amortiguamiento y su estructura estable;
   - la migración neta femenina de 2024 por el método residual, y la proyección de la población femenina desde el 1 de enero de 2025 hasta 2055, sin migración y con la de 2024 cada año.

   Deja al menos una figura en `resultados/` y escribe con `TOML.print` el archivo `resultados/proyecto.toml`, con estas claves:

   | Clave | Contenido |
   | :--- | :--- |
   | `comunidad`, `nombre`, `edad_cierre` | El código, el nombre del INE y la edad del grupo abierto |
   | `e0`, `e0_ine` | Tablas con `ambos`, `hombres` y `mujeres`: la esperanza de vida replicada y la publicada |
   | `isf`, `R0`, `r`, `T` | El indicador coyuntural, la tasa neta de reproducción, la tasa intrínseca y la longitud de una generación |
   | `lambda`, `amortiguamiento` | El autovalor dominante de Leslie y $\lambda_1 / \lvert\lambda_2\rvert$ |
   | `migracion_neta` | La suma de la migración neta femenina residual de 2024 |
   | `grupos`, `mujeres_2025`, `cerrada_2055`, `migracion_2055`, `estable` | Los vectores de la proyección por grandes grupos, `["0-14", "15-64", "65+"]`: la población de 2025, las dos de 2055 y la proporción de cada grupo en la población estable |

4. **`informe.typ`**, el informe de dos páginas A4 como mucho que pide el programa, con todos los números leídos de `resultados/proyecto.toml` con `toml()`, ninguno copiado a mano. Tiene tres partes:
   - **La tabla de vida.** La deducción de sus ecuaciones, de la exposición de Lexis a $e_0 = T_0 / l_0$, y la tabla de las tres esperanzas de vida replicadas frente a las del INE.
   - **La reproducción.** La ecuación de Euler-Lotka, con $R_0$, $r$ y $T$, y la matriz de Leslie: su estructura, su ecuación característica y por qué $\log \lambda$ coincide con $r$.
   - **La proyección.** Los vectores de la proyección, en una tabla, con una figura, y un párrafo que evalúe la tasa intrínseca: qué dice $r$ de tu comunidad, en cuánto tiempo se reduciría a la mitad su población cerrada, y por qué la proyección cerrada no es una predicción.

5. **El historial de Git**, en commits pequeños, uno por idea, como en la semana 3. `datos/defunciones.csv` es un extracto de los microdatos y no entra en el repositorio: el `.gitignore` de la asignatura ya lo excluye.

Antes de cada push, la canalización entera se ejecuta en limpio, en este orden:

```sh
cd semana-12
sh limpiar.sh "$(cat comunidad.txt)"
julia --project=. proyecto.jl
typst compile informe.typ
```

## 3. La defensa en la pizarra

Sin pantalla y sin el informe delante. El tribunal pide una derivación y plantea objeciones directas.

- **La derivación:** los autovectores de la matriz de Leslie. Con la subdiagonal, deduce $w_x = w_0\, \lambda^{-x} \prod_{y<x} s_y$; con la primera fila, la ecuación característica; con $\mathbf{v}^T A = \lambda \mathbf{v}^T$, columna a columna, el valor reproductivo por la izquierda, $v_{x+1} = \left(\lambda v_x - A_{1,x}\, v_0\right)/s_x$, desde $v_0 = 1$ hasta la última edad fértil. ¿Por qué es mejor recorrerla hacia atrás, desde la última edad fértil, con $v_x = \left(A_{1,x}\, v_0 + s_x v_{x+1}\right)/\lambda$? Hacia delante, cada paso resta dos cantidades casi iguales: en todas las comunidades se pierden unas seis cifras, con un error relativo de $10^{-10}$ en la última edad fértil, y lo que debería ser 0 después de ella sale del orden de $10^{-14}$. Hacia atrás, solo se suman términos positivos. Explica por qué $\mathbf{w}$ es positivo y $\lambda_1$ es simple, con Perron-Frobenius.
- **Objeciones posibles:** los microdatos no traen el día de nacimiento ni el de la muerte, ¿cómo puede coincidir tu $e_0$ con la del INE a la milésima? ¿Qué parte del resultado se debe a cada decisión de la semana 9? Tu migración residual mezcla la migración con el extranjero y la de otras comunidades: ¿cambia eso la interpretación de la proyección? ¿Qué supone la proyección con la migración de 2024 constante, y qué pasaría si fuera la mitad? Tu $r$ dice que la población cerrada se reduciría a la mitad en pocas décadas: si la de tu comunidad crece, ¿hay contradicción? ¿Por qué Leslie usa solo mujeres, y qué se pierde? Tu migración de 2024 es una cantidad fija por edad, y en muchas edades es negativa: si una comunidad perdiera más jóvenes de los que tiene, ¿qué daría la proyección? ¿Y $(I - A)^{-1}\mathbf{m}$ con una migración neta total negativa? ¿Por qué la emigración se modela mejor como una tasa sobre la población que como una cantidad?

## 4. Ampliación (sin entrega)

- **Contra el INE.** El INE proyecta la población de España hasta 2074 con supuestos sobre la fecundidad, la mortalidad y la migración por edad que publica en su metodología. Construye la matriz de Leslie nacional con sus supuestos de fecundidad y de mortalidad y compara tu proyección con la suya: ¿dónde coinciden, dónde divergen, y qué supuesto explica cada diferencia?
- **Las diecinueve.** Reúne las $r$ de todos tus compañeros: ¿qué relación tienen con el ISF y con la edad media a la maternidad de cada comunidad? ¿Qué parte de la variación entre comunidades se debe a la fecundidad y cuánta a la mortalidad? La elasticidad de la semana 11 da la idea, y el método tiene nombre: el análisis de respuesta de la tabla de vida (LTRE) de Caswell, en su *Matrix Population Models*, que reparte la diferencia de $\lambda$ entre dos matrices con las sensibilidades de una matriz intermedia.

## 5. Criterio de verificación por integración continua

Con cada push que cambie uno de los entregables, la integración continua ejecuta `semana-12/test_semana12.jl`, y el proyecto se supera si:

1. `comunidad.txt` tiene un código de `01` a `19`, y `sh limpiar.sh`, ejecutado en `dash`, descarga si hace falta los microdatos, cuya suma SHA-256 es la de la semana 9, y deja `datos/defunciones.csv` con exactamente las filas que el test lee por su cuenta del zip, en el mismo orden.
2. `proyecto.jl` no usa más paquetes que la biblioteca estándar, `CairoMakie` y `Somosaguas`, se ejecuta sin advertencias y deja una figura y `resultados/proyecto.toml`.
3. Las tres esperanzas de vida replicadas quedan a menos de 0.01 años de las del INE, o de 0.02 en Ceuta y Melilla, y a menos de 0.001 de las de una tabla de referencia que el test construye con el método de la semana 9.
4. El ISF, $R_0$ y $r$ coinciden con los de referencia, $\log \lambda$ queda a menos de $10^{-5}$ de $r$, y el amortiguamiento es mayor que 1.
5. La migración neta es la residual de referencia, los vectores de la proyección tienen sus tres grupos, la población cerrada de 2055 es menor que la de 2025 y las proporciones de la estructura estable suman 1.
6. `informe.typ` lee sus números con `toml()` y compila con Typst en una o dos páginas.
7. `datos/defunciones.csv` está excluido por `.gitignore` y fuera del repositorio.

Todo trabajo cuya compilación falle en limpio en el entorno de pruebas recibe, como dice el programa, calificación nula. Un fallo del servidor del INE no es del trabajo: la integración continua descarga los microdatos en un paso propio, antes del test y con reintentos, y si es ese paso el que falla, la ejecución se repite y no se califica. El mismo test se pasa antes en la terminal, dentro del repositorio:

```sh
julia --project=semana-12 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-12 --depwarn=yes semana-12/test_semana12.jl
```
