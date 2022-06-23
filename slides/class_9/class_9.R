## -----------------------------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(rvest))
library(httr)
library(knitr)

opts_chunk$set(cache.path = "class_9_files/class_9_cache/html/",
               fig.align = 'center')


## -----------------------------------------------------------------------------
resp <- GET('https://es.wikipedia.org/w/api.php',
            query = list(action = 'query',
                         list = 'search',
                         srsearch = 'web scraping',
                         srlimit = 5,
                         format = 'json'),
            add_headers('Accept-Encoding' = 'gzip'))

df <- content(resp, as = 'text') |> 
  jsonlite::fromJSON()

df$query$search |> as_tibble()


## -----------------------------------------------------------------------------
resp <- GET('https://es.wikipedia.org/w/api.php',
            query = list(action = 'parse',
                         page = 'Web scraping', # contenido de título de página
                         prop = 'text', # html de retorno
                         format = 'json'),
            add_headers('Accept-Encoding' = 'gzip'))

df <- content(resp, as = 'text') |> jsonlite::fromJSON()

str(df, 2)


## -----------------------------------------------------------------------------
df$parse$text$`*` |> 
  read_html() |> html_text() |> 
  cat()


## -----------------------------------------------------------------------------
resp <- GET('https://es.wikipedia.org/w/api.php',
            query = list(action = 'query',
                         titles = 'Web scraping|Python', # Varios títulos a la ves.
                         prop = 'info|categories|iwlinks', # Información a obtener.
                         format = 'json'),
            add_headers('Accept-Encoding' = 'gzip'))

df <- content(resp, as = 'text') |> jsonlite::fromJSON()

str(df, 3)


## -----------------------------------------------------------------------------
df$query$pages |> 
  enframe() |> unnest_wider(value)


## -----------------------------------------------------------------------------
library(WikipediR)

info_wiki <- page_info(
  language = 'es', 
  project = 'wikipedia', 
  page = 'Web_scraping|Python') 


## -----------------------------------------------------------------------------
str(info_wiki, 3)


## -----------------------------------------------------------------------------
info_wiki$query$pages |> 
  enframe() |> unnest_wider(value)


## -----------------------------------------------------------------------------
cont_wiki <-  page_content(language = 'es', 
                           project = 'wikipedia', 
                           page_name = 'Web_scraping')

str(cont_wiki) # Una lisa parse con 4 elementos dentro


## -----------------------------------------------------------------------------
cont_wiki$parse$text$`*` |> # Texto del requerimiento
  read_html() |> html_text() |> 
  cat()


## -----------------------------------------------------------------------------
s_met <- GET('https://api.spotify.com/v1/search',
             query = list(q = 'genre:metal', 
                          market = 'CL', 
                          type = 'artist', 
                          limit = 8),
             accept_json(),
             add_headers(Authorization = str_glue("Bearer {spotifyr::get_spotify_access_token()}")))

df_met <- s_met |> content('text') |> 
  jsonlite::fromJSON()

df_met$artists$items |> 
  as_tibble() |> unpack(followers, names_repair = 'minimal') |>
  select(id, name, popularity, total)


## -----------------------------------------------------------------------------
library(spotifyr)

df_met <- get_genre_artists('metal', limit = 8)
df_met |> 
  select(id, name, popularity, followers.total)


## -----------------------------------------------------------------------------
df_pod <- search_spotify(q = 'podcast', type = 'show', market = 'CL', limit = 10)
df_pod |> 
  select(id, name, total_episodes, description)


## -----------------------------------------------------------------------------
df_top <- get_playlist('37i9dQZEVXbL0GavIqMTeb') # ID de la lista.
df_top_track <- df_top$tracks$items |> as_tibble() |> distinct()

suppressMessages(
  # Seleccionar y limpiar solo alguna de las variables disponibles
  df_top_track_sel <- df_top_track |> 
    mutate(track.id, track.name, track.popularity, track.album.release_date, 
           name = map(track.album.artists, 'name'),
           .keep = 'none') |> 
    unnest_wider(name, names_repair = 'unique')
)

df_top_track_sel |> head()


## -----------------------------------------------------------------------------
df_track_af <- get_track_audio_features(df_top_track_sel$track.id)

