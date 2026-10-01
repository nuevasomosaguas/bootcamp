# somosaguas-hugo-theme

Tema de Hugo con el diseño de la Nueva Somosaguas: el papel, la tinta y el granate de la web, EB Garamond y Fira Code. La portada es una lista de lo último, con el título a la izquierda (cortado con «…» si no cabe) y la fecha a la derecha; arriba, la marca y el menú; abajo, el pie con el autor.

## Uso

En el entorno de la Nueva Somosaguas, `nueva-web carpeta` crea una web con el tema ya copiado en `themes/somosaguas`, su configuración, páginas de ejemplo y la publicación en GitHub Pages.

Fuera del entorno, se copia este repositorio en `themes/somosaguas` y se configura `hugo.toml`:

```toml
theme = "somosaguas"
defaultContentLanguage = "es"
locale = "es-ES"

[params]
  autor = "Nombre Apellido"
  descripcion = "De qué trata la web, en una línea."
  mainSections = ["entradas", "notas"]   # lo que sale en la portada y en el archivo

[[menus.main]]
  name = "Archivo"
  pageRef = "/archivo"                   # una página con «layout: archivo»

# Las fórmulas, $…$ y $$…$$, las pinta MathJax, que solo se carga en las páginas con fórmulas.
[markup.goldmark.renderer]
  unsafe = true
[markup.goldmark.extensions.passthrough]
  enable = true
  [markup.goldmark.extensions.passthrough.delimiters]
    block = [["$$", "$$"]]
    inline = [["$", "$"]]
```

| Plantilla | Qué pinta |
| :--- | :--- |
| `home.html` | El texto de `content/_index.md` y las diez últimas páginas de `mainSections`, con *Más entradas* si hay más |
| `list.html` | Una sección o una etiqueta, en la misma lista |
| `archivo.html` | Todo lo publicado, por años (`layout: archivo`) |
| `page.html` | Una página, con su fecha y sus etiquetas si es de `mainSections` |
| `_markup/` | Las fórmulas para MathJax y los avisos de Obsidian (`> [!nota] Título`) como recuadros |

Hace falta Hugo 0.146 o posterior. Las tipografías EB Garamond y Fira Code (licencia OFL) vienen en `static/fuentes/`.
