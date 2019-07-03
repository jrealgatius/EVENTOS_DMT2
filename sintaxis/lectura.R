#

#####################  Directori Font     ==============================  

rm(list=ls())


link_source<-paste0("https://github.com/jrealgatius/Stat_codis/blob/master/funcions_propies.R","?raw=T")
devtools::source_url(link_source)


# 

library(here)

input_dades<-here::here("dades","BD_CIPS_N951.sav")

# 1. Leer ficheros de eventos
# 2. Formatear etc...
# 3. En BD_CIPS Fusionar eventos agrupados segun cataleg

BD_CIPS<-read.spss(input_dades,to.data.frame = T) %>% as_tibble()

cataleg<-"dades" %>% here::here("catalogo_codigos.xlsx") %>% read_xlsx(sheet = "ECV_EXITUS")
EVENTOS_CV<-"dades" %>% here::here("EVENTOS_CARDIOVASCULARES.xlsx") %>% read_xlsx()
EVENTOS_CV_EXIT<-read_xlsx("EVENTOS_CARDIOVASCULARES_EXITUS.xlsx")
EVENTOS_EXIT_TOTAL<-read_xlsx("EXITUS_todos.xlsx")
EVENTOS_CV_PROC<-read_xlsx("EVENTOS_CARDIOVASCULARES_PROCEDIM.xlsx")







