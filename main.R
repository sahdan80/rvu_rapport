library(tidyverse)
rvu <- read_delim("rvu.csv", ";", escape_double = FALSE, 
                    locale = locale(encoding = "ISO-8859-1"), 
                    trim_ws = TRUE) %>%
    mutate(
        avstand = as.numeric(str_replace(avstand, ",", "."))
    )

pers <- read_delim("pers.csv", ";", escape_double = FALSE, 
                     locale = locale(encoding = "ISO-8859-1"), 
                     trim_ws = TRUE)



#Nedan finns skriptet jag skrev för att ta fram bifogade filer och därmed är en fortsättning av skriptet som finns på github.

# Om ni läser github skriptet ser ni att variabeln "BostadKommunNamn", 
#"BostadLanNamn", "BostadTatortKat", "BostadTatortNamn", "BostadDesoID" 
#tas fram genom overlay av shapefiler och start koordinater för första resan. 
#Det betyder att där det saknas en start koordinat för första resan, saknas det 
#också mer detaljerad bostadsinformation än den som finns i Kollbar från början, 
#dvs variablerna som börjar med "u_". Variabeln "u_kommun" är baserad på registerdata 
#och visar kommunen där svarspersonen är folkbokförd.
# 
# Med github filen skapar jag tre versioner av RVU filen.
# - Alla rader ingår, dvs tomma rader efter konvertering från wide till long utan resedata ingår.
# - Utan tomma rader, dvs om ingen resa utfördes tas raderna bort. Det är den filen som används av skriptet nedan 
#   eftersom det känns lättast att hantera för er men det är så klart möjligt att skicka en fil med alla rader.
# - Utan tomma rader och utan rader med samma start och stop koordinater.
#   Kollbar har haft en utmaning med en relativ stor andel rundresor som enligt definition är ingen resa.
#   Insamlingsmetoden har nu förbättras och rundresor förekommer mycket mer sällan men det är bra att ta hänsyn till.
#Eftersom jag tog bort koordinater finns en ny variabel "samma_start_stop" som ni kan använda.
# 
# Variabeln för att länka ihop filerna är "respondentid".

# rvu = read.csv2("rvu_utan_na_rader.csv")
# pers = read.csv2("persondata.csv")
# 
# pers = pers %>%
#     filter(u_kommun == "håbo") %>%
#     dplyr::select(-BostadRut500ID,
#                   -BostadRut1000ID,
#                   -Bostad_Wgs84lng,
#                   -Bostad_Wgs84lat,
#                   -u_postnummer,
#                   -u_postort,
#                   -h6)
# 
# inklud = pers %>% dplyr::select(respondentid) %>% pull()
# 
# rvu = rvu %>%
#     filter(respondentid %in% inklud) %>%
#     mutate(samma_start_stop = ifelse(paste(b3_lat, b3_lng) == paste(b9_lat, b9_lng), "ja", "nej")) %>%
#     dplyr::select(-ConcatStart,
#                   -ConcatStop,
#                   -StartRut500ID,
#                   -StartRut1000ID,
#                   -b3_lat,
#                   -b3_lng,
#                   -Start_Wgs84lng,
#                   -Start_Wgs84lat,
#                   -StopRut500ID,
#                   -StopRut1000ID,
#                   -Stop_Wgs84lng,
#                   -Stop_Wgs84lat,
#                   -b9_lat,
#                   -b9_lng)
#####

purposes <- data.frame(
    purpose_id = c(1:12),
    purpose = c("Arbete (till jobbet)", "Studier (till skola/studier)", "Tjänsteresa (resa i arbetet)",
      "Inköp av dagligvaror", "Övriga inköp", "Service (sjukvård, bank, post etc.)", 
      "Hämta och lämna inom barnomsorgen", "Skjutsa/följa/hämta annan person", "Besöka släkt och vänner",
      "Egen fritidsaktivitet/nöje/motion", "Hemresa/till bostaden", "Annat ärende")
)

rvu_purp <- rvu %>%
    select(resa.no, respondentid, b2) %>%
    left_join(purposes, by = c("b2" = "purpose_id")) %>%
    group_by(purpose) %>%
    summarise(antal = n())

