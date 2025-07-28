## --------------------------------------------------------------------- ##
# Material Legacy - Harmonization
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Use a 'data key' to standardize column names and combine separate raw inputs (i.e., harmonize)

# Pre-Requisites
## Download raw data (can be done from `00_setup.R`)
## Download data key (can be done from `00_setup.R`)

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, ltertools, supportR)

# Clear environment
rm(list = ls()); gc()

## -------------------------------------------- ##
# Prepare to Harmonize ----
## -------------------------------------------- ##

# Read in key object
key <- read.csv(file = file.path("data", "material-legacy_data-key.csv"))

# Check structure
dplyr::glimpse(key)

# Any raw files not in the data key?
supportR::diff_check(old = unique(key$source),
                     new = dir(path = file.path("data", "raw"), 
                               pattern = "*.csv"))

## -------------------------------------------- ##
# Harmonize ----
## -------------------------------------------- ##

# Harmonize the data
tidy_v1 <- ltertools::harmonize(key = key, raw_folder = file.path("data", "raw"),
                                data_format = "csv", quiet = F)

# Check structure
dplyr::glimpse(tidy_v1)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Export this locally
write.csv(tidy_v1, row.names = F, na = '',
          file = file.path("data", "tidy", "01_harmonized.csv"))

# End ----