head(df_track_af)


## -----------------------------------------------------------------------------
df_top_track_sel <- bind_cols(df_top_track_sel, df_track_af)

gg <- df_top_track_sel |> 
  mutate(pos = row_number()) |>
  pivot_longer(cols = c(danceability, energy, speechiness, acousticness, liveness, liveness),
               names_to = 'variable', values_to = 'valor') |> 
  ggplot(aes(x = variable, y = valor, colour = track.popularity)) +
  geom_point(aes(size = rev(pos)),
             alpha = 0.5,
             show.legend = FALSE) + theme_minimal() +
  labs(title = 'Características de las 100 canciones en Chile',
       subtitle = 'Lista Top 50 — Chile, Spotify', x = NULL)


## ---- fig.height=4------------------------------------------------------------
gg


## -----------------------------------------------------------------------------
suppressPackageStartupMessages(library(rtweet))

rtweet::auth_setup_default() # pedir credenciales


## -----------------------------------------------------------------------------
rtweet::auth_get() # ver credenciales


## -----------------------------------------------------------------------------
tweets <- rtweet::get_timeline('rstudio')
dim(tweets)


## -----------------------------------------------------------------------------
tweets |> 
  select(id, created_at, text) |> head()


## -----------------------------------------------------------------------------
f_date_for_twitter <- function(.date){
  .date |>
    lubridate::with_tz(tzone = 'UCT') |> # Cambio de zona para pasar de hora chilena a UCT.
    format('%Y-%m-%dT%H:%M:%SZ')
}


## -----------------------------------------------------------------------------
suppressPackageStartupMessages(library(academictwitteR))
tuser_id <- get_user_id('rstudio')


## -----------------------------------------------------------------------------
get_user_profile(tuser_id)


## -----------------------------------------------------------------------------
tweets_user <- academictwitteR::get_user_timeline(
  x = tuser_id,
  start_tweets = f_date_for_twitter(as.Date('2022-06-17')),
  end_tweets = f_date_for_twitter(as.Date('2022-06-23')),
  bearer_token = Sys.getenv('TWITTER_BEARER_CAA')) |> 
  as_tibble()

tweets_user |> 
  select(id, created_at, text)


## -----------------------------------------------------------------------------
try(
  get_all_tweets(
    query = '"Encuesta CEP"',
    start_tweets = f_date_for_twitter(as.Date('2022-06-17')),
    end_tweets = f_date_for_twitter(as.Date('2022-06-23')),
    bearer_token = Sys.getenv('TWITTER_BEARER_CAA')) # Error con este token.
)


## -----------------------------------------------------------------------------
tweets_tema <- get_all_tweets(
  query = '"Encuesta CEP"',
  start_tweets = f_date_for_twitter(as.Date('2022-06-17')),
  end_tweets = f_date_for_twitter(as.Date('2022-06-23')),
  bearer_token = Sys.getenv('TWITTER_BEARER')) |> as_tibble()


## -----------------------------------------------------------------------------
tweets_tema |> 
  select(id, created_at, text) |> 
  head()


## -----------------------------------------------------------------------------
tweetsr_tema <- rtweet::stream_tweets(query = '"Encuesta CEP"')

tweetsr_tema |> 
  select(id, created_at, text) |> 
  head()


## -----------------------------------------------------------------------------
library(RTwitterV2)

tweets_tema <- get_timelines_v2(user_id = tuser_id, n = 100, 
                                token = Sys.getenv('TWITTER_BEARER_CAA')) |> 
  as_tibble()

tweets_tema |> 
  select(conversation_id, created_at, text) |> 
  head()


## -----------------------------------------------------------------------------
tweets_tema <- recent_search(search_query = "Encuesta CEP",
                             start_time = f_date_for_twitter(as.Date('2022-06-17')),
                             end_time = f_date_for_twitter(as.Date('2022-06-23')),
                             n = 100,
                             token = Sys.getenv('TWITTER_BEARER_CAA')) |> 
  as_tibble()

tweets_tema |> 
  select(conversation_id, created_at, text) |> 
  head()


## -----------------------------------------------------------------------------
# Extraer código R
knitr::purl('class_9.Rmd',
            output = 'class_9.R',
            quiet = TRUE)

