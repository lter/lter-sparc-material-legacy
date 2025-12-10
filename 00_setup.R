## ---------------------------------------------------- ##
# Material Legacy - Setup
## ---------------------------------------------------- ##
# Purpose
## Do any generally-useful setup tasks

# Load libraries
librarian::shelf(tidyverse)

# Clear environment
rm(list = ls()); gc()

## -------------------------------------------- ##
# Make Folders ----
## -------------------------------------------- ##

# Create needed data folders
dir.create(path = file.path("data", "raw"), showWarnings = F, recursive = T)
dir.create(path = file.path("data", "raw", "not-ready"), showWarnings = F)
dir.create(path = file.path("data", "tidy"), showWarnings = F)

# Graphing folders
dir.create(path = file.path("graphs"), showWarnings = F)

# End ----
