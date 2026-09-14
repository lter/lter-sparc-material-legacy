## -------------------------------------------- ##
# Standardize Data - Harvard Forest (HFR)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites
## Data downloaded from EDI by `00_download-hfr.r`

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Tidy Sapling Data ----
## -------------------------------------------- ##

# Read in the relevant file(s)
hfr_v01 <- read.csv(file.path("data", "raw", "00_HFR__hf106-05-sapling.csv"))

# Check structure
dplyr::glimpse(hfr_v01)

# Do necessary wrangling / tidying
hfr_v02 <- hfr_v01 %>% 
  dplyr::mutate(
    species = ifelse(nchar(species) == 0 | is.na(species),
      yes = "none", no = species),
    spgroup = dplyr::case_when(
      species == "TSCA" ~ "hemlock",
      species %in% c("BEAL", "BELE") ~ "birch",
      TRUE ~ "other"),
    trt = dplyr::case_when(
      plot %in% c(1, 5) ~ "girdled",
      plot %in% c(2, 4) ~ "logged",
      plot %in% c(3, 6) ~ "hemlock",
      TRUE ~ "hardwood"),
    block = ifelse(plot %in% c(1:3, 8), yes = "valley", no = "ridge"),
    n.ha = total / 0.09) # [ABP]: "divide by size of center section of plot"

# Check structure
dplyr::glimpse(hfr_v02)

# Do desired filtering
hfr_v03 <- hfr_v02 %>% 
  dplyr::filter(trt %in% c("girdled", "logged")) %>% 
  # dplyr::filter(stratum == "Sapling") %>% 
  dplyr::filter(year > 2004)

# Check structure
dplyr::glimpse(hfr_v03)

# Summarize to get density
hfr_v04 <- hfr_v03 %>% 
  dplyr::group_by(plot, trt, block, year, species, spgroup) %>% 
  dplyr::summarize(density.ha = sum(n.ha, na.rm = TRUE),
  .groups = "drop") %>% 
  dplyr::group_by(plot, trt, block, year, spgroup) %>%
  dplyr::summarize(dens_ha = sum(density.ha, na.rm = TRUE),
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
