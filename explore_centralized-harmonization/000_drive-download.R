## ---------------------------------------------------- ##
# Material Legacy - Setup
## ---------------------------------------------------- ##
# Purpose
## Acquire necessary files from Google Drive
### Note this requires access to the SPARC group's Shared Drive

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, googledrive)

# Get set up
source(file = file.path("00_setup.R"))

# Clear environment
rm(list = ls()); gc()

## -------------------------------------------- ##
# 'Unready' Data ----
## -------------------------------------------- ##

# These are data files where pre-harmonization processing needs to happen
## E.g., one LTER had more than one raw file, etc.

# Define relevant Drive folder
drive_unready <- googledrive::as_id("https://drive.google.com/drive/u/0/folders/1c0_FMLDpi7AVURRFy-4q4m1j0mBK0Xf8")

# Identify data files in that folder
(unready_files <- googledrive::drive_ls(path = drive_unready, pattern = "*.csv"))

# Download all of these (overwriting local copies if any exist)
purrr::walk2(.x = unready_files$id, .y = unready_files$name,
             .f = ~ googledrive::drive_download(file = .x, overwrite = T,
                                                path = file.path("data", "raw", "not-ready", .y)))

## -------------------------------------------- ##
# Raw Data ----
## -------------------------------------------- ##

# Define relevant Drive folder
drive_raw <- googledrive::as_id("https://drive.google.com/drive/u/0/folders/14t9inCjWw7erT1c7RBLxYTPCHFTr5blf")

# Identify data files in that folder
(raw_files <- googledrive::drive_ls(path = drive_raw, pattern = "*.csv"))

# Download all of these (overwriting local copies if any exist)
purrr::walk2(.x = raw_files$id, .y = raw_files$name,
            .f = ~ googledrive::drive_download(file = .x, overwrite = T,
                                               path = file.path("data", "raw", .y)))

## -------------------------------------------- ##
# Data Key ----
## -------------------------------------------- ##

# Define relevant Drive folder
drive_key <- googledrive::as_id("https://drive.google.com/drive/u/0/folders/1DtyeqOCeMuXxOY6kDk9zNe0MtZ8TmLbC")

# Identify data files in that folder
(key_file <- googledrive::drive_ls(path = drive_key, pattern = "material-legacy_data-key"))

# Download all of these (overwriting local copies if any exist)
purrr::walk2(.x = key_file$id, .y = key_file$name,
             .f = ~ googledrive::drive_download(file = .x, overwrite = T, type = "csv",
                                                path = file.path("data", .y)))

# End ----
