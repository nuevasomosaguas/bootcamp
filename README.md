# bootcamp

Las guías de trabajo, cuadernos de ejercicios y flujos de integración continua (GitHub Actions) para la evaluación automática del código y la sintaxis de los alumnos durante la nivelación estival.

La web se construye con Hugo y el tema de la Nueva Somosaguas (copiado en `themes/somosaguas`): `hugo server` la muestra en <http://localhost:1313>, y cada push a `master` la publica en GitHub Pages. Cada semana es un archivo en `content/semanas/`, con la fecha de su lunes y `weight` igual a su número, que fija el orden de la portada.

Cada `semana-NN/` lleva su `Project.toml` y su `test_semanaN.jl`, que corrige la entrega `laboratorio_semanaN.jl` de esa carpeta; `.github/workflows/semana-NN.yml` lo ejecuta con cada push que la toque.
