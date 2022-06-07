## -----------------------------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(rvest))
library(httr)
library(knitr)
opts_chunk$set(cache.path = "class_5_files/class_5_cache/html/",
               fig.align = 'center')


## -----------------------------------------------------------------------------
knitr::include_graphics('https://github.com/yusuzech/r-web-scraping-cheat-sheet/raw/master/resources/functions_and_classes.png')


## -----------------------------------------------------------------------------
text <- "¡Hola! Soy Cristián y tengo 43 años"

(text_url <- URLencode(text))


## -----------------------------------------------------------------------------
(URLdecode(text_url))


## -----------------------------------------------------------------------------
httr::GET(url = 'https://blog.desuc.cl/test.html') |> httr::http_status()


## -----------------------------------------------------------------------------
rvest::session(url = 'https://blog.desuc.cl/')


## -----------------------------------------------------------------------------
s_blog <- GET(url = 'https://blog.desuc.cl')

s_blog$request


## -----------------------------------------------------------------------------
knitr::include_graphics('class_5_files/request_blog.png')


## -----------------------------------------------------------------------------
s_blog |> headers() |> enframe() |> mutate(value = as.character(value))


## -----------------------------------------------------------------------------
resp <- GET('http://httpbin.org/get',
            query = list(var1 = "valor1", 
                         var2 = "valor2"), #URL values
            authenticate('usuario', 'clavesegura'),
            user_agent(agent = 'hola mundo'),
            set_cookies(a = 1),
            accept_json(),
            add_headers(class = "Web Scraping UC", year = 2022))


## -----------------------------------------------------------------------------
resp


## -----------------------------------------------------------------------------
(git_cookies <- GET('http://github.com') |> cookies())


## -----------------------------------------------------------------------------
git_cookies |> pull(value, name) |> str_trunc(width = 70)


## -----------------------------------------------------------------------------
GET('http://httpbin.org/user-agent')


## -----------------------------------------------------------------------------
GET('http://httpbin.org/cookies/set?c1=tritón')


## -----------------------------------------------------------------------------
GET('http://httpbin.org/cookies') |> 
  cookies() |> t()


## -----------------------------------------------------------------------------
GET('http://httpbin.org/cookies',
    set_cookies('x1' = 'vino'))


## -----------------------------------------------------------------------------
GET('http://httpbin.org/cookies') |> 
  cookies() |> t()


## -----------------------------------------------------------------------------
f_container_row <- function(.get){
  .get |> read_html() |> html_element('.container .row') |> html_text() |> str_squish()
}

GET('https://www.scrapethissite.com/pages/advanced/?gotcha=headers') |> f_container_row()


## -----------------------------------------------------------------------------
GET('https://www.scrapethissite.com/pages/advanced/?gotcha=headers',
    accept('text/html')) |> f_container_row()


## -----------------------------------------------------------------------------
GET('https://www.scrapethissite.com/pages/advanced/?gotcha=headers',
    user_agent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.5 Safari/605.1.15'),
    accept('text/html')) |> f_container_row()


## -----------------------------------------------------------------------------
GET('https://www.scrapethissite.com/pages/advanced/?gotcha=login') |> f_container_row()


## -----------------------------------------------------------------------------
httr::POST('https://www.scrapethissite.com/pages/advanced/?gotcha=login',
     body = list(user = 'test', pass = 'test')) |> f_container_row()


## -----------------------------------------------------------------------------
s <- session('https://www.scrapethissite.com/pages/advanced/?gotcha=login')
f <- html_form(s)[[1]]

f_llena <- f |> html_form_set(user = 'test', pass = 'test')
# Pequeño hack porque la forma no tiene el atributo "action".
f_llena$action <- 'https://www.scrapethissite.com/pages/advanced/?gotcha=login'

f_llena |> html_form_submit() |> f_container_row()


## -----------------------------------------------------------------------------
# Extraer código R
knitr::purl('class_5.Rmd',
            output = 'class_5.R',
            quiet = TRUE)

