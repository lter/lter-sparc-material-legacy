## --------------------------------------------------------------------- ##
# Material Legacy - Pre-Processing
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Harmonization expects one data file per site
## This code does needed joining to get from multiple raw files to a single raw (mostly) file
## This script works on data from: Harvard Forest (HFR) LTER

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse)

# Clear environment
rm(list = ls()); gc()

# Identify files for this site
(focal_files <- dir(path = file.path("data", "raw", "not-ready"), pattern = "HFR___") )

## -------------------------------------------- ##
# Wrangle Input (Dead) ----
## -------------------------------------------- ##

# Read in data
hfr_predictors_v1 <- read.csv(file.path("data", "raw", "not-ready", focal_files[[1]]))

# Check structure
dplyr::glimpse(hfr_predictors_v1)

# Do needed wrangling
hfr_predictors_v2 <- hfr_predictors_v1

# Re-check structure
dplyr::glimpse(hfr_predictors_v2)

## -------------------------------------------- ##
# Wrangle Input (Live) ----
## -------------------------------------------- ##

# Read in data
hfr_live_v1 <- read.csv(file.path("data", "raw", "not-ready", focal_files[[2]]))

# Check structure
dplyr::glimpse(hfr_live_v1)

# Do needed wrangling
hfr_live_v2 <- hfr_live_v1 %>% 
  # Streamline species
  dplyr::mutate(spp_group = dplyr::case_when(
    species == "TSCA" ~ "hemlock",
    species %in% c("BELE", "BEAL") ~ "birch",
    T ~ "other")) %>% 
  # Summarize density and biomass within species groups
  dplyr::group_by(plot, trt, block, year, spp_group, stratum) %>% 
  dplyr::summarize(dens_ha = sum(dens.ha, na.rm = T),
                   biomass_gm2 = sum(biomass.gm2, na.rm = T),
                   .groups = "keep") %>% 
  dplyr::ungroup() %>% 
  # Pivot to wide format
  tidyr::pivot_wider(names_from = spp_group, values_from = c(dens_ha, biomass_gm2),
                     values_fill = 0)

# Re-check structure
dplyr::glimpse(hfr_live_v2)

## -------------------------------------------- ##
# Join Inputs ----
## -------------------------------------------- ##

# Join the inputs
hfr_v1 <- hfr_live_v2 %>% 
  dplyr::left_join(y = hfr_predictors_v2, by = c("plot", "year", "trt", "block"))



## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final object
hfr_actual <- hfr_v2

# Decide on a nice new file name
hfr_name <- "HFR___processed-data.csv"

# Export a new file locally
write.csv(x = hfr_actual, row.names = F,
          file = file.path("data", "raw", hfr_name))

# Upload to the relevant Drive folder
googledrive::drive_upload(media = file.path("data", "raw", hfr_name), overwrite = T,
                          path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/14t9inCjWw7erT1c7RBLxYTPCHFTr5blf"))

# End ----
