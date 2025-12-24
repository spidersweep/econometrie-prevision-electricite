library(readxl)
library(readr)
library(dplyr)
library(lubridate)
library(zoo)
library(ggplot2)

# ============================================================
# ÉTAPE 1 : Charger les fichiers
# ============================================================

fichiers <- list.files(path = "C:/Users/Lara1/Documents/intro_a_R/Donnees_RTE", 
                       pattern = "\\.xlsx$|\\.xls$", 
                       full.names = TRUE)

lire_fichier_simple <- function(fichier) {
  df <- read_excel(fichier)
  df_clean <- df %>%
    select(Date, Heures, Consommation) %>%
    mutate(fichier_source = basename(fichier))
  return(df_clean)
}

liste_data <- lapply(fichiers, lire_fichier_simple)
data_brut <- bind_rows(liste_data)

# ============================================================
# ÉTAPE 2 : Nettoyer les dates
# ============================================================

data_brut <- data_brut %>%
  mutate(
    date = as.Date(Date),
    heure = format(Heures, "%H:%M:%S")
  )

# Filtrer 2016-2024 (CHANGEMENT : 2015 → 2016)
data_clean <- data_brut %>%
  filter(!is.na(date)) %>%
  filter(year(date) >= 2016 & year(date) <= 2024)

# Vérifier
nrow(data_clean)
head(data_clean)

# ============================================================
# ÉTAPE 3 : Agréger journalier puis mensuel
# ============================================================

# Journalier
data_jour <- data_clean %>%
  group_by(date) %>%
  summarise(conso_jour = sum(Consommation, na.rm = TRUE),
            .groups = 'drop')

# Ajouter année et mois
data_jour <- data_jour %>%
  mutate(annee = year(date),
         mois = month(date))

# Mensuel
data_mensuel <- data_jour %>%
  group_by(annee, mois) %>%
  summarise(conso_mensuelle = sum(conso_jour, na.rm = TRUE),
            .groups = 'drop')

# Créer date mensuelle
data_mensuel <- data_mensuel %>%
  mutate(date_mensuelle = as.Date(paste(annee, mois, "01", sep = "-"))) %>%
  arrange(date_mensuelle)

# Vérifier
head(data_mensuel)
tail(data_mensuel)
nrow(data_mensuel)  # Devrait être 108 mois (9 ans)

# ============================================================
# ÉTAPE 3B : Ajouter variables exogènes (dummies)
# ============================================================

data_mensuel <- data_mensuel %>%
  mutate(
    hiver = ifelse(mois %in% c(12, 1, 2), 1, 0),
    ete = ifelse(mois %in% c(6, 7, 8), 1, 0),
    canicule = ifelse(mois %in% c(7, 8), 1, 0),
    chauffage = ifelse(mois %in% c(11, 12, 1, 2, 3), 1, 0)
  )

head(data_mensuel)

# ============================================================
# ÉTAPE 4 : Créer objet ts
# ============================================================

conso_ts <- ts(data_mensuel$conso_mensuelle, 
               start = c(2016, 1), 
               frequency = 12)

print(conso_ts)
plot(conso_ts, main = "Consommation électrique IDF (2016-2024)")

# ============================================================
# ÉTAPE 5 : Graphiques
# ============================================================

# Graphique 1 : Série complète
g1 <- ggplot(data_mensuel, aes(x = date_mensuelle, y = conso_mensuelle)) +
  geom_line(color = "blue", size = 0.8) +
  labs(title = "Consommation d'électricité en Île-de-France (2016-2024)",
       x = "Date", 
       y = "Consommation mensuelle (MWh)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"))


# Sauvegarder
ggsave("graphique_serie_temporelle.png", plot = g1, width = 10, height = 6, dpi = 300)

# Graphique 2 : Saisonnalité
g2 <- data_mensuel %>%
  group_by(mois) %>%
  summarise(conso_moy = mean(conso_mensuelle)) %>%
  ggplot(aes(x = factor(mois), y = conso_moy)) +
  geom_col(fill = "steelblue") +
  scale_x_discrete(labels = month.abb) +
  labs(title = "Saisonnalité moyenne par mois (2016-2024)",
       x = "Mois", 
       y = "Consommation moyenne (MWh)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"))

ggsave("graphique_saisonnalite.png", plot = g2, width = 10, height = 6, 
       dpi = 300)

# Graphique 3 : Décomposition
png("graphique_decomposition.png", width = 1200, height = 800, res = 120)
decomp <- decompose(conso_ts, type = "additive")
plot(decomp)
dev.off()

