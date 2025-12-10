## --------------------------------------------------------------------- ##
# Material Legacy - Pre-Processing
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Harmonization expects one data file per site
## This code does needed joining to get from multiple raw files to a single raw (mostly) file
## This script works on data from: Andrews Forest (AND) LTER

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, googledrive)

# Clear environment
rm(list = ls()); gc()

# Identify files for this site
(focal_files <- dir(path = file.path("data", "raw", "not-ready"), pattern = "AND___") )

## -------------------------------------------- ##
# Join Inputs ----
## -------------------------------------------- ##

# Read in data
and_dead_v1 <- read.csv(file.path("data", "raw", "not-ready", focal_files[[1]]))
and_live_v1 <- read.csv(file.path("data", "raw", "not-ready", focal_files[[2]]))

# Check structure
dplyr::glimpse(and_dead_v1)
dplyr::glimpse(and_live_v1)

# Join the data
and_v1 <- and_live_v1 %>% 
  dplyr::left_join(y = and_dead_v1, by = c("Stand" = "stand",
                                           "Plot" = "plot",
                                           "CWDYear" = "year"))

# Check structure again
dplyr::glimpse(and_v1)

## -------------------------------------------- ##
# Calculate Key Metrics ----
## -------------------------------------------- ##

# Caculate dead wood per hectare & individual tree growth rates
and_v2 <- and_v1 %>% 
  dplyr::mutate(dead_wood_mass_ha = total_mass / area_ha,
                dead_wood_vol_ha = total_volume / area_ha,
                dead_wood_cover_ha = total_cover / area_ha,
                dead_wood_area_ha = total_area / area_ha,
                tree_growth_ind = growth_baph_spp / (tph0_spp * surv_prop_spp) / dYear)

# Check structure
dplyr::glimpse(and_v2)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final object
and_actual <- and_v2

# Decide on a nice new file name
and_name <- "AND___processed-data.csv"

# Export a new file locally
write.csv(x = and_actual, row.names = F,
          file = file.path("data", "raw", and_name))

# Upload to the relevant Drive folder
googledrive::drive_upload(media = file.path("data", "raw", and_name), overwrite = T,
                          path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/14t9inCjWw7erT1c7RBLxYTPCHFTr5blf"))

# End ----
