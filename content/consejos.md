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

Para cada test que pasa tu script, debes saber decir qué comprueba y por qué fallaría una versión equivocada. Y para cada supuesto del modelo, qué pasa si no se cumple: es la objeción que hará el tribunal.

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
