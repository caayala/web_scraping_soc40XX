# title: "Trabajo con listas"
# subtitle: "Web Scrapping y acceso a datos desde la web con R"
# author: Cristián Ayala
# date: 2022-05-26

suppressPackageStartupMessages(library(tidyverse))
library(rvest)

# purrr Fundamentos ----

l <-  list(a = c('caso' = c(1:2, NA)),
           b = c('caso' = 4:5))
l

# Suma de cada elemento de la lista.
l |> purrr::map(sum)
l |> purrr::map(function(x)sum(x))

# Distintas formas de anotar la función o qué se hará con cada elemento.
l |> purrr::map(sum, na.rm = TRUE)
l |> purrr::map(~sum(., na.rm = TRUE))
l |> purrr::map(function(x)sum(x, na.rm = TRUE))
l |> purrr::map(\(x)sum(x, na.rm = TRUE))

base::lapply(l, sum)
base::lapply(l, ~sum(., na.rm = TRUE)) # lapply no entiende este tipo de sintaxis.
base::lapply(l, \(x)sum(x, na.rm = TRUE))

# ¿Cuál es el largo de cada elemento?
l |> purrr::map(length)

# purrr Feriados en Chile ----

## Lectura de base de datos ----

url <- 'https://apis.digital.gob.cl/fl/feriados'

l_feriados <- jsonlite::read_json(url, simplifyVector = FALSE)


## Explorar la lista ----

# ¿cuántos datos hay?
l_feriados |> length()

# ¿cómo es su estructura?
l_feriados |> str()
 
# 1 nivel
l_feriados |> str(1)

# 2 niveles de los primeros 2 elementos
l_feriados[1:2] |> str(2)

# Profundidad máxima de la lista. 
vec_depth(l_feriados) #Tiene un máximo de 5 niveles.




## Extraer elementos ----

### map Nombres ----
# 
# ¿Cuáles son los nombres de los feriados?

l_feriados |> map('nombre') # Devuelve una lista

l_feriados |> map_chr('nombre') # Devuelve un vector de caracteres

l_feriados |> map_chr('nombre') |> table()

l_feriados |> map_chr('nombre') |> table() |> sort()


### map Fechas ----
# 
# ¿Cuáles son las fechas de los feriados? ¿Cuántos feriados fueron en fin de semana por año?

l_feriados |> map_chr('fecha') # Devuelve un vector de caracteres

# ¿Cuántos feriados fueron en fin de semana por año?

ch_fechas <- l_feriados |> map_chr('fecha') # Vector con fechas

# ¿Hay fechas duplicadas?
sum(duplicated(ch_fechas))

# ¿Cuáles son las fechas duplicadas?
ch_fechas[duplicated(ch_fechas)]

ch_fechas <- unique(ch_fechas) # solo fechas únicas

df_fechas <- tibble(fecha = ch_fechas)

df_fechas <- df_fechas |> 
  mutate(fecha = as.Date(fecha))

# Quiero obtener el año y el día de la semana
# help(strptime)

df_fechas <- df_fechas |> 
  mutate(dia = format(fecha, '%u'), # Lunes es 1
         anio = format(fecha, '%Y'),
         fin_de_semana = dia > 5)

# Graficar

ggplot(df_fechas, 
       aes(x = anio, fill = fin_de_semana)) +
  geom_bar() + 
  labs(title = 'Feriados por año',
       y = 'número')

ggplot(df_fechas, 
       aes(x = anio, fill = fin_de_semana)) +
  geom_bar(position = position_fill()) + 
  labs(title = 'Feriados por año',
       y = 'proporción')

# ¿Cuál fue el mejor año?

### pluck Leyes ----
# 
# Ver si cada uno de los elementos tiene una lista de 'leyes'
l_feriados |> pluck(1, 'leyes')
l_feriados |> pluck(183, 'leyes')

l_feriados[1:3] |> map(pluck, 'leyes')
l_feriados[1:3] |> map(pluck, 'leyes') |> map(pluck, 1, 'nombre')

l_feriados[1:3] |> map(pluck, 'leyes', 1, 'nombre')
l_feriados[1:3] |> map(pluck, 'leyes', 2, 'nombre')


