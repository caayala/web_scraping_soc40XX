
<!-- README.md is generated from README.Rmd. Please edit that file -->

### Web Scraping y acceso a datos desde la web

<!-- badges: start -->
<!-- badges: end -->

Este repositorio contiene el material del curso Web Scraping y acceso a
datos desde la web, dictado el primer semestre de 2022 por el
Departamento de Sociología de la Universidad Católica de Chile a
estudiantes de educación continua como parte del
[`Diplomado en WebScraping y visualización de datos sociales en R`](https://educacioncontinua.uc.cl/43873-ficha-diplomado-en-webscraping-y-visualizacion-de-datos-sociales-en-r).

El programa de este curso se encuentra [`acá`](files/01-programa.pdf).

Al final de este curso los alumnos debiesen tener la capacidad de
acceder a nuevas fuentes de datos para su análisis. Esta habilidad es de
gran utilidad práctica porque más y más información es generada,
almacenada y —de alguna manera— disponible en Internet.

El sitio web del curso es
<https://caayala.github.io/web_scraping_soc40XX/>.

------------------------------------------------------------------------

#### Calendario

Tendremos clases teóricas (T) y prácticas (P).

| Clase | fecha      | tipo | contenido                                          | Paquetes                                                                                       | entrega      | link/grabación zoom | material                                                                                                    |
|------:|:-----------|:-----|:---------------------------------------------------|:-----------------------------------------------------------------------------------------------|:-------------|:--------------------|:------------------------------------------------------------------------------------------------------------|
|     1 | 2022-05-24 | T    | Introducción a Web Scraping                        | [`rvest`](https://rvest.tidyverse.org)                                                         |              |                     | [Slides](slides/class_1/class_1#1) [.Rmd](slides/class_1/class_1.Rmd)                                       |
|     2 | 2022-05-26 | P    | Repaso R: manejo de listas y expresiones regulares | [`purrr`](https://purrr.tidyverse.org) [`stringr`](https://stringr.tidyverse.org)              |              |                     | [Slides](slides/class_2/class_2#1) [.Rmd](slides/class_2/class_2.Rmd) [.R](slides/class_2/class_2_taller.R) |
|     3 | 2022-05-31 | T    | Web Scraping                                       | [`rvest`](https://rvest.tidyverse.org)                                                         |              |                     | [Slides](slides/class_3/class_3#1) [.Rmd](slides/class_3/class_3.Rmd)                                       |
|     4 | 2022-06-02 | P    | Web Scraping                                       | [`rvest`](https://rvest.tidyverse.org)                                                         | C1 (20%)     |                     | [Slides](slides/class_4/class_4#1) [.Rmd](slides/class_4/class_4.Rmd) [.R](slides/class_4/class_4_taller.R) |
|     5 | 2022-06-07 | T    | Web Scraping avanzado                              | [`rvest`](https://rvest.tidyverse.org), [`httr`](https://httr.r-lib.org)                       |              |                     | [Slides](slides/class_5/class_5#1) [.Rmd](slides/class_5/class_5.Rmd)                                       |
|     6 | 2022-06-09 | P    | Web Scraping avanzado                              | [`rvest`](https://rvest.tidyverse.org), [`httr`](https://httr.r-lib.org)                       | C2 (20%)     |                     | [Slides](slides/class_6/class_6#1) [.Rmd](slides/class_6/class_6.Rmd) [.R](slides/class_6/class_6_taller.R) |
|     7 | 2022-06-14 | T    | Integración de R con Google Sheets                 | [`googlesheets4`](https://googlesheets4.tidyverse.org)                                         |              |                     | [Slides](slides/class_7/class_7#1) [.Rmd](slides/class_7/class_7.Rmd)                                       |
|     8 | 2022-06-16 | P    | Integración de R con Google Sheets                 | [`googlesheets4`](https://googlesheets4.tidyverse.org)                                         | Propuesta TF |                     | [Slides](slides/class_8/class_8#1) [.Rmd](slides/class_8/class_8.Rmd)                                       |
|     9 | 2022-06-23 | T    | Uso de APIs: Spotify y Twitter                     | [`rtweet`](https://docs.ropensci.org/rtweet/) [`spotifyr`](https://www.rcharlie.com/spotifyr/) |              |                     | [Slides](slides/class_9/class_9#1) [.Rmd](slides/class_9/class_9.Rmd)                                       |
|    10 | 2022-06-28 | P    | Uso de APIs: Spotify y Twitter                     | [`rtweet`](https://docs.ropensci.org/rtweet/) [`spotifyr`](https://www.rcharlie.com/spotifyr/) | C3 (20%)     |                     |                                                                                                             |
|    11 | 2022-06-30 | T    | Recuento                                           |                                                                                                | TF (40%)     |                     |                                                                                                             |

#### Evaluaciones

-   Control 1 (20%): Captura de página web.
    [Instrucciones](./homework/c_1).
    [Respuesta](./homework/c_1_answers.pdf)

-   Control 2 (20%): Captura datos de cine chileno.
    [Instrucciones](./homework/c_2).
    [Respuesta](./homework/c_2_answers.pdf)

-   Control 3 (20%): Análisis de canciones.
    [Instrucciones](./homework/c_3).

-   Trabajo Final (40%):

------------------------------------------------------------------------

#### Requisitos

-   Descargar e instalar [R 4.2](https://cran.r-project.org)

#### Recursos de aprendizaje

-   [CSS Diner](https://flukeout.github.io): It’s a fun game to learn
    and practice CSS selectors. Repo en
    [Github](https://github.com/flukeout/css-diner)

#### Lecturas y referencias

-   **R for Data Science (2e)** (Hadley Wickham & Garrett Grolemund)
    [web](https://r4ds.hadley.nz/index.html). Trabajo en desarrollo.
-   **`rvest` Web scraping 101**
    [web](https://rvest.tidyverse.org/articles/rvest.html)
-   **Web Scraping Reference: Cheat Sheet for Web Scraping using R**
    [github](https://github.com/yusuzech/r-web-scraping-cheat-sheet)
-   **`purrr` cheatsheet**
    [pdf](https://raw.githubusercontent.com/rstudio/cheatsheets/main/purrr.pdf)
-   **`stringr` cheatsheet**
    [pdf](https://raw.githubusercontent.com/rstudio/cheatsheets/main/strings.pdf)
