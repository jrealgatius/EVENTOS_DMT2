# LECTURA DE DADES --------------------------

# 1. Setup ------

rm(list=ls())

# 2. Carrega de funcions ----------
link_source<-paste0("https://github.com/jrealgatius/Stat_codis/blob/master/funcions_propies.R","?raw=T")
devtools::source_url(link_source)

# 3. Lectura de dades ------------ 
library(here)

input_dades<-here::here("dades","BD_CIPS_N951.sav")

# 1. Leer ficheros de eventos
# 2. Formatear etc...
# 3. En BD_CIPS Fusionar eventos agrupados segun cataleg


BD_CIPS<-read.spss(input_dades,to.data.frame = T) %>% as_tibble()

# 4. Lectura de cataleg i dades d'events CV

cataleg<-"dades" %>% here::here("catalogo_codigos.xls") %>% read_excel(sheet = "ECV_EXITUS") %>% netejar.noms.variables()
EVENTOS_CV<-"dades" %>% here::here("EVENTOS_CARDIOVASCULARES.xls") %>% read_excel() %>% netejar.noms.variables()
EVENTOS_CV_EXIT<-"dades" %>% here::here("EVENTOS_CARDIOVASCULARES_EXITUS.xlsx") %>% read_excel() %>% netejar.noms.variables()
EVENTOS_EXIT_TOTAL<-"dades" %>% here::here("EXITUS_todos.xlsx") %>% read_excel() %>% netejar.noms.variables()
EVENTOS_CV_PROC<-"dades" %>% here::here("EVENTOS_CARDIOVASCULARES_PROCEDIM.xlsx") %>% read_excel() %>% netejar.noms.variables()

# 5. Fusió d'events CV ----------------
EVENTOS_TOTAL<-EVENTOS_CV %>% rbind(EVENTOS_CV_EXIT) %>% rbind(EVENTOS_EXIT_TOTAL)

# Reformat procediments_CV
EVENTOS_CV_PROC<-EVENTOS_CV_PROC %>% rename(Diagnstic_codi=Procediment_codi,Diagnstic_desc=Procediment_desc)

# Fusió total
HISTORIC_EVENTOS_TOTAL<-EVENTOS_TOTAL %>% rbind(EVENTOS_CV_PROC) %>% rename(idp=CIP_14d) %>% select(idp,cod=Diagnstic_codi,Data_ingres)

# 5. Formateig (CIPS A 13 DIGITS)

# Ids CIPS --> a 13 digits 
HISTORIC_EVENTOS_TOTAL<-HISTORIC_EVENTOS_TOTAL %>% mutate(idp=str_sub(idp,1,13)) %>% 
  select(idp,cod,dat=Data_ingres) %>% 
  mutate(dat=data_convert_UTC(dat)) 
# 
IDS_CIPS<-BD_CIPS %>% select(CIP, Inclusion) %>% mutate(dtindex=dataSPSS_to_Rdata(Inclusion),idp=as.character(CIP)) %>% select(idp,dtindex) %>%
  mutate(idp=str_sub(idp,1,13))

#
dt_cataleg<-cataleg %>% select(cod=Diagnstic_codi,Agrupador1,Agrupador2,Agrupador3,MCV)

# 6. Agregar problemes de salut 

dt_agregada<-agregar_problemes(dt=HISTORIC_EVENTOS_TOTAL, bd.dindex = IDS_CIPS,dt.agregadors = dt_cataleg,finestra.dies = c(0,+Inf),prefix = "DG.",camp_agregador = "Agrupador1")

dt_agregada2<-agregar_problemes(dt=HISTORIC_EVENTOS_TOTAL, bd.dindex = IDS_CIPS,dt.agregadors = dt_cataleg,finestra.dies = c(0,+Inf),prefix = "DG.",camp_agregador = "Agrupador2")

dt_agregada3<-agregar_problemes(dt=HISTORIC_EVENTOS_TOTAL, bd.dindex = IDS_CIPS,dt.agregadors = dt_cataleg,finestra.dies = c(0,+Inf),prefix = "DG.",camp_agregador = "Agrupador3")

dt_agregada4<-agregar_problemes(dt=HISTORIC_EVENTOS_TOTAL, bd.dindex = IDS_CIPS,dt.agregadors = dt_cataleg,finestra.dies = c(0,+Inf),prefix = "DG.",camp_agregador = "MCV")


# 7. Agregar per tipus de base de dades o

# Mortalitat event CV ----------------
historic_eventos_MCV<-EVENTOS_CV_EXIT %>% mutate (idp=str_sub(CIP_14d,1,13),data_MCV=data_convert_UTC(Data_ingres)) %>% 
  select(idp,cod_MCV=Diagnstic_codi,data_MCV)

# Join 
idp_MCV<-IDS_CIPS %>% left_join(historic_eventos_MCV,by="idp")


# Mortalitat global ----------------
historic_eventos_exitus<-EVENTOS_EXIT_TOTAL %>% mutate (idp=str_sub(CIP_14d,1,13),data_exitus=data_convert_UTC(Data_ingres)) %>% 
  select(idp,cod_exitus=Diagnstic_codi,data_exitus)

# Join 
idp_exitus<-IDS_CIPS %>% left_join(historic_eventos_exitus,by="idp") %>% select(-dtindex)


# Eventos CV ----------------

historic_CV<-EVENTOS_CV %>% rbind(EVENTOS_CV_EXIT) %>% rbind(EVENTOS_CV_PROC) %>% mutate (idp=str_sub(CIP_14d,1,13),data1_CV=data_convert_UTC(Data_ingres)) %>%
  select(idp,cod_CV1=Diagnstic_codi,data1_CV)

# Join 
idp_CV<-IDS_CIPS %>% left_join(historic_CV,by="idp") %>% group_by(idp) %>% arrange(dtindex) %>% slice(1) %>% ungroup() %>% select(-c(dtindex))


# Fusionar tot 

idp_tots<-idp_MCV %>% left_join(idp_exitus,by="idp") %>% left_join(idp_CV,by="idp") %>% select(-dtindex)


BD_CIPS<-BD_CIPS %>% mutate(idp=str_sub(CIP,1,13)) %>% 
                      left_join(idp_tots,by="idp") %>% 
                      left_join(dt_agregada,by="idp") %>%
                      left_join(dt_agregada2,by="idp") %>% 
                      left_join(dt_agregada3,by="idp") %>% 
                      left_join(dt_agregada4,by="idp")
                    


table(BD_CIPS$DG.MCV>0,BD_CIPS$GRUPO)
table(BD_CIPS$data1_CV>0,BD_CIPS$GRUPO)
names(BD_CIPS$data1_CV)







