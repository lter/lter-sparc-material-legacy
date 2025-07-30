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
#  ----
## -------------------------------------------- ##



# End ----
