---
title: "Consejos generales"
description: "Cómo trabajar las doce semanas del bootcamp, cómo preparar la prueba de la pizarra y qué leer además del programa."
---

Lo que sirve para las doce semanas, sea cual sea la guía: cómo trabajar, cómo preparar la prueba de la pizarra y qué leer además de los textos de cada semana. Complementan esta página la [guía autodidacta](https://nuevasomosaguas.github.io/guia_autodidacta.html), con su presupuesto de horas y su higiene de la atención, la [política de inteligencia artificial](https://nuevasomosaguas.github.io/politica_ia.html) y el [entorno de trabajo](https://nuevasomosaguas.github.io/entorno.html).

## Antes de la semana 1

- **La [prueba de nivel](../diagnostico/).** Veinte problemas de Bachillerato, en seis bloques, que dicen qué repasar y antes de qué semana. Las matemáticas del Bachillerato no son las mismas en Ciencias, en Ciencias Sociales o en Humanidades con Latín, y la prueba lo tiene en cuenta. Quien eligió Latín tiene, además, el [puente desde Humanidades](../puente/): dieciocho semanas de preparación durante 2.º de Bachillerato, o diez después, antes de la semana 1.
- **El entorno, instalado y probado.** Julia, la terminal, Git y un editor, como explica la página del [entorno](https://nuevasomosaguas.github.io/entorno.html). El primer día se programa, no se instala.
- **Las dos primeras lecciones de [*The Missing Semester*](https://missing.csail.mit.edu/2026/)**, la introducción a la consola y el entorno de la línea de órdenes: la semana 2 las da por sabidas.
- **Los capítulos 1 a 3 de *Mathematics for Humanists*, de Gintis** (más abajo), si vienes de un bachillerato de letras: leer matemáticas, la lógica y los conjuntos. Son el idioma en que están escritas todas las guías.

## Cómo trabajar

1. **Lee matemáticas con lápiz.** Gintis lo resume así: leer matemáticas no es como leer prosa; o se entiende cada expresión por completo o no se entiende. Si una no se entiende, se lee símbolo a símbolo hasta dar con el que falla, y no se sigue hasta saber qué significa. Una página de marco conceptual por hora es un buen ritmo. Rehaz cada derivación en papel antes de abrir el código.
2. **Primero a mano, después en Julia, después el test.** Es el orden de cada guía. Una función cuyo resultado no sabes predecir a mano no está entendida, aunque pase el test.
3. **Comprueba cada número.** Las guías dan valores concretos: un pico en $0.499\,K$, un error de $3 \cdot 10^{-5}$, una prima salarial de $0.81$. Reprodúcelos. Si no coinciden, el error está en tu código o en la guía, y las dos cosas merecen saberse.
4. **Pasa el test en tu máquina antes de cada push.** El test de la integración continua es el mismo que el de la terminal: si falla en local, fallará en GitHub.
5. **Un commit, una idea.** Prepara cada commit con `git add -p` y escribe en el mensaje qué cambia y por qué. Los datos y los resultados no entran nunca en el repositorio.
6. **Bloques largos, no ratos sueltos.** Las 25 a 30 horas semanales rinden en sesiones de dos o tres horas sin interrupciones, una de papel y otra de terminal mejor que cinco de cada cosa a medias.
7. **Pide ayuda con un ejemplo mínimo.** El script más corto que reproduce el error, el mensaje exacto y la salida de `versioninfo()`. La mitad de las veces, preparar el ejemplo resuelve el problema.
8. **La IA, como interlocutor.** Según la [política de inteligencia artificial](https://nuevasomosaguas.github.io/politica_ia.html): pídele que critique tu derivación o tu código, no que los escriba. Respondes de cada línea que entregas, y la pizarra lo comprueba.

## Preparar la prueba de la pizarra

En la pizarra no hay pantalla: se deriva de viva voz lo que el script ejecutó. Cada semana deja un resultado que hay que saber deducir sin notas.

| Semana | Lo que se deriva en la pizarra |
| :--- | :--- |
| 1 | Por qué la matriz de similitudes es un único producto de matrices normalizadas por filas |
| 2 | Por qué $\mathcal{C}(A^T)^\perp = \mathcal{N}(A)$, y por qué Gram-Schmidt clásico pierde la ortogonalidad más deprisa que el modificado |
| 3 | De la ecuación normal a $R\mathbf{x} = Q^T\mathbf{b}$, y por qué formar $A^TA$ eleva al cuadrado $\kappa$ |
| 4 | La varianza de $\boldsymbol{\hat\beta}$ y el teorema de Gauss-Markov; qué mide, y qué no, el coeficiente de la brecha salarial |
| 5 | El punto de inflexión de la logística en $K/2$ y el umbral $R_0 > 1$ del SIR |
| 6 | La actualización beta-binomial y la decisión que minimiza la pérdida esperada |
| 7 | El paso de Newton como unos mínimos cuadrados ponderados, por qué converge de forma cuadrática y la máxima entropía, $p_k \propto e^{\lambda v_k}$, con Lagrange |
| 8 | El coste $O(nm)$ de los bucles anidados frente al $O(n + m)$ de la tabla hash, y la esperanza de los pares en colisión con variables indicadoras |
| 9 | $q_x = m_x / (1 + (1 - a_x)\, m_x)$ y la exposición del diagrama de Lexis, y por qué las contribuciones de Arriaga suman exactamente la diferencia de $e_0$ |
| 10 | La ecuación de Euler-Lotka a partir de la de renovación, por qué tiene una sola raíz real, la aproximación de Coale y el factor $1 - c$ de Bongaarts y Feeney |
| 11 | Los autovalores y autovectores de una matriz de Leslie de $3 \times 3$, a mano, y la sensibilidad $\partial\lambda/\partial a_{ij} = v_i w_j / \mathbf{v}^T\mathbf{w}$ |
| 12 | Los autovectores de la matriz de Leslie de tu comunidad y su ecuación característica, que es la de Euler-Lotka, frente a las objeciones del tribunal |

Para cada test que pasa tu script, debes saber decir qué comprueba y por qué fallaría una versión equivocada. Y para cada supuesto del modelo, qué pasa si no se cumple: es la objeción que hará el tribunal.

## Con el entorno de la Nueva Somosaguas

El [entorno de trabajo](https://nuevasomosaguas.github.io/entorno.html) trae lo que pide el bootcamp —Julia 1.13 con CairoMakie y `Somosaguas`, Typst 0.15, Git, `curl`, `unzip` y la consola POSIX— en las mismas versiones que la integración continua. Lo que sigue es cómo usarlo sin tropezar.

- **Qué nivel, para qué.** Doce semanas a 25-30 horas piden la distribución instalada: el disco guarda todo, Git usa tus credenciales y no hay cuota. Codespaces sirve para probar y para el [puente](../puente/), no para el bootcamp entero: su cuota gratuita, 120 horas de núcleo al mes (180 con GitHub Education), da unas 60 horas en la máquina de dos núcleos, y un Codespace abierto desde el repositorio del entorno solo puede escribir en ese repositorio, no en tu copia del bootcamp. En el devcontainer, lo que no está en `/workspaces` se pierde al reconstruirlo: si trabajas ahí, `git push` al terminar cada sesión. El USB en vivo no guarda nada al apagar.
- **Los paquetes de Julia, el primer día.** La imagen trae CairoMakie y `Somosaguas` ya compilados, pero cada semana pide `Somosaguas` en su última versión, y el primer `Pkg.instantiate()` puede tardar unos minutos en descargar y compilar lo que cambie. Hazlo el primer día con la semana 1, mientras lees su guía: las demás semanas tienen los mismos paquetes y lo reutilizan. En un contenedor, `~/.julia` se pierde al reconstruirlo, y la espera vuelve.
- **La consola, como la de la integración continua.** `/bin/sh` es `dash`, como en GitHub, así que `sh limpiar.sh` falla en tu máquina donde fallaría allí. Pero el entorno está en español: los números conservan el punto decimal, y en cambio `sort`, `ls` y los rangos como `[a-z]` ordenan como en español, y la integración continua no. Por eso cada script de consola empieza con `export LC_ALL=C`, como piden las semanas 2, 4 y 12.
- **Una sesión por semana.** `zellij attach -c semana-09`, desde `semana-09/`, abre la pestaña de Julia con el `Project.toml` de esa semana: allí, `include("laboratorio_semana9.jl")` deja todas las variables a mano para probar. La pestaña de lazygit hace los commits pequeños que piden las guías: `Intro` sobre un archivo muestra sus cambios, y el espacio prepara solo la línea o el bloque elegidos, como `git add -p`.
- **Typst: lo que compila en tu máquina y no en la integración continua.** Dos cosas del entorno no están en GitHub. La plantilla `@local/somosaguas` falla allí con *package not found*, y la compilación fallida es una calificación nula. Y las fuentes, EB Garamond y Fira Code, faltan sin error: Typst usa las suyas, con otro ancho de letra, y un informe de dos páginas puede pasar a tres. Para `ficha.typ` e `informe.typ`, Typst sin plantilla, como en las guías, y antes de cada push, `typst compile --ignore-system-fonts informe.typ`, que da las páginas que verá la integración continua. La vista previa de VS Code usa las fuentes del sistema y no lo muestra.
- **Las citas del informe.** `bibcongelar informe.typ` escribe junto al informe un `referencias.bib` con las entradas que cita, sacadas de tu Zotero y de la biblioteca de la Nueva Somosaguas. Va al repositorio con el informe, y `#bibliography("referencias.bib")` compila igual en GitHub, que no tiene tu Zotero.
- **Ni `nuevo-proyecto` ni más lenguajes.** `nuevo-proyecto` crea un repositorio propio con su estructura, y en el del bootcamp las carpetas y los nombres son los de las guías. Su regla, que el análisis escribe las cifras y el informe las lee, es la del proyecto de la semana 12: úsalo para tus trabajos después del verano. R, Python, DataFrames y CSV están en el entorno, pero el bootcamp es solo Julia: la semana 4 rechaza los paquetes de regresión, y la 12, todo lo que no sea la biblioteca estándar, CairoMakie y `Somosaguas`. Para mirar un CSV del INE antes de leerlo, Rainbow CSV en VS Code o `xsv table -d ';'` en la consola.
- **Leer y repasar.** *The Linux Command Line*, de Shotts, espera en `~/Documents` para las semanas 2 y 3. `biblectura` abre en Obsidian una ficha de lectura por libro, con su estado: `verificado` es cuando la ecuación ya funciona como script, la misma costumbre que comprobar cada número. Las clases de Strang se bajan con `yt-dlp` a `~/Cursos`, y mpv las retoma donde se dejaron (`Aprender.pdf`, en `~/Documents`, lo explica). Newsboat ya sigue *Demographic Research* y el *European Journal of Population*, las revistas de la fase III.
- **Si algo se borra.** En la distribución instalada, Snapper guarda una instantánea diaria de `/home`: `snapper -c home list` las enumera, y el archivo de ayer está entero en `/home/.snapshots/N/snapshot/`. No es una copia de seguridad, porque vive en el mismo disco: la copia es el `git push`.
- **Al medir tiempos**, en la semana 8, mira en htop, la última pestaña de Zellij, que nada más ocupe los núcleos: un Pluto abierto o una compilación en marcha cambian la pendiente.

## Lecturas recomendadas

Además de los textos de referencia de cada semana.

### Leer y escribir matemáticas

- **Herbert Gintis, *Mathematics for Humanists*.** Un libro para quien llega a las matemáticas desde las humanidades: las trata como un lenguaje que permite decir con precisión lo que la prosa no puede. Recorre la lectura de textos matemáticos, la lógica, los conjuntos, los números, la probabilidad, el cálculo, los espacios vectoriales y el análisis real. Es un borrador de 2021, en abierto, que quedó sin terminar al morir Gintis en 2023: [en la web de la UMass](https://www.umass.edu/preferen/gintis/mathlit.pdf) y, si el enlace falla, [en el Internet Archive](http://web.archive.org/web/20241116135949/http://www.umass.edu/preferen/gintis/mathlit.pdf). Los capítulos 1 a 3 antes de la semana 1; el 8, con las semanas 1 a 4; el 6 y el 7, con las semanas 5 y 6.
- **Richard Hammack, [*Book of Proof*](https://richardhammack.github.io/BookOfProof/).** Cómo se escribe una demostración, con ejercicios resueltos. Libre y gratuito. Si no te salen las demostraciones del bloque G de la [prueba de nivel](../diagnostico/), los capítulos 1, 2, 4 y 10 antes de la semana 1.
- **Daniel J. Velleman, *How to Prove It: A Structured Approach*** (Cambridge University Press). La estructura lógica de las demostraciones, paso a paso.
- **George Pólya, *How to Solve It*** (Princeton University Press). El método para atacar un problema que no se sabe resolver: entenderlo, buscar uno parecido, plantear un plan y revisarlo.

### Matemáticas para las ciencias sociales

- **Will H. Moore y David A. Siegel, [*A Mathematics Course for Political and Social Research*](https://press.princeton.edu/books/paperback/9780691159171/a-mathematics-course-for-political-and-social-research)** (Princeton University Press, 2013). Álgebra, cálculo, probabilidad y álgebra lineal, con ejemplos de ciencia política y sociología.
- **Jeff Gill, *Essential Mathematics for Political and Social Research*** (Cambridge University Press, 2006). El mismo terreno, con más peso en la probabilidad.

### Álgebra, cálculo y probabilidad, en abierto

- **Gilbert Strang, [*18.06 Linear Algebra*](https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/)**, en el MIT OpenCourseWare. Las clases grabadas del autor del texto de la fase I.
- **3Blue1Brown, [*Essence of Linear Algebra*](https://www.3blue1brown.com/topics/linear-algebra) y [*Essence of Calculus*](https://www.3blue1brown.com/topics/calculus).** La geometría que hay detrás de las fórmulas, en vídeos cortos.
- **Joseph K. Blitzstein y Jessica Hwang, *Introduction to Probability*.** El texto de probabilidad de la fase II, que sus autores ofrecen en PDF en [probabilitybook.net](https://probabilitybook.net/).

### Consola, Git y Julia

- **[*The Missing Semester of Your CS Education*](https://missing.csail.mit.edu/)** (MIT). La consola, el editor, la depuración y Git: las herramientas que ninguna asignatura enseña. La lección [*Data Wrangling*](https://missing.csail.mit.edu/2020/data-wrangling/) de la edición de 2020, sobre `sed` y `awk`, acompaña a la semana 2.
- **Scott Chacon y Ben Straub, [*Pro Git*](https://git-scm.com/book/es/v2)**, en español. Los capítulos 2 y 3 bastan para la semana 3.
- **Ben Lauwens y Allen B. Downey, [*Think Julia*](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html).** Una introducción a la programación con Julia, desde cero.
- **[*Modern Julia Workflows*](https://modernjuliaworkflows.org/).** Entornos, tests, perfilado y depuración en Julia: el oficio alrededor del código.
- **Los [consejos de rendimiento](https://docs.julialang.org/en/v1/manual/performance-tips/) del manual de Julia.** Por qué una función es lenta o reserva memoria: el complemento de la semana 3.