# Graphique 4 : Plot simple de la série ts
png("graphique_ts_simple.png", width = 1000, height = 600, res = 120)
plot(conso_ts, main = "Consommation électrique IDF", 
     xlab = "Année", ylab = "Consommation (MWh)")
dev.off()

library(dplyr)

# 1) On construit un data.frame vide pour 2016–2024
annee  <- rep(2016:2024, each = 12)
mois   <- rep(1:12, times = 9)

temp_min <- c(
  # 2016 (12 valeurs min)
  4.0, 4.2, 4.5, 6.9, 11.3, 14.7, 16.6, 16.5, 15.2, 8.8, 6.2, 2.8,
  # 2017 (à remplir à partir de ta capture)
  0.6, 5.4, 7.6, 7.2, 12.2, 16.3, 16.8, 15.6, 12.2, 11.5, 6.1, 3.8,
  # 2018
  6.2,  NA, 4.5, 10.1, 12.1, 15.6, 19.2, 16.8, 13.0, 10.6, 6.2, 5.4,
  # 2019
  3.2, 4.1, 6.9, 7.9, 10.0, 15.4, 17.1, 16.6, 13.5, 10.9, 6.4, 5.2,
  # 2020
  4.6, 6.5, 5.6, 10.0, 11.3, 14.4, 15.7, 17.6, 14.5, 10.3, 7.5, 5.2,
  # 2021
  3.2, 4.2, 4.9, 5.4, 9.3, 15.8, 16.4, 15.3, 14.7, 9.2, 5.1, 5.5,
  # 2022
  3.6, 5.3, 6.4, 7.6, 12.6, 15.3, 17.1, 17.6, 13.5, 12.7, 7.7, 3.8,
  # 2023
  4.6, 4.4, 6.7, 7.5, 11.2, 16.7, 16.5, 16.6, 16.4, 11.7, 7.5, 6.2,
  # 2024
  3.0, 7.5, 7.2, 8.6, 12.2, 13.9, 16.2, 16.8, 13.3, 11.5, 6.8, 4.6
)

temp_max <- c(
  # 2016
  8.5, 9.6, 10.8, 15.0, 19.6, 21.9, 25.8, 27.1, 23.9, 15.8, 10.7, 8.0,
  # 2017
  5.3, 10.7, 15.1, 16.7, 22.0, 26.5, 26.2, 25.2, 20.2, 18.3, 11.1, 8.4,
  # 2018
  10.3, 5.1, 11.2, 19.0, 23.0, 24.8, 29.6, 27.1, 22.9, 18.6, 11.0, 9.5,
  # 2019
  6.7, 12.7, 14.1, 17.3, 18.6, 25.7, 28.8, 26.7, 22.3, 16.7, 10.8, 9.7,
  # 2020
  9.5, 12.3, 13.0, 21.3, 22.3, 24.0, 26.5, 28.2, 24.0, 15.6, 13.4, 9.0,
  # 2021
  7.2, 10.2, 13.6, 15.4, 18.1, 25.1, 24.6, 23.8, 23.9, 17.2, 10.2, 9.6,
  # 2022
  7.6, 11.5, 15.0, 16.9, 22.9, 25.6, 28.9, 29.0, 21.6, 20.0, 12.7, 7.5,
  # 2023
  8.3, 10.6, 13.3, 15.6, 21.0, 28.1, 25.9, 25.1, 26.3, 19.5, 12.2, 10.1,
  # 2024
  7.6, 11.9, 14.3, 16.9, 20.2, 22.9, 25.8, 26.7, 20.4, 17.4, 11.0, 8.5
)

# 2) On met tout dans un data.frame
temp_all <- data.frame(annee, mois, temp_min, temp_max)

# 3) On calcule la température moyenne
temp_all <- temp_all %>%
  mutate(temp_moy = (temp_min + temp_max) / 2)

# 4) On crée la date mensuelle pour fusionner avec data_mensuel
temp_all <- temp_all %>%
  mutate(date_mensuelle = as.Date(paste(annee, mois, "01", sep = "-")))

# 5) On fusionne avec ta conso
data_mensuel <- data_mensuel %>%
  left_join(temp_all %>% select(date_mensuelle, temp_moy),
            by = "date_mensuelle")

# Vérifier
head(data_mensuel)

data_mensuel <- data_mensuel %>%
  select(
    annee,
    date_mensuelle,
    mois,
    conso_mensuelle,
    temp_moy,       
    hiver,
    ete,
    canicule,
    chauffage,
    everything()  
  )

head(data_mensuel)

# ============================================================
# ÉTAPE : Ajout google trends
# ======================================

library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)

