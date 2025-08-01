## --------------------------------------------------------------------- ##
# Material Legacy - Pre-Processing
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Harmonization expects one data file per site
## This code does needed joining to get from multiple raw files to a single raw (mostly) file
## This script works on data from: Konza Prairie (KNZ) LTER

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse)

# Clear environment
rm(list = ls()); gc()

# Identify files for this site
(focal_files <- dir(path = file.path("data", "raw", "not-ready"), pattern = "KNZ___") )

## -------------------------------------------- ##
# Wrangle Input (Burn Years) ----
## -------------------------------------------- ##

# Read in data
knz_burn_v1 <- read.csv(file.path("data", "raw", "not-ready", focal_files[[1]]))

# Check structure
dplyr::glimpse(knz_burn_v1)

# Do needed wrangling
knz_burn_v2 <- knz_burn_v1 %>% 
  # Filter to desired watershed(s)
  dplyr::filter(Watershed == "2D")

# Re-check structure
dplyr::glimpse(knz_burn_v2)

## -------------------------------------------- ##
# Wrangle Input (Annually-Burned Watersheds) ----
## -------------------------------------------- ##

# Read in data
knz_1y_v1 <- read.csv(file.path("data", "raw", "not-ready", focal_files[[2]]))

# Check structure
dplyr::glimpse(knz_1y_v1)

# Do needed wrangling
knz_1y_v2 <- knz_1y_v1 %>% 
  # Filter to desired watershed(s)
  dplyr::filter(WATERSHED == "001d") %>% 
  # Summarize grass by year, soil type, and transect
  dplyr::group_by(RECYEAR, SOILTYPE, TRANSECT) %>% 
  dplyr::summarize(lvgrass_mean = mean(LVGRASS, na.rm = T),
                   .groups = "keep") %>% 
  dplyr::ungroup() %>% 
  # Add burn category
  dplyr::mutate(burn_categ = "burned")

# Re-check structure
dplyr::glimpse(knz_1y_v2)

## -------------------------------------------- ##
# Wrangle Input (Biannually-Burned Watersheds) ----
## -------------------------------------------- ##

# Read in data
knz_2y_v1 <- read.csv(file.path("data", "raw", "not-ready", focal_files[[3]]))

# Check structure
dplyr::glimpse(knz_2y_v1)

# Do needed wrangling
knz_2y_v2 <- knz_2y_v1 %>% 
  # Filter to desired watershed(s)
  dplyr::filter(WATERSHED == "002d") %>% 
  # Summarize grass by year, soil type, and transect
  dplyr::group_by(RECYEAR, SOILTYPE, TRANSECT) %>% 
  dplyr::summarize(lvgrass_mean = mean(LVGRASS, na.rm = T),
                   .groups = "keep") %>% 
  dplyr::ungroup() %>% 
  # Add burn category
  dplyr::mutate(burn_categ = "unburned")

# Re-check structure
dplyr::glimpse(knz_2y_v2)

## -------------------------------------------- ##
# Combine Inputs ----
## -------------------------------------------- ##

# Combine the data
knz_v1 <- dplyr::bind_rows(knz_1y_v2, knz_2y_v2) %>% 
  # Keep only years that *were not* in the burning dataframe
  dplyr::filter(RECYEAR %in% unique(knz_burn_v2$Year) != T) %>% 
  # And keep only Florentine soils
  dplyr::filter(SOILTYPE == "fl")

# Check structure
dplyr::glimpse(knz_v1)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final object
knz_actual <- knz_v1

# Decide on a nice new file name
knz_name <- "KNZ___processed-data.csv"

# Export a new file locally
write.csv(x = knz_actual, row.names = F,
          file = file.path("data", "raw", knz_name))

# Upload to the relevant Drive folder
googledrive::drive_upload(media = file.path("data", "raw", knz_name), overwrite = T,
                          path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/14t9inCjWw7erT1c7RBLxYTPCHFTr5blf"))

# End ----