## Comentarios ----

# ¿Cómo extraemos los comentarios?
l_feriados |> map('comentarios')

# Error: No se puede generar un vector solamente con 'characters'.
l_feriados |> map_chr('comentarios')

# Revisión de los comentarios contenidos.
l_feriados |> map('comentarios') |> 
  as.character() |> str_trunc(width = 40) |> 
  table(useNA = 'ifany') |> sort()


# Cambio el primer comentario
l_feriados |> assign_in(list(1, 'comentarios'), 'nuevo comentario') |> 
  (\(x)x[[1]])()

# Cambio todos los comentarios
l_feriados |> map(assign_in, list('comentarios'), 'nuevo comentario')


# Modifico comentarios para limpiarlos: 3 tipos de comentarios.

l_feriados[[144]]$nombre

l_feriados[[144]]$comentarios #' '
l_feriados[[160]]$comentarios #''
l_feriados[[183]]$comentarios #NULL
  
f_blancos <- function(x){
  # Función para homologar los comentarios.
  if_else((x %in% c(' ', '', 'NULL')) || is.null(x),
          NA_character_,
          x)
}

# Ejemplos de función
f_blancos('casa')
f_blancos(' ')

### modify ----

l_feriados[[144]] |> modify_in('comentarios', f_blancos)
l_feriados[[183]] |> modify_in('comentarios', f_blancos)

# Modifiquemos todos los comentarios
l_feriados[[183]] |> modify_in('comentarios', f_blancos)

l_feriados |> map(modify_in, 'comentarios', f_blancos)
# Formas equivalentes de anotar funciones anónimas "lambda".
l_feriados |> map(function(x)modify_in(x, 'comentarios', f_blancos))
l_feriados |> map(function(x){modify_in(x, 'comentarios', f_blancos)})
l_feriados |> map(\(x)modify_in(x, 'comentarios', f_blancos))
l_feriados |> map(\(x){modify_in(x, 'comentarios', f_blancos)})
l_feriados |> map(~modify_in(., 'comentarios', f_blancos))

l_feriados <- l_feriados |> 
  map(modify_in, 'comentarios', f_blancos)

### keep ----
l_feriados |> keep(~!is.na(.['comentarios']))


## Lista a data.frame ----

df_feriados <- l_feriados |> 
  enframe(name = 'id', value = 'feriados')

df_feriados

df_feriados |> 
  unnest_wider(feriados)

df_feriados |> 
  unnest_wider(feriados) |> 
  unnest(leyes)

df_feriados |> 
  unnest_wider(feriados) |> 
  unnest(leyes) |> 
  unnest_wider(leyes, names_repair = 'minimal')

# data.frame con los feriados. Las unidades de análisis 
df_feriados <- df_feriados |> 
  unnest_wider(feriados) |> 
  unnest(leyes) |> 
  unnest_wider(leyes, names_repair = 'minimal')

# Se debe distinguir las dos variables con igual nombre: "nombre"
names(df_feriados)[7] <- 'nombre_ley'

# Dejar solo una fecha, evitando los duplicados
df_feriados <- df_feriados |> 
  distinct(across(id:tipo), .keep_all = TRUE)


### fromJSON: Lectura directa de JSON a data.frame ----

# Podemos pedir a `read_json` que intente simplificar el JSON que recibe a un vector o data.frame.
jsonlite::read_json(url, simplifyVector = TRUE) |> 
  as_tibble()

# Equivalente:
df_feriados_2 <- jsonlite::fromJSON(url) |> 
  as_tibble()

df_feriados_2 |> 
  head()

df_feriados_2$comentarios |> 
  str_trunc(width = 40) |> table() |> sort()

# ¿Existe el problema con los comentarios igual que en la lista anterior?
df_feriados_2$comentarios |> 
  str_trunc(width = 40) |> table(useNA = 'ifany') |> sort()

## type_convert: Extra, ajustar la clase de las variables ----

df_feriados_2 |> 
  mutate(fecha = as.Date(fecha),
         irrenunciable = as.integer(irrenunciable))
  
