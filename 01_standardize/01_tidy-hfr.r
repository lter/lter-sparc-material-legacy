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
hfr_tree_v01 <- read.csv(file.path("data", "raw", "00_HFR__hf126-02-tree.csv"))

# Check structure
dplyr::glimpse(hfr_tree_v01)

# Begin doing actual wrangling/tidying
hfr_tree_v02 <- hfr_tree_v01 %>% 
  dplyr::mutate(species = gsub(pattern = " ", replacement = "", x = species)) %>% 
  dplyr::mutate(
    dbht0 = dplyr::case_when(
      ## [ABP]: "trees 3606, 3902, 1901, 3920, and 3900 dbh in 2004 was more than 20cm greater than 2009 and subsequent meas. Change these to dbh09."
      tree %in% c(3902, 1901, 3920, 3900, 3606, 3911) ~ dbh09,
      ## [ABP]: "trees 2721, 6701, 4173, 5300, and 3239 grew more than 10cm between 2004 and 2009. It's pretty clear what the correct value should be for 2004 for these."
      tree == 2721 ~ 57.0, #dbht0 was recorded as 37.0
      tree == 3239 ~ 48.5, #dbht0 was recorded as 38.5
      tree == 4173 ~ 67.0, #dbht0 was recorded as 57.0
      tree == 5300 ~ 43.2, #dbht0 was recorded as 33.2
      tree == 6701 ~ 69.1, #dbht0 was recorded as 59.1
      TRUE ~ dbht0)) %>% 
  dplyr::mutate(
    BAm204 = ifelse(condt0 %in% c('L', 'R'), yes = (pi*((dbht0/200)^2)), no = NA),
    BAm209 = ifelse(cond09 %in% c('L', 'R'), yes = (pi*((dbh09/2)^200)), no = NA),
    BAm214 = ifelse(cond14 %in% c('L', 'R'), yes = (pi*((dbh14/2)^200)), no = NA),
    BAm219 = ifelse(cond19 %in% c('L', 'R'), yes = (pi*((dbh19/2)^200)), no = NA),
    BAm224 = ifelse(cond24 %in% c('L', 'R'), yes = (pi*((dbh24/2)^200)), no = NA)
  ) %>% 
  dplyr::mutate(
    size.ha = dplyr::case_when(
      plot %in% c(1, 3) ~ (90*85)/10000,
      plot == 2 ~ (85^2)/10000,(90^2)/10000,
      plot == 7 ~ 0.6000),
    block = ifelse(plot %in% c(1:3, 8), yes = "valley", no = "ridge"),
    trt = dplyr::case_when(
      plot %in% c(1, 5) ~ "girdled",
      plot %in% c(2, 4) ~ "logged",
      plot %in% c(3, 6) ~ "hemlock",
      TRUE ~ "hardwood"),
    spgr = dplyr::case_when(
      species == "ACRU" ~ "red maple",
      species %in% c('BELE', 'BEAL', 'BEPA', 'BEPO') ~ 'birch',
      species == 'PIST' ~ 'white pine', 
      species %in% c('QURU', 'QUVE','QUAL', 'QUBI') ~ 'oak',
      species == 'TSCA' ~ 'hemlock',
      TRUE ~ "other hardwood")) %>% 
  dplyr::mutate(
    intervalt04 = NA,
    intervalt09 = ifelse(cond09 %in% c('L','D'), yes = 2009 - yeart0, no = NA),
    intervalt09 = ifelse(intervalt09 == 0, yes = 5, no = intervalt09),
    intervalt141924 = 5
  )

# Check structure
dplyr::glimpse(hfr_tree_v02)

# Exclude some rows/columns
hfr_tree_v03 <- hfr_tree_v02 %>% 
  dplyr::filter(tolower(note14) != "off hf" | is.na(note14))

# Check structure
dplyr::glimpse(hfr_tree_v03)

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
write.csv(hfr_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_HFR_hemlock-removal.csv"))

# End ----
