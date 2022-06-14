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
                        username = 'caayala',
                        password = Sys.getenv('GPASS'))

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
# Crear el query a partir del link anterior:

url_portal_render$query <- list(p_l_id = 10230,
                                p_p_id = 'DatosPersonales_WAR_LPT022_DatosPersonales',
                                p_p_lifecycle = 0,
                                p_p_state = 'normal',
                                p_p_mode = 'view',
                                p_p_col_id = 'column-1',
                                p_p_col_pos = 0,
                                p_p_col_count = 1)

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

status_code(home_s)

home_html <- home_s |> 
  read_html() 

# EJERCICIO:
# ¿Está la tabla de interés?

# No encontramos lo que buscamos:
home_html |> 
  html_elements('.overflow-auto')
  
# No hay un formulario.
html_form(home_html)


# EJERCICIO:
# Buscar el *request* que entrega la información con los datos municipales.

# El servidor entrega resultados desde:
url_consulta <- 'https://www.ciudadesamigables.cl/api/comunas-filters/'

home_input <- home_html |> 
  html_elements('input')

# EJERCICIO:
# Construir y capturar ese link. ¿Qué sucede?

web_token <- setNames(home_input |> html_attr('value'),
                      paste0('X-', home_input |> html_attr('name')))

x_data <- session_jump_to(home_s,
                          url_consulta,
                          add_headers('X-Requested-With' = 'XMLHttpRequest',
                                      web_token),
                          accept_json(),
                          query = list(page = 1,
                                       status = '1|2|3|4|5|6',
                                       cycle = '1|2'))
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
  data <- session_jump_to(home_s,
                          url_consulta,
                          add_headers('X-Requested-With' = 'XMLHttpRequest',
                                      web_token),
                          accept_json(),
                          query = list(page = .page,
                                       status = '1|2|3|4|5|6',
                                       cycle = '1|2'))
  data <- data$response |> 
    content(type = 'text') |> 
    jsonlite::fromJSON()
  
  # Pausa para no recargar el servidor.
  Sys.sleep(1)
  
  data$comunas
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
library(lubridate)

# Base de datos de tweets
df_tweets_all <- readRDS('slides/class_6/class_6_taller/df_tweets_encuesta_cep.rds')

start_date <- as.POSIXct('2022-06-09 11:00:00', tz = Sys.timezone())
end_date   <- as.POSIXct('2022-06-09 23:59:00', tz = Sys.timezone())

f_date_for_twitter <- function(.date){
  .date |>
    with_tz(tzone = 'UCT') |> # Cambio de zona para pasar de hora chilena a UCT.
    format('%Y-%m-%dT%H:%M:%SZ')
}

tweets_n <- academictwitteR::count_all_tweets(query = '#EncuestaCEP OR \"Encuesta CEP\"',
                                              start_tweets = f_date_for_twitter(start_date), #UCT-4
                                              end_tweets   = f_date_for_twitter(end_date))
tweets_n

if(!exists('df_tweets_all')){
  df_tweets_all <- academictwitteR::get_all_tweets(query = "#EncuestaCEP",
                                                   start_tweets = f_date_for_twitter(start_date), #UCT-4
                                                   end_tweets   = f_date_for_twitter(end_date),
                                                   n = 20000,
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
  
  df_users |> 
    saveRDS('slides/class_6/class_6_taller/df_users_encuesta_cep.rds')
}

df_tweets_usuario <- left_join(df_tweets_all |> select(id, text, author_id, created_at),
                              df_users |> select(author_id = id, username, name),
                              by = 'author_id') |> 
  as_tibble()

# Convierto fecha
df_tweets_usuario <- df_tweets_usuario |> 
  mutate(created_at_min = strptime(created_at, '%Y-%m-%dT%H:%M:%S.000Z', tz = 'UTC'),
         created_at_min = with_tz(created_at_min, 'America/Santiago'),
         created_at_min = lubridate::floor_date(created_at_min, unit = '15 mins'),
         created_at_min = as.POSIXct(created_at_min))

df_tweets_usuario |> 
  select(created_at, created_at_min)

# Gráfico
df_tweets_n <- df_tweets_usuario |> 
  count(created_at_min,
        mención = if_else(str_detect(text, '#EncuestaCEP'),
                          '#EncuestaCEP',
                          'Encuesta CEP'))

df_tweets_usuario$created_at_min |> class()

ggplot(df_tweets_n,
       aes(x = created_at_min,
           y = n,
           colour = mención)) +
  geom_line() +
  scale_x_datetime('Hora',
                   date_labels ="%H",
                   breaks = '1 hours') +
  labs(title = 'Tweets con hashtag #EncuestaCEP') +
  theme_minimal()