trends_chauffage <- read_csv(
  "C:/Users/Lara1/Documents/intro_a_R/trends_chauffage.csv",
  skip = 2,
  col_names = c("mois_str", "chauffe_index"),
  show_col_types = FALSE
)

# 2) Filtrer la ligne "Mois" qui reste et convertir
trends_chauffage <- trends_chauffage %>%
  filter(mois_str != "Mois") %>%  # enlever la ligne d'en-tête "Mois"
  mutate(
    date = as.Date(paste0(mois_str, "-01")),
    chauffe_index = as.numeric(chauffe_index)
  ) %>%
  select(date, chauffe_index)

head(trends_chauffage)

# 3) Créer date_mensuelle et fusionner
trends_chauffage_m <- trends_chauffage %>%
  mutate(
    annee = year(date),
    mois  = month(date),
    date_mensuelle = as.Date(paste(annee, mois, "01", sep = "-"))
  ) %>%
  select(date_mensuelle, trend_chauffage = chauffe_index)

data_mensuel <- data_mensuel %>%
  left_join(trends_chauffage_m, by = "date_mensuelle")

head(data_mensuel) 
  
 
# Pour climatisation
trends_climatisation_raw <- read_csv(
  "C:/Users/Lara1/Documents/intro_a_R/trends_climatisation.csv",
  skip = 2,
  col_names = c("mois_str", "clim_index"),
  show_col_types = FALSE
)

print(trends_climatisation_raw)


trends_climatisation <- trends_climatisation_raw %>%
  filter(mois_str != "Mois") %>%
  mutate(
    date = as.Date(paste0(mois_str, "-01")),
    clim_index = as.numeric(clim_index)
  ) %>%
  select(date, clim_index)

head(trends_climatisation)

# Créer version mensuelle
trends_climatisation_m <- trends_climatisation %>%
  mutate(
    annee = year(date),
    mois  = month(date),
    date_mensuelle = as.Date(paste(annee, mois, "01", sep = "-"))
  ) %>%
  select(date_mensuelle, trend_clim = clim_index)

# Fusionner
data_mensuel <- data_mensuel %>%
  left_join(trends_climatisation_m, by = "date_mensuelle")

head(data_mensuel)


#Canicule

trends_canicule <- read_csv(
  "C:/Users/Lara1/Documents/intro_a_R/trends_canicule.csv",
  skip = 2,
  col_names = c("mois_str", "canicule_index"),
  show_col_types = FALSE
)

print(trends_canicule)

trends_canicule <- trends_canicule %>%
  filter(mois_str != "Mois") %>%
  mutate(
    canicule_index = as.numeric(canicule_index),
    date = as.Date(paste0(mois_str, "-01"))
  ) %>%
  select(date, canicule_index)

head(trends_canicule)


# version mensuelle
trends_canicule_m <- trends_canicule %>%
  mutate(
    annee = year(date),
    mois  = month(date),
    date_mensuelle = as.Date(paste(annee, mois, "01", sep = "-"))
  ) %>%
  select(date_mensuelle, trend_canicule = canicule_index)


data_mensuel <- data_mensuel %>%
  left_join(trends_canicule_m, by = "date_mensuelle")

head(data_mensuel)


data_mensuel <- data_mensuel %>%
  select(
    date_mensuelle,
    annee,
    mois,
    conso_mensuelle,
    temp_moy,
    trend_chauffage,
    trend_canicule,
    trend_clim,
    hiver,
    ete,
    everything()  
  )

head(data_mensuel)
colnames(data_mensuel)

write.csv(data_mensuel, 
          "C:/Users/Lara1/Documents/intro_a_R/conso_idf_mensuel_2016_2024_final.csv", 
          row.names = FALSE)


save(conso_ts, data_mensuel, 
     file = "C:/Users/Lara1/Documents/intro_a_R/conso_idf_final.RData")

conso_ts <- ts(data_mensuel$conso_mensuelle, 
               start = c(2016, 1), 
               frequency = 12)

plot(conso_ts, main = "Consommation d'électricité IDF (2016-2024)")

cat("=== STATISTIQUES DESCRIPTIVES ===\n")
cat("Période : 2016-2024 (108 mois)\n")
cat("Consommation moyenne :", round(mean(data_mensuel$conso_mensuelle), 0), "MWh\n")
cat("Écart-type :", round(sd(data_mensuel$conso_mensuelle), 0), "MWh\n")
cat("Min :", round(min(data_mensuel$conso_mensuelle), 0), "MWh\n")
cat("Max :", round(max(data_mensuel$conso_mensuelle), 0), "MWh\n")
cat("Température moyenne :", round(mean(data_mensuel$temp_moy, na.rm = TRUE), 2), "°C\n")