df_feriados_2 <- df_feriados_2 |> 
  readr::type_convert()

df_feriados_2 |> 
  head()

df_feriados_2$comentarios |> 
  str_trunc(width = 40) |> table() |> sort()


## Webscrapping y el uso de listas ----
# 
# Capturar feriados por año.
# Revision de API: https://apis.digital.gob.cl/fl/
# 
# Para pedir feriados por año: https://apis.digital.gob.cl/fl/feriados/(:año)


url <- 'https://apis.digital.gob.cl/fl/feriados'

# Feriados de 2022
jsonlite::fromJSON('https://apis.digital.gob.cl/fl/feriados/2022') |> head()
jsonlite::fromJSON(paste0(url,'/', 2022)) |> head()

# Ahora capturemos los feriados de 2020 a 2022
anios <- 2020:2022

# Lista con los tres años:
l_anios <- map(anios, ~jsonlite::fromJSON(paste0(url,'/', .)))

l_anios |> map(head, 2)

# Puedo agregar todos en una sola data.frame mediante map_dfr.
df_anios <- map_dfr(anios, ~jsonlite::fromJSON(paste0(url,'/', .)))

df_anios |> head(2)

glimpse(df_anios)


# stringr ----
# 
# Está incluido dentro de los paquetes que carga `tidyverse`.

df_feriados_2$nombre |> table() |> sort()

## str_detect ----
# Detección de feriados con domingo.
df_feriados_2 |> 
  filter(str_detect(nombre, 'Domingo'))
  
# Exluir esos datos de la base de datos
df_feriados_2 <- df_feriados_2 |> 
  filter(!str_detect(nombre, 'Domingo'))

## str_detect ----
df_feriados_2 |> filter(str_detect(nombre, 'Sábado')) #con tilde

df_feriados_2 |> filter(str_detect(nombre, 'Sabado')) #sin tilde

df_feriados_2 |> filter(str_detect(nombre, 'S.bado')) # comodín

df_feriados_2 |> filter(str_detect(nombre, 'S(a|á)bado')) # a | á

df_feriados_2 |> filter(str_detect(nombre, 'S[aá]bado')) # a | á

## str_subset ----
df_feriados_2$nombre |> str_subset('^Sab')

## str_replace ----
df_feriados_2$nombre <- df_feriados_2$nombre |> str_replace_all('^Sab', 'Sáb')

# Confirmación de que el cambio fue hecho.
df_feriados_2 |> filter(str_detect(nombre, 'Sabado'))

## str_match_all ----
# 
# Listado de todos los nombres para ver diferencias 
feriados_nombres <- df_feriados_2$nombre |> str_match_all('\\w*')

feriados_nombres_chr <- map(feriados_nombres, discard, ~. == '')

feriados_nombres_chr |> unlist() |> table()

# Reemplazar diferencias detectadas
# 
# old = new
df_feriados_2$nombre |> str_replace_all(
  c('Alcaldes' = 'Alcalde',
    'Parlamentarias' = 'Parlamentaria',
    'Ejercito' = 'Ejército',
    'Prueblos' = 'Pueblos',
    'todos' = 'Todos')) |> 
  table()

textos_reempazar <- c('Alcaldes' = 'Alcalde',
                      'Parlamentarias' = 'Parlamentaria',
                      'Ejercito' = 'Ejército',
                      'Prueblos' = 'Pueblos',
                      'todos' = 'Todos')

df_feriados_2$nombre |> 
  str_replace_all(textos_reempazar) |> 
  table()

df_feriados_2$nombre <- df_feriados_2$nombre |> 
  str_replace_all(textos_reempazar)

## Elecciones por año

df_feriados_2 <- df_feriados_2 |> 
  mutate(anio = format(fecha, '%Y'), 
         eleccion = str_detect(nombre, '.*Elecci.*'),
         .after = comentarios)

df_feriados_2 |> 
  filter(eleccion)

df_feriados_2 |> 
  count(anio, wt = eleccion, 
        name = 'n_elecciones')

df_feriados_2 |> 
  group_by(anio) |> 
  summarise(n_elecciones = sum(eleccion))
