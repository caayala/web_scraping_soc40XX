# title: "Lecturas de sitios web"
# subtitle: "Web Scraping y acceso a datos desde la web con R"
# author: Cristián Ayala
# date: 2022-06-09

suppressPackageStartupMessages(library(tidyverse))
library(httr)
library(rvest)

# Ejemplo 1: Mi portal UC ----
# 
# Login a servicio de autentificación de la UC.

url_outh <- 'https://sso.uc.cl/cas/login'

## Usando rvest ----
# 
# Creamos una sesión en con las credenciales de ingreso
s <- session(url = url_outh)

s_form <- html_form(s)[[1]]
s_form <- html_form_set(s_form,
                        username = 'USERNAME',
                        password = 'PASSWORD')

session_submit(s, s_form)


### Cumpleaños ----
# 
# Link para la recepción de cumpleaños
url_captura <- 'https://portal.uc.cl/c/portal/render_portlet?p_l_id=10708&p_p_id=Cumpleannos_WAR_LPT026_SocialCump_INSTANCE_6vV3&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=column-1&p_p_col_pos=1&p_p_col_count=2&currentURL=%2Fweb%2Fhome-community%2Fherramientas%3Fgpi%3D10225'
parse_url(url_captura)

# Crear link para capturar cumpleaños
url_portal_render <- parse_url('https://portal.uc.cl/c/portal/render_portlet')
url_portal_render$query <- list(p_l_id = 10708,
                                p_p_id = 'Cumpleannos_WAR_LPT026_SocialCump_INSTANCE_6vV3',
                                p_p_lifecycle = 0,
                                p_p_state = 'normal',
                                p_p_mode = 'view',
                                p_p_col_id = 'column-1',
                                p_p_col_pos = 1,
                                p_p_col_count = 2)

url_portal_render_cumpleanos <- build_url(url_portal_render)

url_portal_render_cumpleanos

html_cumpleanos <- session_jump_to(s,
                                   url_portal_render_cumpleanos)

html_cumpleanos |> 
  read_html() |>
  html_elements('.table_data') |> 
  html_table()

### Datos personales ----

url_captura <- 'https://portal.uc.cl/c/portal/render_portlet?p_l_id=10230&p_p_id=DatosPersonales_WAR_LPT022_DatosPersonales&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&p_p_col_id=column-1&p_p_col_pos=0&p_p_col_count=1&currentURL=%2Fweb%2Fhome-community%2Fdatos-personales%3Fgpi%3D10225'
parse_url(url_captura)

# EJERCICIO:
# Crear el query a partir del link anterior: url_portal_render_personal





url_portal_render_personal <- build_url(url_portal_render)

html_personal <- session_jump_to(s,
                                 url_portal_render_personal)

html_personal |> 
  read_html() |>
  html_elements('.table_data') |> 
  html_table()


# Ejemplo 2: Ciudades Amigables ----
# 

# EJERCICIO:
# Capturar la información de esta página
url_home <- 'https://www.ciudadesamigables.cl/comunas-amigables/'

home_s <- session(url_home)



# EJERCICIO:
# ¿Está la tabla de interés?




# EJERCICIO:
# Buscar el *request* que entrega la información con los datos municipales.




# EJERCICIO:
# Construir y capturar ese link. ¿Qué sucede?

x_data <- session_jump_to(home_s,
                          url_consulta
                          
                          
                          
                          
                          )

json_comunas <- x_data$response |> 
  content(type = 'text') |> 
  jsonlite::fromJSON()

json_comunas$comunas |> 
  as_tibble()

## Captura de toda la información de las comunas ----

# Páginas de comunas
pages <- 1:39

# Función para capturar la información

# EJERCICIO:
# Construir función para capturar las sucesivas páginas con información.

json_page <- function(.page){

}

df_comunas <- map_dfr(1:2, json_page)

df_comunas |> 
  write_excel_csv('slides/class_6/class_6_taller/df_comunas_amigables.csv')


# Ejemplo 3: Twitter API ----
# 
# Construcción de llamados a APIs como Twitter
# 
# https://developer.twitter.com/en/docs/twitter-api/tweets/search/api-reference/get-tweets-search-recent

response_tweets <- GET("https://api.twitter.com/2/tweets/search/recent",
                       query = list(query = '#EncuestaCEP',
                                    max_results = 100,
                                    expansions = paste0(c('author_id', 
                                                          'geo.place_id'),
                                                        collapse = ','),
                                    place.fields = paste0(c('country'), 
                                                          collapse = ','),
                                    user.fields = paste0(c('username', 
                                                           'verified'), 
                                                         collapse = ','),
                                    tweet.fields = paste0(c('created_at', 
                                                            'lang', 
                                                            'public_metrics', 
                                                            'possibly_sensitive', 
                                                            'source'),
                                                          collapse = ',')),
                       add_headers(Authorization = paste0("Bearer ", Sys.getenv('TWITTER_BEARER_CAA'))))

response_tweets

df_tweets <- response_tweets |> 
  content('text') |> 
  jsonlite::fromJSON()

df_users <- df_tweets$includes$users |> 
  as_tibble()

df_tweets$data |> 
  as_tibble() |> 
  unnest_wider(col = public_metrics)

# Habría que paginar

## academictwitteR: uso de paquetes ----
# 
# Todo este código ya ha sido empaquetado:
# `academictwitteR`
# 
# https://github.com/cjbarrie/academictwitteR
# install.packages("academictwitteR")
# 

library(academictwitteR)

# Base de datos de tweets
df_tweets_all <- readRDS('slides/class_6/class_6_taller/df_tweets_encuesta_cep.rds')

if(!exists('df_tweets_all')){
  df_tweets_all <- academictwitteR::get_all_tweets(query = "#EncuestaCEP",
                                                   start_tweets = '2022-06-08T15:00:00Z', #UCT-4
                                                   end_tweets   = '2022-06-09T20:00:00Z',
                                                   n = 5000,
                                                   bearer_token = Sys.getenv('TWITTER_BEARER'),
                                                   file = 'slides/class_6/class_6_taller/df_tweets_encuesta_cep.rds')
}

df_tweets_all |> 
  as_tibble()

# Todos los tweets entre ambas horas.
df_tweets_all |> 
  count(text, sort = TRUE) |> 
  head()

df_tweets_all |> 
  count(author_id, sort = TRUE) |> 
  head()

# Base de datos de los usuarios que produjeron esos tweets. 

df_users <- readRDS('slides/class_6/class_6_taller/df_users_encuesta_cep.rds')

if(!exists('df_users')){
  df_users <- academictwitteR::get_user_profile(x = unique(df_tweets_all$author_id),
                                                bearer_token = Sys.getenv('TWITTER_BEARER'))
}

df_tweets_usuario <- left_join(df_tweets_all |> select(id, text, author_id, created_at),
                              df_users |> select(author_id = id, username, name),
                              by = 'author_id') |> 
  as_tibble()

df_tweets_usuario
