## -----------------------------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(rvest))
library(knitr)
opts_chunk$set(cache.path = "class_3_files/class_3_cache/html/")


## ---- echo=FALSE--------------------------------------------------------------
x <- htmltools::includeHTML("./class_3_files/scraping_con_css.html")

x |> gsub('<!DOCTYPE html>\n', '', x = _)


## ---- echo=FALSE--------------------------------------------------------------
if(interactive()){
  url <- 'slides/class_3/class_3_files/scraping_con_css.html'
} else {
  url <- './class_3_files/scraping_con_css.html'
}


## -----------------------------------------------------------------------------
(html <- read_html(x = url))


## -----------------------------------------------------------------------------
html |> html_elements('table') |> html_table()


## .img-height-medio p img{

##   height: 500px;

## }


## -----------------------------------------------------------------------------
(df_img_perros <- html |> html_element('#tabla-imagen-perros') |> 
   html_table())


## -----------------------------------------------------------------------------
(src_img_perros <- html |> html_elements('#tabla-imagen-perros') |> 
   html_elements('img') |> 
   html_attr('src'))


## -----------------------------------------------------------------------------
# Uso rbind porque tiene menos salvaguardas que `bind_rows`.
(df_img_perros <- base::rbind(df_img_perros,
                              src_img_perros))


## -----------------------------------------------------------------------------
df_img_perros |> 
  t() |> as.data.frame() |>
  setNames(nm = c('raza', 'fuente', 'img_src'))


## -----------------------------------------------------------------------------
html |> html_element('#first') |> html_text()


## -----------------------------------------------------------------------------
html |> html_elements('p') |> html_text()


## -----------------------------------------------------------------------------
html |> html_elements('p b') |> html_text()


## -----------------------------------------------------------------------------
html |> html_elements('a[href]')


## -----------------------------------------------------------------------------
html |> html_elements('[alt*=akita]')


## -----------------------------------------------------------------------------
url <- 'http://books.toscrape.com/'
html <- read_html(paste0(url, 'index.html'))


## -----------------------------------------------------------------------------
l_cat <- html |> html_elements('.side_categories a')

head(l_cat, 2)


## -----------------------------------------------------------------------------
df_cat <- tibble(categoria = l_cat |> html_text(),
                 link      = l_cat |> html_attr('href')) |> 
  mutate(categoria = stringr::str_squish(categoria))

head(df_cat, 2)


## ---- cache=TRUE--------------------------------------------------------------
df_cat_hojas <- df_cat |> 
  rowwise() |> 
  mutate(pagina = list(read_html(paste0(url, link))))

head(df_cat_hojas, 3)


## -----------------------------------------------------------------------------
html |> html_elements('.form-horizontal strong:first-of-type') |> html_text()


## -----------------------------------------------------------------------------
df_cat_hojas <- df_cat_hojas |> 
  mutate(n_libros = html_elements(pagina, '.form-horizontal strong:first-of-type') |> html_text()) |> 
  ungroup() |> # evito que data.frame siga agrupada por filas.
  mutate(n_libros = as.integer(n_libros))

df_cat_hojas |> head(3)


## ---- fig.dim=c(14, 4)--------------------------------------------------------
df_cat_hojas |> 
  filter(n_libros < 1000) |> 
  ggplot(aes(x = fct_reorder(categoria, -n_libros), y = n_libros)) + 
  geom_col() + 
  scale_x_discrete(NULL, guide = guide_axis(angle = 90)) +
  labs(title = 'Número de libros por categoría') + theme_minimal()


## -----------------------------------------------------------------------------
# Extraer código R
knitr::purl('class_3.Rmd',
            output = 'class_3.R',
            quiet = TRUE)

