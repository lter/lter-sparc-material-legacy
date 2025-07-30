## --------------------------------------------------------------------- ##
# Material Legacy - Calculate Effect Sizes
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Fit models for each LTER and extract effect sizes

# Pre-Requisites
## Have wrangled data (can be done by running `02_wrangle.R`)

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, supportR)

# Clear environment
rm(list = ls()); gc()

# Read in data
ef_v1 <- read.csv(file.path("data", "tidy", "02_wrangled.csv"))

# Check structure
dplyr::glimpse(ef_v1)


## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final data object
ef_v99 <- ef_v1

# Export this locally
write.csv(ef_v99, row.names = F, na = '',
          file = file.path("data", "tidy", "03_effect-sizes.csv"))

# End ----
