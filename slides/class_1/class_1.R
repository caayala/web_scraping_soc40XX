## -----------------------------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))
library(knitr)
opts_chunk$set(cache.path = "class_1_files/class_1_cache/html/")


## -----------------------------------------------------------------------------
library(rvest)
url <- 'class_1_files/mi_primer_scraping.html'

html <- read_html(x = url)
html


## -----------------------------------------------------------------------------
html |> html_element('body')


## -----------------------------------------------------------------------------
html |> html_element('p')


## -----------------------------------------------------------------------------
html |> html_element('#first') |> html_text()


## -----------------------------------------------------------------------------
html |> html_element('img') |> html_attr('src')


## -----------------------------------------------------------------------------
html |> html_element('img') |> html_attrs()


## -----------------------------------------------------------------------------
html |> html_element('body') |> html_children() |> html_name()


## -----------------------------------------------------------------------------
url <- 'https://es.wikipedia.org/wiki/Star_Wars'
html <- read_html(url)

df_tablas <- html |> 
  html_elements('table.wikitable') |>  html_table()

df_tablas |> str(1)


## -----------------------------------------------------------------------------
df_tablas[[5]] |> head(3)


## -----------------------------------------------------------------------------
df_tablas[[6]] |> head(3)


## -----------------------------------------------------------------------------
df_recaudacion <- df_tablas[[5]]
names(df_recaudacion) <- as.character(df_recaudacion[1, ])
  
df_recaudacion <- df_recaudacion |> 
  filter(str_detect(Película, 'Star Wars')) |> 
  mutate(across(3:5, str_remove_all, '\\.'), # Eliminar '.' en números
         across(3:5, as.integer))


## -----------------------------------------------------------------------------
df_recaudacion$Película <- df_recaudacion$Película |> 
  str_remove('Star Wars: ') |> 
  str_extract('(?<= - ).*(?=\\[)|(^.*(?=:))')

df_recaudacion$Película[df_recaudacion$Película == 'The Empire Strikes Back'] <- 'Empire Strikes Back'
df_recaudacion$Película[df_recaudacion$Película == 'Rise of Skywalker'] <- 'The Rise of Skywalker'

df_recaudacion |> head(3) # Dejo fuera "The Clone wars"


## -----------------------------------------------------------------------------
df_critica <- df_tablas[[6]]
names(df_critica) <- as.character(df_critica[1, ])
  
df_critica <- df_critica |> 
  filter(!(Película %in% c('Película', 'Promedio'))) |> 
  mutate(across(2:7, str_extract, '\\d.?\\d'), # capturo las notas
         across(6:7, str_replace, '\\,', '\\.'), # reemplazo ',' por '.'
         across(2:5, as.integer)) # transformo strings a numeros.

df_critica |> head(4)


## -----------------------------------------------------------------------------
df_cyr <- left_join(df_critica, df_recaudacion, by = 'Película')

ggplot(df_cyr,
       aes(x = Total, y = General)) + 
  geom_point(size = rel(3)) +
  ggrepel::geom_label_repel(aes(label = Película)) +
  scale_x_continuous('Millones de dólares', labels = ~scales::dollar(., scale = 0.000001)) + 
  labs(title = 'Star Wars: Relación entre recaudación total y crítica (Rottentomatos)')


## -----------------------------------------------------------------------------
# Extraer código R
knitr::purl('class_1.Rmd',
            output = 'class_1.R',
            quiet = TRUE)

