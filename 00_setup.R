## --------------------------------------------------------------------- ##
# Material Legacy - Setup
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Create needed folders
## Acquire necessary files from Google Drive
### Note this requires access to the SPARC group's Shared Drive

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, googledrive)

# Clear environment
rm(list = ls()); gc()

## -------------------------------------------- ##
# Folders -----
## -------------------------------------------- ##

# Create needed folders
dir.create(path = file.path("data", "raw"), showWarnings = F, recursive = T)
dir.create(path = file.path("data", "tidy"), showWarnings = F)

## -------------------------------------------- ##
# Raw Data -----
## -------------------------------------------- ##

# Define relevant Drive folder
drive_raw <- googledrive::as_id("https://drive.google.com/drive/u/0/folders/14t9inCjWw7erT1c7RBLxYTPCHFTr5blf")

# Identify data files in that folder
(raw_files <- googledrive::drive_ls(path = drive_raw, pattern = "*.csv"))

# Download all of these (overwriting local copies if any exist)
purrr::walk2(.x = raw_files$id, .y = raw_files$name,
            .f = ~ googledrive::drive_download(file = .x, overwrite = T,
                                               path = file.path("data", "raw", .y)))

# End ----
