# Modélisation et Prévision de la Consommation d'Électricité en Île-de-France

## 📋 Projet Académique - Master 1 BIDABI (2024-2025)

Ce projet vise à **modéliser et prévoir la consommation mensuelle d'électricité** en Île-de-France sur la période 2016–2024 à l'aide de méthodes économétriques avancées (modèles ARIMAX).

---

## 🎯 Objectif général

Identifier et quantifier les **déterminants de la consommation d'électricité régionale** (température, saisonnalité, comportements de recherche en ligne) et développer un **modèle de prévision robuste** pour anticiper les pics de consommation, utile aux gestionnaires de réseau et aux décideurs énergétiques.

---

## 📊 Données

### Sources principales

- **RTE (Réseau de Transport d'Électricité)** : Consommation électrique mensuelle (données consolidées eCO2mix)
- **Météo-France** : Température mensuelle Paris-Montsouris (2016–2024)
- **Google Trends** : Indices de recherche mensuels pour les termes « chauffage », « canicule », « climatisation » (région Île-de-France)

### Période couverte
- **2016–2024** (108 observations mensuelles)
- Données consolidées et finalisées (pas de données temps réel)

### Variables principales
| Variable | Description | Unité |
|----------|-------------|-------|
| `conso_mensuelle` | Consommation d'électricité | MWh |
| `temp_moy` | Température moyenne mensuelle | °C |
| `trend_chauffage` | Indice Google Trends "chauffage" | 0–100 |
| `trend_canicule` | Indice Google Trends "canicule" | 0–100 |
| `trend_clim` | Indice Google Trends "climatisation" | 0–100 |
| `covid` | Dummy période de confinement | 0/1 |

---

## 📁 Structure du dépôt
econometrie-prevision-electricite/
│
├── README.md # Ce fichier
├── LICENSE # Licence MIT
├── .gitignore # Fichiers à ignorer
│
├── code/ # Scripts R
│ ├── 01_collecte_donnees_Lara.R # Étape 1 : Collecte et nettoyage
│ ├── 02_analyse_exploratoire_Nabiha.R # Étape 2 : Analyse descriptive
│ └── 03_modelisation_Awatif.R # Étape 3 : ARIMAX et prévisions
│
├── data/ # Données (CSV)
│ ├── conso_idf_mensuel_2016_2024_final.csv
│ ├── trends_chauffage.csv
│ ├── trends_canicule.csv
│ └── trends_climatisation.csv
│
├── outputs/ # Résultats
│ ├── graphiques/
│ │ ├── serie_temporelle.png
│ │ ├── saisonnalite.png
│ │ └── decomposition.png
│ └── resultats_arimax.csv
│
└── rapport/ # Document final
└── Rapport_M1_BIDABI_2025.docx
