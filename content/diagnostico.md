---
title: "Prueba de nivel"
description: "Veinte problemas de Bachillerato para saber qué repasar antes de cada semana del bootcamp, y dos demostraciones opcionales para la prueba de la pizarra."
---

El bootcamp parte de las matemáticas del Bachillerato, pero no de las mismas para todos. Quien cursó Matemáticas II vio vectores, determinantes, derivadas, integrales y probabilidad; quien cursó Matemáticas Aplicadas a las Ciencias Sociales II vio matrices, derivadas, integrales y probabilidad, pero no vectores ni determinantes; y quien eligió Latín en la modalidad de Humanidades no ha vuelto a ver matemáticas desde 4.º de ESO.

Esta prueba dice qué repasar y antes de qué semana. Son veinte problemas en seis bloques, para papel y lápiz, sin calculadora salvo en el último de probabilidad: donde salga un logaritmo o una exponencial, basta el valor exacto o acotarlo entre dos números que se puedan razonar a mano. Una hora y media basta. Un séptimo bloque, opcional pero conveniente, pide dos demostraciones, y media hora más. **Si fallas dos problemas o más de un bloque, repasa ese bloque antes de la primera semana que lo usa.**

Resuelve cada bloque entero antes de abrir sus soluciones. Nadie corrige esta prueba: es para ti, y por eso solo sirve si es honesta. Reconocer una solución no es saber encontrarla, y quien mira antes de tiempo solo se engaña a sí mismo: lo descubrirá en la primera semana que use ese bloque, cuando ya no haya tiempo de repasarlo con calma.

Si elegiste Latín y no has visto matemáticas desde 4.º de ESO, el [puente desde Humanidades](../puente/) ordena en dieciocho semanas durante 2.º de Bachillerato, o en diez después, lo que hace falta para superar esta prueba.

| Bloque | Lo usan las semanas | En el Bachillerato |
| :--- | :--- | :--- |
| A. Álgebra y funciones | 1 y 5 a 12 | Todas las modalidades con matemáticas |
| B. Vectores | 1 a 4 | Matemáticas I y II; no en las de Ciencias Sociales |
| C. Matrices y sistemas | 1 a 4 y 11 | Matemáticas II y Ciencias Sociales II; los determinantes, solo en Matemáticas II |
| D. Derivadas e integrales | 3 a 7, 10 y 11 | Matemáticas II y Ciencias Sociales II |
| E. Probabilidad | 4 y 6 a 10 | Matemáticas II y Ciencias Sociales II |
| F. Estadística | 4 | Matemáticas I y Ciencias Sociales I |
| G. Demostraciones (opcional) | La prueba de la pizarra, desde la semana 1 | Casi nunca, en ninguna modalidad |

## A. Álgebra y funciones

1. Resuelve $2^{x+1} = 24$. Da el resultado exacto con logaritmos, y di entre qué dos enteros consecutivos está.
2. Calcula $\sum_{i=1}^{4} (2i - 1)$. ¿Qué dice la suma sobre los números impares?
3. ¿Para qué valores de $x$ es $\ln x < 0$? ¿Y para cuáles no está definido?
4. La función $N(t) = \dfrac{K}{1 + c\,e^{-rt}}$, con $K, c, r > 0$, describe una difusión que se satura en $K$. Despeja $t$ en función de $N$, y calcula cuándo $N = K/2$ si $K = 1000$, $c = 99$ y $r = 0.8$: el valor exacto, y entre qué dos enteros consecutivos está, con $e \approx 2.7$.

<details>
<summary>Soluciones del bloque A</summary>

1. $x + 1 = \log_2 24$, así que $x = \log_2 24 - 1 = \log_2 12 = \dfrac{\ln 12}{\ln 2}$. Como $2^3 = 8 < 12 < 16 = 2^4$ y $2^x$ es creciente, $3 < x < 4$; con calculadora, $x \approx 3.58$.
2. $1 + 3 + 5 + 7 = 16 = 4^2$: la suma de los $n$ primeros impares es $n^2$.
3. $\ln x < 0$ si $0 < x < 1$; $\ln x$ no está definido para $x \le 0$.
4. $N(1 + c\,e^{-rt}) = K$ da $e^{-rt} = \dfrac{K - N}{cN}$, y $t = \dfrac{1}{r} \ln \dfrac{cN}{K - N}$. Con $N = K/2$, $t = \dfrac{\ln 99}{0.8}$. Como $e^2 \approx 7.3$, $e^4 \approx 53 < 99 < 143 \approx e^5$, así que $4 < \ln 99 < 5$ y $5 < t < 6.25$: $t$ está entre 5 y 6, y con calculadora, $t \approx 5.74$. Es el punto de inflexión de la semana 5.

