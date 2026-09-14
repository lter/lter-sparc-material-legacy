## -------------------------------------------- ##
# Standardize Data - Harvard Forest (HFR)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites

## !!! DATA SOURCE NOTE !!!
# Data taken from Google Drive (_not_ EDI)
## Data downloaded from Google Drive by `_TEMPORARY_drive-download.r`
## !!! SEE ABOVE !!!

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Tidy Dead Wood Data ----
## -------------------------------------------- ##

# # Load the relevant file
# hfr_dead_v01 <- read.csv(file.path("data", "raw", "00_HFR__hf125-01-cwd.csv"))

# # Check structure
# dplyr::glimpse(hfr_dead_v01)

## -------------------------------------------- ##
# Tidy Sapling Data ----
## -------------------------------------------- ##

# Read in the relevant file(s)
hfr_sap_v01 <- read.csv(file.path("data", "raw", "00_HFR__hf106-05-sapling.csv"))

# Check structure
dplyr::glimpse(hfr_sap_v01)

# Do necessary wrangling / tidying
hfr_sap_v02 <- hfr_sap_v01 %>% 
  dplyr::mutate(
    species = ifelse(is.na(species), yes = "none", no = species),
    spgr = dplyr::case_when(
      species == "ACRU" ~ "red maple",
      species %in% c("BELE", "BEAL", "BEPA", "BEPO") ~ "birch",
      species == "PIST" ~ "white pine", 
      species %in% c("QURU", "QUVE","QUAL", "QUBI") ~ "oak",
      species == "TSCA" ~ "hemlock",
      TRUE ~ "other hardwood"),
    trt = dplyr::case_when(
      plot %in% c(1, 5) ~ "girdled",
      plot %in% c(2, 4) ~ "logged",
      plot %in% c(3, 6) ~ "hemlock",
      TRUE ~ "hardwood"),
    block = ifelse(plot %in% c(1:3, 8), yes = "valley", no = "ridge"),
    n.ha = total / 0.09) # [ABP]: "divide by size of center section of plot"

# Check structure
dplyr::glimpse(hfr_sap_v02)

# Summarize to get density
hfr_sap_v03 <- hfr_sap_v02 %>% 
  dplyr::group_by(plot, trt, block, year, species, spgr) %>% 
  dplyr::summarize(density.ha = sum(n.ha, na.rm = TRUE),
  .groups = "drop")

# Check structure
dplyr::glimpse(hfr_sap_v03)

## -------------------------------------------- ##
# Tidy Hemlock Data ----
## -------------------------------------------- ##

# Load relevant data
hfr_v01 <- read.csv(file.path("data", "from-drive", "TreeSapDensSpecies.csv"))

# Check structure
dplyr::glimpse(hfr_v01)

# Simplify some categorical columns in data
hfr_v02 <- hfr_v01 %>% 
  dplyr::mutate(
    species = ifelse(nchar(species) == 0 | is.na(species),
      yes = "none", no = species),
    spgroup = dplyr::case_when(
      species == "TSCA" ~ "hemlock",
      species %in% c("BEAL", "BELE") ~ "birch",
      TRUE ~ "other"))

# Check structure
dplyr::glimpse(hfr_v02)

# Do some needed filtering
hfr_v03 <- hfr_v02 %>% 
  dplyr::filter(trt %in% c("girdled", "logged")) %>% 
  dplyr::filter(stratum == "Sapling") %>% 
  dplyr::filter(year > 2004)

# Check structure
dplyr::glimpse(hfr_v03)

# Summarize within needed columns
hfr_v04 <- hfr_v03 %>% 
  dplyr::group_by(plot, trt, block, year, spgroup) %>%
  dplyr::summarize(dens_ha = sum(dens.ha, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::group_by(plot, trt, block, year) %>% 
  dplyr::mutate(dens_ha_total = sum(dens_ha, na.rm = TRUE)) %>% 
  dplyr::ungroup()

# Check structure
dplyr::glimpse(hfr_v04)

# Filter to only hemlock density data
hfr_v05 <- hfr_v04 %>% 
  dplyr::filter(spgroup == "hemlock") %>% 
  dplyr::rename(dens_ha_hemlock = dens_ha) %>% 
  dplyr::select(-spgroup)

# Check structure
dplyr::glimpse(hfr_v05)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
hfr_v99 <- hfr_v05 %>% 
  dplyr::rename_with(.fn = ~ tolower(gsub(pattern = "_", replacement = ".", x = .))) %>% 
  dplyr::select(plot, block,
    treatment = trt, year,
    hemlock.density.ha = dens.ha.hemlock)

# One last structure check
dplyr::glimpse(hfr_v99)

# Export locally
write.csv(hfr_v99, row.names = FALSE, na = "",
  file = file.path("data", "standard", "01_HFR_hemlock-removal.csv"))

# End ----
