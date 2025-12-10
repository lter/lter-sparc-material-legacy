## --------------------------------------------------------------------- ##
# Material Legacy - Pre-Processing
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## This site's raw file requires special wrangling to get into the right shape for later use
## This script works on data from: Moorea Coral Reef (MCR) LTER

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse)

# Clear environment
rm(list = ls()); gc()

# Identify file(s) for this site
(focal_files <- dir(path = file.path("data", "raw", "not-ready"), pattern = "MCR___") )

## -------------------------------------------- ##
# Process Input ----
## -------------------------------------------- ##

# Read in data
mcr_v1 <- read.csv(file = file.path("data", "raw", "not-ready", focal_files[[1]]))

# Check structure
dplyr::glimpse(mcr_v1)

# Do needed processing
mcr_v2 <- mcr_v1 %>% 
  # Identify study year
  dplyr::mutate(year = paste0("20", stringr::str_sub(string = TagLab.Date,
                                                     start = nchar(TagLab.Date) - 1,
                                                     end = nchar(TagLab.Date)))) %>% 
  # Remove unwanted coral classes
  dplyr::filter(TagLab.Class.name %in% c("Acropora", "Pocillopora", "Dead coral")) %>% 
  # Divide coral into live or dead
  dplyr::mutate(coral_status = ifelse(TagLab.Class.name == "Dead coral",
                                      yes = "coral_dead", no = "coral_live")) %>% 
  # Summarize coral area within groups
  dplyr::group_by(Plot, Treatment, year, coral_status) %>% 
  dplyr::summarize(coral_m.sq = mean(TagLab.Surf..area * 0.0001, na.rm = T),
                   .groups = "keep") %>% 
  dplyr::ungroup() %>% 
  # Reshape wider
  tidyr::pivot_wider(names_from = coral_status, values_from = coral_m.sq) %>% 
  # Sort by plot and year
  dplyr::arrange(Plot, year) %>% 
  # Calculate some key metrics within plot
  dplyr::group_by(Plot) %>% 
  dplyr::mutate(
    coral_live_start = dplyr::lag(coral_live),
    coral_live_change_pct = ((coral_live - coral_live_start) / coral_live_start) * 100,
    coral_dead_start = dplyr::lag(coral_dead)
  ) %>% 
  dplyr::ungroup() %>% 
  # Filter missing values
  dplyr::filter(!is.na(coral_live_change_pct) & !is.na(coral_dead_start)) %>% 
  # Drop unwanted columns
  dplyr::select(-coral_dead, -coral_live, -coral_live_start)

# Re-check structure
dplyr::glimpse(mcr_v2)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final data object
mcr_actual <- mcr_v2

# Check its structure
dplyr::glimpse(mcr_actual)

# Decide on a nice new file name
mcr_name <- "MCR___processed-data.csv"

# Export a new file locally
write.csv(x = mcr_actual, row.names = F, file = file.path("data", "raw", mcr_name))

# Upload to the relevant Drive folder
googledrive::drive_upload(media = file.path("data", "raw", mcr_name), overwrite = T,
                          path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/14t9inCjWw7erT1c7RBLxYTPCHFTr5blf"))

# End ----
