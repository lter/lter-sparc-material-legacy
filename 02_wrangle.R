## --------------------------------------------------------------------- ##
# Material Legacy - Harmonization
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Do quality control checks, filtering, and data structure edits
## Includes anything important before analysis

# Pre-Requisites
## Have harmonized data (can be done by running `01_harmonize.R`)

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, supportR)

# Clear environment
rm(list = ls()); gc()

# Read in data
qc_v1 <- read.csv(file.path("data", "tidy", "01_harmonized.csv"))

# Check structure
dplyr::glimpse(qc_v1)

## -------------------------------------------- ##
#  ----
## -------------------------------------------- ##


## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final data object
qc_v99 <- qc_v1

# Export this locally
write.csv(qc_v99, row.names = F, na = '',
          file = file.path("data", "tidy", "02_wrangled.csv"))

# End ----
