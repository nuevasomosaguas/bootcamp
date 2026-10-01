---
title: "Semana 4: Regresión lineal, Gauss-Markov e influencia"
date: 2027-07-19
weight: 4
---

**Módulo:** Cimientos formales y programación  
**Texto de referencia:** Gilbert Strang, *Linear Algebra and Its Applications*, cap. 3 (ortogonalidad y mínimos cuadrados), que se lee con las semanas 2 y 3; John F. Monahan, *A Primer on Linear Models*; Bradley Efron y Trevor Hastie, *Computer Age Statistical Inference*, caps. 1-3  
**Herramientas:** Julia 1.11 o posterior, con `LinearAlgebra`, `Random` y `Statistics` (biblioteca estándar), sin paquetes de regresión (`GLM`); `sh`, `curl`, `unzip` y `awk`; `git`; `CairoMakie` y [`Somosaguas`](https://github.com/nuevasomosaguas/somosaguas-makie) para las figuras  
**Evaluación:** entrega de un script ejecutable `.jl` y del proyecto de cierre de la fase I (un script de consola, un script de Julia y su historial de Git), sujetos a integración continua, y prueba de la pizarra (*Blackboard Defence*)

## 1. Marco conceptual: la regresión como proyección ortogonal en $\mathbb{R}^n$

En las facultades de sociología tradicional se enseña la regresión lineal como un algoritmo mecánico para «trazar una línea entre puntos». En la Nueva Somosaguas, la regresión por mínimos cuadrados ordinarios (MCO, en inglés OLS) se entiende desde su naturaleza geométrica: **es la proyección ortogonal del vector de observaciones $\mathbf{y} \in \mathbb{R}^n$ sobre el subespacio $\text{col}(\mathbf{X}) \subset \mathbb{R}^n$ generado por las columnas de la matriz de diseño $\mathbf{X}$**.

1. **La ecuación normal y la condición de ortogonalidad.** Dados un vector de observaciones $\mathbf{y} \in \mathbb{R}^n$ y una matriz de diseño $\mathbf{X} \in \mathbb{R}^{n \times p}$, donde $n$ es el número de sujetos y $p$ el de regresores, incluida la columna de unos del intercepto, buscamos la combinación lineal $\mathbf{\hat{y}} = \mathbf{X}\boldsymbol{\hat{\beta}}$ que minimiza la norma del vector de residuos $\mathbf{e} = \mathbf{y} - \mathbf{\hat{y}}$.

   El punto de $\text{col}(\mathbf{X})$ más cercano a $\mathbf{y}$ es el pie de la perpendicular: la norma de $\mathbf{e}$ es mínima cuando $\mathbf{e}$ es **ortogonal** a cada columna de $\mathbf{X}$. Si no lo fuera, moverse en la dirección de esa columna acortaría $\mathbf{e}$.

   $$
   \mathbf{X}^T \mathbf{e} = \mathbf{0} \implies \mathbf{X}^T (\mathbf{y} - \mathbf{X}\boldsymbol{\hat{\beta}}) = \mathbf{0}
   $$

   Despejando, la ecuación normal da el estimador de MCO:

   $$
   \mathbf{X}^T\mathbf{X}\,\boldsymbol{\hat{\beta}} = \mathbf{X}^T\mathbf{y} \implies \boldsymbol{\hat{\beta}} = (\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T\mathbf{y}
   $$

2. **La matriz sombrero $\mathbf{H}$ y la proyección.** Sustituyendo $\boldsymbol{\hat{\beta}}$, el vector de valores predichos es una transformación lineal de $\mathbf{y}$:

   $$
   \mathbf{\hat{y}} = \mathbf{X}\boldsymbol{\hat{\beta}} = \mathbf{X}(\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T \mathbf{y} = \mathbf{H}\mathbf{y}
   $$

   La matriz $\mathbf{H} = \mathbf{X}(\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T \in \mathbb{R}^{n \times n}$ es un **operador de proyección ortogonal**, con dos propiedades esenciales:
   - **Simetría:** $\mathbf{H}^T = \mathbf{H}$.
   - **Idempotencia:** $\mathbf{H}^2 = \mathbf{H}$; proyectar un vector ya proyectado no altera su posición.

3. **Descomposición de la varianza y teorema de Pitágoras.** Como $\mathbf{1} \in \text{col}(\mathbf{X})$ por la columna del intercepto, $\mathbf{\hat{y}} - \bar{y}\mathbf{1}$ también está en $\text{col}(\mathbf{X})$ y es ortogonal a $\mathbf{e}$. La variación total se descompone entonces sin términos cruzados:

   $$
   \|\mathbf{y} - \bar{y}\mathbf{1}\|^2 = \|\mathbf{\hat{y}} - \bar{y}\mathbf{1}\|^2 + \|\mathbf{e}\|^2 \implies SS_{\text{Tot}} = SS_{\text{Reg}} + SS_{\text{Res}}
   $$

   De ahí la definición del coeficiente de determinación:

   $$
   R^2 = 1 - \frac{SS_{\text{Res}}}{SS_{\text{Tot}}} = \frac{SS_{\text{Reg}}}{SS_{\text{Tot}}}
   $$

4. **El teorema de Gauss-Markov.** Sea el modelo $\mathbf{y} = \mathbf{X}\boldsymbol{\beta} + \boldsymbol{\varepsilon}$. Bajo exogeneidad estricta, $\mathbb{E}[\boldsymbol{\varepsilon} \mid \mathbf{X}] = \mathbf{0}$, y homocedasticidad sin autocorrelación, $\text{Var}(\boldsymbol{\varepsilon} \mid \mathbf{X}) = \sigma^2 \mathbf{I}_n$, el estimador de MCO es **ELIO** (*BLUE*, el estimador lineal insesgado óptimo): tiene la varianza mínima entre todos los estimadores lineales insesgados. Su matriz de varianzas y covarianzas es:

   $$
   \text{Var}(\boldsymbol{\hat{\beta}} \mid \mathbf{X}) = \sigma^2 (\mathbf{X}^T\mathbf{X})^{-1}
   $$

## 2. Código base de referencia (`laboratorio_semana4.jl`)

El script estima la ecuación de ingresos con álgebra matricial pura, comprueba la condición de ortogonalidad $\mathbf{X}^T\mathbf{e} = \mathbf{0}$ y la descomposición de la varianza, y dibuja el panel diagnóstico.

```julia
using CairoMakie, Somosaguas
using LinearAlgebra, Random, Statistics

Random.seed!(42)

# 1. Datos sintéticos de un proceso socioeconómico
#    x1: nivel educativo (años); x2: experiencia laboral (años); y: ingreso anual (miles de €)
n = 200
x1 = 14 .+ 2.5 .* randn(n)
x2 = 10 .+ 4.0 .* randn(n)
y = 15 .+ 2.5 .* x1 .+ 1.2 .* x2 .+ 5.0 .* randn(n)   # relación real con ruido exógeno

# 2. Matriz de diseño X, con la columna de unos del intercepto
X = [ones(n) x1 x2]

# 3. Ecuación normal, XᵀX β̂ = Xᵀy, resuelta como sistema lineal: inv(X' * X) daría
#    la misma β̂ con más error de redondeo
β̂ = (X' * X) \ (X' * y)

# 4. Proyección ortogonal y residuos
ŷ = X * β̂
residuos = y - ŷ
ortogonalidad = X' * residuos   # Xᵀe = 0, salvo error de redondeo

# 5. Descomposición de la varianza y R²
ss_tot = sum(abs2, y .- mean(y))
ss_reg = sum(abs2, ŷ .- mean(y))
ss_res = sum(abs2, residuos)
R² = 1 - ss_res / ss_tot

println("β̂ = ", round.(β̂; digits = 3), "   ‖Xᵀe‖∞ = ", maximum(abs, ortogonalidad), "   R² = ", round(R²; digits = 4))

# 6. Panel diagnóstico: el ajuste y la ortogonalidad de los residuos, lado a lado
set_theme!(tema_somosaguas())
fig = Figure(size = (1400, 550))
ax1 = Axis(fig[1, 1]; title = "Predicción frente a realidad, R² = $(round(R²; digits = 3))",
    xlabel = "Ingreso predicho ŷ (miles de €)", ylabel = "Ingreso observado y (miles de €)")
ablines!(ax1, 0, 1; color = :gray, linestyle = :dash)   # el ajuste perfecto, y = ŷ
scatter!(ax1, ŷ, y; markersize = 10)
ax2 = Axis(fig[1, 2]; title = "Residuos frente a educación, x₁ᵀe = 0",
    xlabel = "Años de educación, x₁", ylabel = "Residuo, e = y − ŷ")
hlines!(ax2, [0]; color = :gray, linestyle = :dash)
scatter!(ax2, x1, residuos; markersize = 10)
resultados = mkpath(joinpath(@__DIR__, "resultados"))
save(joinpath(resultados, "regresion_matricial.png"), fig; px_per_unit = 1.5)
```

La ecuación normal se resuelve como sistema lineal, con `\`, y no con `inv(X' * X)`: con la inversa sale la misma $\boldsymbol{\hat{\beta}}$ a tres decimales, pero $\|\mathbf{X}^T\mathbf{e}\|_\infty$ pasa de $6 \cdot 10^{-11}$ a $5 \cdot 10^{-10}$, y el test de ortogonalidad falla. `X \ y`, la factorización $QR$ de la semana 3, baja a $2 \cdot 10^{-11}$.

## 3. Ejercicios

### Ejercicio 1: multicolinealidad casi perfecta y colapso de $(\mathbf{X}^T\mathbf{X})^{-1}$

Añade una tercera variable explicativa $x_3$ que sea casi una combinación lineal exacta de las dos anteriores: $x_3 = 0.99 \, x_1 + 0.01 \, x_2 + \epsilon$, con $\epsilon \sim \mathcal{N}(0, 0.001^2)$.

- **Tarea:** calcula el **número de condición** $\kappa(\mathbf{X}^T\mathbf{X}) = \frac{\lambda_{\text{máx}}}{\lambda_{\text{mín}}}$ con `cond(X' * X)` y observa cómo infla los elementos diagonales de $\text{Var}(\boldsymbol{\hat{\beta}}) = \sigma^2 (\mathbf{X}^T\mathbf{X})^{-1}$, el origen de los factores de inflación de la varianza (VIF).
- **Pregunta causal:** explica geométricamente por qué la colinealidad vuelve inestable el plano de proyección y sensible a pequeñas perturbaciones de los datos, aunque el ajuste global, $R^2$, permanezca prácticamente inalterado.

### Ejercicio 2: demostración empírica del teorema de Gauss-Markov por Monte Carlo

Diseña una simulación Monte Carlo de $B = 10\,000$ réplicas, con $\mathbf{X}$ fija y un ruido nuevo en cada una, que compare el estimador de MCO, $\boldsymbol{\hat{\beta}}_{\text{MCO}} = (\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T\mathbf{y}$, con un estimador lineal insesgado alternativo pero no óptimo, $\boldsymbol{\tilde{\beta}} = \mathbf{W}\mathbf{y}$. Cualquier $\mathbf{W}$ con $\mathbf{W}\mathbf{X} = \mathbf{I}$ es insesgado; por ejemplo, los mínimos cuadrados ponderados con pesos arbitrarios, $\mathbf{W} = (\mathbf{X}^T\boldsymbol{\Omega}\mathbf{X})^{-1}\mathbf{X}^T\boldsymbol{\Omega}$, con $\boldsymbol{\Omega}$ diagonal de elementos positivos y distintos.

- **Tarea:** calcula la matriz de varianzas y covarianzas empírica de ambos estimadores a lo largo de las 10 000 réplicas.
- **Pregunta causal:** verifica que la diferencia $\text{Var}(\boldsymbol{\tilde{\beta}}) - \text{Var}(\boldsymbol{\hat{\beta}}_{\text{MCO}})$ es **semidefinida positiva** (sus autovalores, `eigvals`, son no negativos), como garantiza Gauss-Markov.

### Ejercicio 3: apalancamiento (*leverage*), puntos influyentes y distancia de Cook

El apalancamiento de cada observación $i$ es el elemento diagonal $h_{ii}$ de la matriz sombrero $\mathbf{H} = \mathbf{X}(\mathbf{X}^T\mathbf{X})^{-1}\mathbf{X}^T$.

- **Tarea:** modifica un único punto de la muestra para convertirlo en un valor extremo en el espacio de los regresores (por ejemplo, $x_{1} = 35$) con un $y$ atípico.
- **Pregunta causal:** programa la **distancia de Cook**, con $s^2 = \|\mathbf{e}\|^2 / (n - p)$:

  $$
  D_i = \frac{e_i^2}{p \, s^2} \left[ \frac{h_{ii}}{(1 - h_{ii})^2} \right]
  $$

  Identifica las observaciones que superan el umbral convencional $D_i > 4/n$ y dibuja la deformación que sufre el hiperplano de proyección al incluir o excluir ese punto.

## 4. Proyecto de cierre de la fase I: la ecuación de salarios con microdatos

El código base inventa los ingresos para conocer la verdad; el proyecto los toma de la **[Encuesta de Estructura Salarial 2022](https://www.ine.es/dyngs/INEbase/es/operacion.htm?c=Estadistica_C&cid=1254736177025&menu=resultados&idp=1254735976596)** del INE: 240 490 asalariados, uno por registro, en un archivo de texto de ancho fijo. Reúne las cuatro semanas de la fase: la consola de la semana 2 para limpiar los microdatos, el Gram-Schmidt modificado y la sustitución hacia atrás de las semanas 2 y 3 para estimar, y Git para entregar.

**Los datos.** [`datos_2022.zip`](https://www.ine.es/ftp/microdatos/salarial/datos_2022.zip) (77 MB) trae los microdatos en `md_EES_2022.txt`, de ancho fijo y con finales de línea `\r\n`, y su diseño de registro en `dr_EES_2022.json` y `dr_EES_2022.xlsx`: la posición y la longitud de cada variable. Las que hacen falta:

| Variable | Posición | Longitud | Contenido |
| :--- | ---: | ---: | :--- |
| `SEXO` | 18 | 1 | 1, hombre; 6, mujer |
| `ESTU` | 23 | 1 | Estudios, de 1 (menos que primaria) a 7 (licenciatura o doctorado) |
| `ANOANTI` | 24 | 2 | Años de antigüedad en la empresa |
| `TIPOJOR` | 28 | 1 | Jornada: 1, completa; 2, parcial |
| `DRELABAM` | 126 | 2 | Meses trabajados en el año |
| `RETRINOIN` | 146 | 10 | Salario bruto anual no derivado de incapacidad temporal, en euros |
| `RETRIIN` | 156 | 10 | Salario bruto anual derivado de incapacidad temporal, en euros |

Los microdatos no entran en el repositorio: se descargan del INE, que permite reutilizarlos citando la fuente.

**1. Limpieza en la consola (`semana-04/limpiar.sh`).** Un script POSIX que descarga el zip en `semana-04/datos/` si no está, con `curl`, y con `unzip -p` y `awk` escribe `semana-04/datos/ees2022.csv`, con la cabecera `mujer,estudios,antiguedad,salario` y una fila por cada asalariado a jornada completa (`TIPOJOR` = 1) que trabajó los doce meses (`DRELABAM` = 12) y cobró un salario anual positivo: `mujer` es 1 o 0, y `salario`, la suma de `RETRINOIN` y `RETRIIN` con dos decimales. Quedan 170 521 filas. Las rutas son relativas a `semana-04/`, desde donde se ejecuta.

**2. Estimación en Julia (`semana-04/proyecto.jl`).** El script lee el CSV, forma la matriz de diseño en este orden:

$$
\mathbf{X} = \big[\, \mathbf{1}, \; \text{mujer}, \; \text{antigüedad}, \; \text{antigüedad}^2, \; \mathbb{I}[\text{estudios} = 2], \dots, \mathbb{I}[\text{estudios} = 7] \,\big] \in \mathbb{R}^{170\,521 \times 10}
$$

con $\mathbf{y} = \log(\text{salario})$, y estima $\boldsymbol{\hat\beta}$ con `minimos_cuadrados_mgs` de la semana 3, es decir, Gram-Schmidt modificado sobre $[\mathbf{X} \; \mathbf{y}]$ y sustitución hacia atrás. Guarda `X_ees`, `y_ees` y `β_ees` con esos nombres, y deja en `semana-04/resultados/` una figura con la prima salarial de cada nivel de estudios.

**3. Entrega con Git.** El historial muestra el trabajo en commits pequeños, y `.gitignore` excluye `semana-04/datos/`: ni el zip ni el CSV se comprometen.

**Preguntas para la pizarra:**

- **La brecha:** con los mismos estudios y la misma antigüedad, ¿cuánto menos cobra una mujer, en porcentaje? Pasa el coeficiente de $\log(\text{salario})$ a porcentaje con $e^{\hat\beta} - 1$, y explica por qué el coeficiente no es una medida de discriminación: ¿qué variables que influyen en el salario faltan en $\mathbf{X}$, y cómo sesgan $\hat\beta_{\text{mujer}}$?
- **El condicionamiento:** calcula $\kappa(\mathbf{X})$, en torno a $2 \cdot 10^4$, y vuelve a calcularlo con la antigüedad centrada en su media: baja a unos $7 \cdot 10^3$. ¿Qué par de columnas casi colineales explica esa bajada, qué explica el resto, y por qué centrar no cambia ni $\hat{\mathbf{y}}$ ni $R^2$?
- **Los pesos:** cada registro lleva un factor de elevación, `FACTOTAL` (posición 195, longitud 12), que dice a cuántos asalariados representa. Estima la misma ecuación por mínimos cuadrados ponderados con esos pesos. ¿Contradice el resultado el teorema de Gauss-Markov?

## 5. Criterio de verificación por integración continua

La entrega es `semana-04/laboratorio_semana4.jl`, con el proyecto, `semana-04/limpiar.sh` y `semana-04/proyecto.jl`, en el repositorio de la asignatura. Con cada push, la integración continua ejecuta `semana-04/test_semana4.jl`, y la semana se supera si:

1. Ningún script usa paquetes de regresión (`GLM`, `FixedEffectModels`, `MLJ`, ni una función `lm`): toda la estimación se deriva con productos matriciales y la resolución de sistemas lineales.
2. `laboratorio_semana4.jl` se ejecuta sin excepciones ni advertencias en Julia 1.11 o posterior, y deja el panel diagnóstico en PNG en `semana-04/resultados/`.
3. Supera el test unitario `test_ortogonalidad`, que comprueba que los residuos son los de la proyección de $\mathbf{y}$ sobre $\text{col}(\mathbf{X})$ y que $\|\mathbf{X}^T \mathbf{e}\|_\infty < 10^{-10}$.
4. Supera el test unitario `test_descomposicion_varianza`, que comprueba que $SS_{\text{Reg}} + SS_{\text{Res}} = SS_{\text{Tot}}$ dentro de la tolerancia del punto flotante. Estos tests leen `X`, `y`, `residuos`, `ss_tot`, `ss_reg` y `ss_res`: el script conserva esos nombres del código base.
5. `sh limpiar.sh`, ejecutado en `dash`, deja `datos/ees2022.csv` con exactamente las filas que el test lee por su cuenta del ancho fijo, en el mismo orden, con el salario al céntimo.
6. `proyecto.jl` se ejecuta sin advertencias, su `X_ees` es la matriz de diseño en el orden indicado, su `β_ees` coincide con `X_ees \ y_ees` y sale de su propia `minimos_cuadrados_mgs`, cuyo `mgs` es Gram-Schmidt modificado, y deja su figura.
7. `semana-04/datos/` está excluida por `.gitignore` y sin archivos en el repositorio.

Antes de enviarlo, el mismo test se pasa en la terminal, dentro del repositorio; la primera vez descarga los 77 MB de la encuesta:

```sh
julia --project=semana-04 -e 'using Pkg; Pkg.instantiate()'
julia --project=semana-04 --depwarn=yes semana-04/test_semana4.jl
```
