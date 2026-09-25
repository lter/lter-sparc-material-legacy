## -------------------------------------------- ##
# Standardize Data
## -------------------------------------------- ##
# Purpose
## Get all sites' data into a standard format

# !!! Organization / Structure Note !!!
## Each site requires totally idiosyncratic wrangling.
## This is handled by the scripts in the "01_standardize/" folder.
## This script exists as a convenience for quickly running all of those scripts.
# !!!  (^^^) see above (^^^) !!!

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, janitor, supportR, magrittr)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Actually Perform Standardization ----
## -------------------------------------------- ##

# !!! Raw Data Note !!!
## You'll need to have all the raw inputs locally downloaded already
## You can do this by running `00_download.r`
# !!!  (^^^) see above (^^^) !!!

# Quickly standardize all sites' raw files
purrr::walk(.x = dir("01_standardize", pattern = "*.r"), 
  .f = ~ source(file.path("01_standardize", .x)))

# End ----