**Si has fallado dos o más:** las funciones exponencial y logarítmica y el sumatorio, en el [precálculo de Khan Academy](https://es.khanacademy.org/math/precalculus), y los capítulos 1 a 4 de *Mathematics for Humanists*, de Gintis (en los [consejos](../consejos/)).

</details>

## B. Vectores

1. Sean $\mathbf{u} = (1, 2, 2)$ y $\mathbf{v} = (2, 0, -1)$. Calcula $\mathbf{u} \cdot \mathbf{v}$ y $\|\mathbf{u}\|$. ¿Qué ángulo forman?
2. Proyecta $\mathbf{b} = (2, 3)$ sobre la recta generada por $\mathbf{a} = (1, 1)$: halla el punto $\mathbf{p}$ de la recta más cercano a $\mathbf{b}$, y comprueba que $\mathbf{b} - \mathbf{p}$ es perpendicular a $\mathbf{a}$.
3. Calcula el coseno del ángulo entre $(1, 1, 0)$ y $(1, 0, 1)$, y el ángulo.

<details>
<summary>Soluciones del bloque B</summary>

1. $\mathbf{u} \cdot \mathbf{v} = 2 + 0 - 2 = 0$ y $\|\mathbf{u}\| = \sqrt{1 + 4 + 4} = 3$. Forman un ángulo recto: son ortogonales.
2. $\mathbf{p} = \dfrac{\mathbf{a} \cdot \mathbf{b}}{\mathbf{a} \cdot \mathbf{a}}\,\mathbf{a} = \dfrac{5}{2}(1, 1) = (2.5, 2.5)$, y $\mathbf{b} - \mathbf{p} = (-0.5, 0.5)$, con $(-0.5, 0.5) \cdot (1, 1) = 0$. Es la proyección de la semana 3, sobre una recta en lugar de un subespacio.
3. $\cos\theta = \dfrac{1}{\sqrt{2}\,\sqrt{2}} = \dfrac{1}{2}$, así que $\theta = 60°$. Es la similitud de coseno de la semana 1.

**Si has fallado dos o más:** los vídeos de 3Blue1Brown sobre [vectores](https://www.3blue1brown.com/lessons/vectors) y el [producto escalar](https://www.3blue1brown.com/lessons/dot-products), y los vectores del [álgebra lineal de Khan Academy](https://es.khanacademy.org/math/linear-algebra). Si cursaste Ciencias Sociales, este bloque es nuevo para ti: repásalo antes de la semana 1.

</details>

## C. Matrices y sistemas

1. Con $A = \begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix}$ y $B = \begin{bmatrix} 0 & 1 \\ 1 & 0 \end{bmatrix}$, calcula $AB$ y $BA$. ¿Qué observas?
2. Resuelve por el método de Gauss: $x + y + z = 6$, $2x - y + z = 3$, $x + 2y - z = 2$.
3. Calcula $\det \begin{bmatrix} 2 & 1 \\ 4 & 3 \end{bmatrix}$ y $\det \begin{bmatrix} 1 & 2 \\ 2 & 4 \end{bmatrix}$. ¿Qué tienen de especial las columnas de la segunda?
4. Con $X = \begin{bmatrix} 1 & 1 \\ 1 & 2 \\ 1 & 3 \end{bmatrix}$ y $\mathbf{y} = (1, 3, 4)$, calcula $X^T X$ y $X^T \mathbf{y}$.

<details>
<summary>Soluciones del bloque C</summary>

1. $AB = \begin{bmatrix} 2 & 1 \\ 4 & 3 \end{bmatrix}$ y $BA = \begin{bmatrix} 3 & 4 \\ 1 & 2 \end{bmatrix}$: el producto de matrices no es conmutativo. $B$ intercambia las columnas de $A$ si multiplica por la derecha, y las filas si multiplica por la izquierda.
2. $x = 1$, $y = 2$, $z = 3$.
3. $2 \cdot 3 - 1 \cdot 4 = 2$ y $1 \cdot 4 - 2 \cdot 2 = 0$. La segunda columna de la segunda matriz es el doble de la primera: son linealmente dependientes, y por eso el determinante se anula. Es el punto de partida de la semana 2.
4. $X^T X = \begin{bmatrix} 3 & 6 \\ 6 & 14 \end{bmatrix}$ y $X^T \mathbf{y} = (8, 19)$. Guárdalos para el problema F1.

**Si has fallado dos o más:** el [producto de matrices](https://www.3blue1brown.com/lessons/matrix-multiplication), el [determinante](https://www.3blue1brown.com/lessons/determinant) y las [matrices inversas](https://www.3blue1brown.com/lessons/inverse-matrices), en 3Blue1Brown. Si cursaste Ciencias Sociales, los determinantes son nuevos para ti.

</details>

## D. Derivadas e integrales

1. Deriva $f(x) = x^2 e^{-x}$ y halla su máximo para $x > 0$, con su valor exacto. ¿Es mayor o menor que 1?
2. Con los datos $y = (1, 2, 6)$, ¿qué número $b$ minimiza $S(b) = \sum_i (y_i - b)^2$? Deriva $S$ e iguala a cero.
3. Calcula $\int_0^1 3x^2 \, dx$ y $\int_0^\infty e^{-x} \, dx$.
4. Comprueba que $N(t) = \dfrac{1}{1 + e^{-t}}$ cumple $N'(t) = N(t)\,\big(1 - N(t)\big)$.

<details>
<summary>Soluciones del bloque D</summary>

1. $f'(x) = (2x - x^2)\,e^{-x} = x(2 - x)\,e^{-x}$, que se anula en $x = 2$; el máximo es $f(2) = 4e^{-2} = 4/e^2$. Como $e > 2$, $e^2 > 4$ y $f(2) < 1$; con calculadora, $f(2) \approx 0.54$.
2. $S'(b) = -2 \sum_i (y_i - b) = 0$ da $b = \bar{y} = 3$: la media minimiza la suma de cuadrados. Es la idea de los mínimos cuadrados de las semanas 3 y 4.
3. $\big[x^3\big]_0^1 = 1$ y $\big[-e^{-x}\big]_0^\infty = 1$. Las dos funciones son densidades de probabilidad: su área total es 1.
4. $N'(t) = \dfrac{e^{-t}}{(1 + e^{-t})^2} = \dfrac{1}{1 + e^{-t}} \cdot \dfrac{e^{-t}}{1 + e^{-t}} = N(t)\,\big(1 - N(t)\big)$. Es la ecuación logística de la semana 5, con $r = 1$ y $K = 1$.

**Si has fallado dos o más:** la serie de 3Blue1Brown sobre el cálculo, desde [la derivada](https://www.3blue1brown.com/lessons/derivatives) hasta [la integral](https://www.3blue1brown.com/lessons/integration), y el [cálculo diferencial de Khan Academy](https://es.khanacademy.org/math/differential-calculus).

</details>

## E. Probabilidad

1. Una enfermedad afecta al 1 % de la población. Una prueba la detecta en el 90 % de los enfermos y da positivo, por error, en el 5 % de los sanos. Si una persona da positivo, ¿qué probabilidad hay de que esté enferma?
2. Si $X \sim \text{Binomial}(n = 5, p = 0.3)$, calcula $P(X = 2)$.
3. Calcula la esperanza y la varianza de la puntuación de un dado equilibrado.
4. Si $X \sim \mathcal{N}(100, 15^2)$, ¿cuánto vale aproximadamente $P(X > 130)$? Puedes usar una tabla de la normal o una calculadora.

<details>
<summary>Soluciones del bloque E</summary>

1. Por el teorema de Bayes, $P(E \mid +) = \dfrac{0.01 \cdot 0.9}{0.01 \cdot 0.9 + 0.99 \cdot 0.05} = \dfrac{0.009}{0.0585} \approx 0.15$. Solo un 15 %: la mayoría de los positivos son sanos, porque los sanos son muchos más.
2. $\binom{5}{2}\, 0.3^2\, 0.7^3 = 10 \cdot 0.09 \cdot 0.343 \approx 0.309$.
3. $\mathbb{E}[X] = \dfrac{1 + \dots + 6}{6} = 3.5$ y $\text{Var}(X) = \mathbb{E}[X^2] - \mathbb{E}[X]^2 = \dfrac{91}{6} - 3.5^2 = \dfrac{35}{12} \approx 2.92$.
4. $P(X > 130) = P\big(Z > \tfrac{130 - 100}{15}\big) = P(Z > 2) \approx 0.023$.

**Si has fallado dos o más:** el [teorema de Bayes](https://www.3blue1brown.com/lessons/bayes-theorem) en 3Blue1Brown, los capítulos 1 a 4 de Blitzstein y Hwang (en los [consejos](../consejos/)) y la [probabilidad de Khan Academy](https://es.khanacademy.org/math/statistics-probability).

</details>

## F. Estadística

1. Halla la recta de regresión $\hat{y} = a + bx$ de los puntos $(1, 1)$, $(2, 3)$ y $(3, 4)$, y su coeficiente de correlación. Después resuelve el sistema $X^T X \, (a, b) = X^T \mathbf{y}$ con las matrices del problema C4 y compara.

<details>
<summary>Solución del bloque F</summary>

1. Con $\bar{x} = 2$ e $\bar{y} = 8/3$, la pendiente es $b = \dfrac{\sum (x_i - \bar{x})(y_i - \bar{y})}{\sum (x_i - \bar{x})^2} = \dfrac{3}{2} = 1.5$, y la ordenada en el origen, $a = \bar{y} - b\,\bar{x} = -\tfrac{1}{3}$. La correlación es $r \approx 0.98$. El sistema $\begin{bmatrix} 3 & 6 \\ 6 & 14 \end{bmatrix} \begin{bmatrix} a \\ b \end{bmatrix} = \begin{bmatrix} 8 \\ 19 \end{bmatrix}$ da la misma recta: la regresión del Bachillerato es la ecuación normal de la semana 4.

**Si has fallado:** la estadística bidimensional de Matemáticas I o de Ciencias Sociales I, y la [regresión de Khan Academy](https://es.khanacademy.org/math/statistics-probability).

</details>

## G. Demostraciones (opcional)

Los veinte problemas anteriores piden calcular. En la prueba de la pizarra, además, hay que justificar cada paso con notación, y el Bachillerato casi nunca lo pide: este bloque detecta a tiempo a quien calcula bien pero se bloquea ante una demostración. Es opcional, pero conviene hacerlo. Escribe cada demostración entera, con una frase que justifique cada paso.

1. El problema A2 comprobó que $1 + 3 + 5 + 7 = 4^2$. Demuestra que la suma de los $n$ primeros impares es $n^2$ para cualquier entero $n \ge 1$, es decir, que $\sum_{i=1}^{n} (2i - 1) = n^2$, de dos maneras: por inducción, y con un dibujo de puntos que lo haga evidente.
2. Sean $x_1, \dots, x_n$ números reales y $\bar{x} = \frac{1}{n} \sum_{i=1}^{n} x_i$ su media. Demuestra que $\sum_{i=1}^{n} (x_i - \bar{x}) = 0$. Deduce que, para otros números $y_1, \dots, y_n$ con media $\bar{y}$, $\sum_i (x_i - \bar{x})(y_i - \bar{y}) = \sum_i (x_i - \bar{x})\, y_i$.

<details>
<summary>Soluciones del bloque G</summary>

Una demostración bien escrita dice qué se quiere probar, de qué se parte y por qué se sigue cada paso del anterior, y termina diciendo que lo pedido está probado. Comprobar unos cuantos casos, como hizo A2 con $n = 4$, no es demostrar: es reunir indicios para una conjetura.

1. **Por inducción.** Sea $P(n)$ la afirmación $\sum_{i=1}^{n} (2i - 1) = n^2$.
   - *Caso base.* Para $n = 1$, la suma tiene un solo término, $2 \cdot 1 - 1 = 1$, y $1 = 1^2$: $P(1)$ es cierta.
   - *Paso inductivo.* Supongamos que $P(k)$ es cierta para un $k \ge 1$ cualquiera: es la hipótesis de inducción. La suma de los $k + 1$ primeros impares es la de los $k$ primeros más el impar $k + 1$, que es $2(k + 1) - 1 = 2k + 1$:
     $$
     \sum_{i=1}^{k+1} (2i - 1) = \sum_{i=1}^{k} (2i - 1) + (2k + 1) = k^2 + 2k + 1 = (k + 1)^2
     $$
     donde la segunda igualdad usa la hipótesis de inducción, y la tercera, el cuadrado de un binomio. Luego $P(k + 1)$ es cierta.
   - *Conclusión.* $P(1)$ es cierta, y si $P(k)$ lo es, también $P(k + 1)$. Por el principio de inducción, $P(n)$ es cierta para todo $n \ge 1$. $\blacksquare$

   **Con un dibujo.** Un cuadrado de $k \times k$ puntos tiene $k^2$ puntos. Para convertirlo en uno de $(k + 1) \times (k + 1)$ hay que añadirle una escuadra: una fila de $k$ puntos abajo, una columna de $k$ a la derecha y el punto de la esquina, $2k + 1$ puntos, que es el impar número $k + 1$. Empezando por un punto, $1$, y añadiendo escuadras de $3, 5, 7, \dots$ puntos, tras $n$ escuadras se tiene un cuadrado de $n \times n$. El dibujo es una demostración porque el argumento vale para cualquier $k$, no solo para los cuadrados dibujados: es el paso inductivo, visto. Hay una tercera manera, directa: $\sum_i (2i - 1) = 2 \sum_i i - n = n(n + 1) - n = n^2$, que se apoya en la suma de Gauss, $\sum_{i=1}^{n} i = n(n + 1)/2$, y que a su vez habría que demostrar. Una misma verdad admite varias demostraciones, y cada una explica algo distinto.

2. **Demostración directa.**
   - El sumatorio de una diferencia es la diferencia de los sumatorios: $\sum_i (x_i - \bar{x}) = \sum_i x_i - \sum_i \bar{x}$.
   - $\bar{x}$ no depende de $i$, así que sumarlo para $i = 1, \dots, n$ es sumar $n$ veces el mismo número: $\sum_i \bar{x} = n\,\bar{x}$.
   - Por la definición de la media, $n\,\bar{x} = \sum_i x_i$.
   - Luego $\sum_i (x_i - \bar{x}) = \sum_i x_i - \sum_i x_i = 0$. $\blacksquare$

   **La consecuencia.** Desarrollando el producto, $\sum_i (x_i - \bar{x})(y_i - \bar{y}) = \sum_i (x_i - \bar{x})\, y_i - \bar{y} \sum_i (x_i - \bar{x})$, donde $\bar{y}$ sale del sumatorio porque no depende de $i$. Por lo que se acaba de demostrar, el segundo término es $\bar{y} \cdot 0 = 0$. $\blacksquare$ Las desviaciones respecto a la media se compensan: la media es el punto de equilibrio de los datos. Es lo que hace que, en la semana 4, los residuos de una regresión con intercepto sumen cero.

**Si no te ha salido:** no hace falta repetir ningún bloque. Antes de la semana 1, porque la prueba de la pizarra empieza con ella, lee *Book of Proof*, de Hammack (en los [consejos](../consejos/)): los capítulos 1 y 2, los conjuntos y la lógica; el 4, la demostración directa, y el 10, la inducción. Después, vuelve a escribir estas dos demostraciones sin mirar las soluciones.

</details>

## Y después

Lo que ninguna modalidad del Bachillerato enseña empieza en la semana 2: los subespacios, el rango, las proyecciones, las ecuaciones diferenciales y las densidades de probabilidad. Cada guía abre con un recuadro, *Lo que esta semana da por sabido*, que dice qué bloques de esta prueba necesita y qué es nuevo para todos.
