## --------------------------------------------------------------------- ##
# Material Legacy - Pre-Processing
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Harmonization expects one data file per site
## This code does needed joining to get from multiple raw files to a single raw (mostly) file
## This script works on data from: Luquillo (LUQ) LTER

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, googledrive)

# Clear environment
rm(list = ls()); gc()

# Identify files for this site
(focal_files <- dir(path = file.path("data", "raw", "not-ready"), pattern = "LUQ___") )

## -------------------------------------------- ##
# Join Inputs ----
## -------------------------------------------- ##

# Read in the relevant files
luq_trt_v1 <- read.csv(file = file.path("data", "raw", "not-ready", focal_files[[1]]))
luq_seed_v1 <- read.csv(file = file.path("data", "raw", "not-ready", focal_files[[2]]))

# Check structure
dplyr::glimpse(luq_trt_v1)
dplyr::glimpse(luq_seed_v1)

# Streamline treatment info
luq_trt_v2 <- luq_trt_v1 %>% 
  dplyr::select(-SUBPLOT) %>% 
  dplyr::distinct()

# Join!
luq_v1 <- dplyr::full_join(luq_seed_v1, luq_trt_v2,
                           by = c("BLOCK", "PLOT"))

# Re-check structure
dplyr::glimpse(luq_v1)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final object
luq_actual <- luq_v1

# Decide on a nice new file name
luq_name <- "LUQ___procssed-data.csv"

# Export a new file locally
write.csv(x = luq_actual, row.names = F,
          file = file.path("data", "raw", luq_name))

# Upload to the relevant Drive folder
googledrive::drive_upload(media = file.path("data", "raw", luq_name), overwrite = T,
                          path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/14t9inCjWw7erT1c7RBLxYTPCHFTr5blf"))

# End ----
