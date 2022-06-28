## -----------------------------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(rvest))
library(httr)
library(knitr)

opts_chunk$set(cache.path = "class_10_files/class_10_cache/html/",
               fig.align = 'center')


## -----------------------------------------------------------------------------
url <- 'https://www.mime.mineduc.cl/explorer'
read_html(url) |> 
  html_element('body strong') |> 
  html_text()


## -----------------------------------------------------------------------------
library(chromote)
b <- ChromoteSession$new() # Nuevo navegador.
b1 <- b$new_session() # Nueva "ventana".

# Ir a sitio web de interés
b1$Page$navigate("https://www.mime.mineduc.cl/explorer/")
Sys.sleep(20) # Tiempo para que la página cargue.


## -----------------------------------------------------------------------------
# Se puede ver lo que hace esta "ventana":
# b1$view()


## -----------------------------------------------------------------------------
x1 <- b1$DOM$getDocument()

x1$root |> str(2)


## -----------------------------------------------------------------------------
div_ids <- b1$DOM$querySelectorAll(x1$root$nodeId, "div[id^=id-markermap]")

div_ids$nodeIds |> unlist() |> head()


## -----------------------------------------------------------------------------
try(
  b1$DOM$getOuterHTML(div_ids$nodeIds[[1]])[[1]] |>
    read_html() |>
    html_element('div') |>
    html_attr('id')
)


## -----------------------------------------------------------------------------
try(b1$DOM$getAttributes(div_ids$nodeIds[[1]])$attributes[[4]])


## -----------------------------------------------------------------------------
try(l_uuid <- map_chr(div_ids$nodeIds,
                      ~b1$DOM$getAttributes(.)$attributes[[4]]))
try(length(l_uuid))


## -----------------------------------------------------------------------------
try(l_uuid |> head())


## -----------------------------------------------------------------------------
# Agrandamos el tamaño del navegador.
b1$Browser$setWindowBounds(
  windowId = b1$Browser$getWindowForTarget()$windowId,
  bounds = list(width = 4000, height = 6000)
  )

Sys.sleep(20) # Tiempo para que la página cargue.

if(interactive()){
  b1$view()
}


## -----------------------------------------------------------------------------
div_ids <- b1$DOM$querySelectorAll(x1$root$nodeId, "div[id^=id-markermap]")

l_uuid <- map_chr(div_ids$nodeIds,
                  ~b1$DOM$getAttributes(.)$attributes[[4]])

length(l_uuid)


## -----------------------------------------------------------------------------
if(interactive()){
  l_uuid <- readRDS('slides/class_10/class_10_files/l_uuid_chromote_500.rds')
} else {
  l_uuid <- readRDS('class_10_files/l_uuid_chromote_500.rds')
}



## -----------------------------------------------------------------------------
try(b1$parent$close())


## -----------------------------------------------------------------------------
escuela <- 'Colegio Bicentenario Victoria Prieto'

resp <- POST(url = 'https://api.consiliumbots.com/service-search-engine/search/campuses//',
             query = list(language_code = 'es'),
             accept_json(),
             add_headers('accept-encoding' = 'gzip',
                         'x-index' = 'chile-campuses-master'),
             body = list(search_partial = 'true',
                         search_size = 20,
                         search_term = escuela))


## -----------------------------------------------------------------------------
resp |> content('text') |> jsonlite::fromJSON() |> str(1)


## -----------------------------------------------------------------------------
f_mime_busqueda <- function(.search_term){
  # Recepción de la respuesta
  response <- POST(url = 'https://api.consiliumbots.com/service-search-engine/search/campuses//',
                   query = list(language_code = 'es'),
                   accept_json(),
                   add_headers('accept-encoding' = 'gzip',
                               'x-index' = 'chile-campuses-master'),
                   body = list(search_partial = 'true',
                               search_size = 20,
                               search_term = .search_term))
  
  response |> 
    content('text', encoding = 'UTF-8') |> 
    jsonlite::fromJSON()
}

f_mime_p_response <- function(.response){
  # Respuesta de POST a tibble
  tibble(data        = .response$results,
         search_term = .response$search) |> 
    unpack(data)
}


## -----------------------------------------------------------------------------
df_escuelas <- tibble::tribble(
   ~rbd,                                ~nombre,
  8928L,       "LICEO JOSE VICTORINO LASTARRIA",
  8931L,             "ESCUELA BASICA EL VERGEL",
  8933L,               "ESCUELA DE PROVIDENCIA",
  8992L,    "COLEGIO ALEMAN SANKT THOMAS MORUS"
  )


## -----------------------------------------------------------------------------
df <- f_mime_busqueda(df_escuelas$rbd[1]) 

df_unpack <-  df |> 
  f_mime_p_response()

df_unpack |> select(id, uuid, institution_name, institution_code)


## -----------------------------------------------------------------------------
df <- f_mime_busqueda(df_escuelas$nombre[1]) 

df_unpack <-  df |> 
  f_mime_p_response()

df_unpack |> select(id, uuid, institution_name, institution_code)


## -----------------------------------------------------------------------------
df_rbd <- map(df_escuelas$rbd, 
              f_mime_busqueda) 

df_unpack <-  map_dfr(df_rbd, 
                      f_mime_p_response)

df_unpack |> select(id, uuid, institution_name, institution_code)


## -----------------------------------------------------------------------------
f_uuid_detalle <- function(.uuid){
  jsonlite::fromJSON(str_glue(
    'https://api.consiliumbots.com/explorer-backend/r/chile/institutions/campuses/{.uuid}/'
    ))
}

x <- f_uuid_detalle(df_unpack$uuid[[1]])


## -----------------------------------------------------------------------------
x |> str(1)


## -----------------------------------------------------------------------------
l_info <- map(df_unpack$uuid, 
              f_uuid_detalle)

df_info <- l_info |> 
  enframe() |> 
  unnest_wider(value)

head(df_info, 2)


## -----------------------------------------------------------------------------
df_uuid <- l_uuid[1:20] |> 
  str_remove('id-markermap-') |> 
  map(f_uuid_detalle)

df_uuid <- df_uuid |> 
  enframe() |> 
  unnest_wider(value)

df_uuid


## -----------------------------------------------------------------------------
# Extraer código R
knitr::purl('class_10.Rmd',
            output = 'class_10.R',
            quiet = TRUE)

