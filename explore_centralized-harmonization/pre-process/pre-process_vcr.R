## --------------------------------------------------------------------- ##
# Material Legacy - Pre-Processing
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## This site's raw file requires special wrangling to summarize the response variable
## This script works on data from: Virginia Coastal Reserve (VCR) LTER

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, googledrive)

# Clear environment
rm(list = ls()); gc()

# Identify file(s) for this site
(focal_files <- dir(path = file.path("data", "raw", "not-ready"), pattern = "VCR___") )

## -------------------------------------------- ##
# Process Input ----
## -------------------------------------------- ##

# Read in data
vcr_v1 <- read.csv(file = file.path("data", "raw", "not-ready", focal_files[[1]]))

# Check structure
dplyr::glimpse(vcr_v1)

# Do needed processing
vcr_v2 <- vcr_v1 %>% 
  # Filter to desired restoration status and species
  dplyr::filter(Restoration == "Reference") %>% 
  dplyr::filter(Species %in% c("Box Adult Oyster", "Spat Oyster")) %>% 
  # Identify study year
  dplyr::mutate(year = paste0("20", stringr::str_sub(string = Date,
                                                     start = nchar(Date) - 1,
                                                     end = nchar(Date)))) %>% 
  # Get date totals of each species
  dplyr::group_by(Site, year, Date, Species) %>% 
  dplyr::summarize(spp_count = sum(Species_count, na.rm = T),
                   .groups = "keep") %>% 
  dplyr::ungroup()

# Re-check structure
dplyr::glimpse(vcr_v2)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final data object
vcr_actual <- vcr_v2

# Check its structure
dplyr::glimpse(vcr_actual)

# Decide on a nice new file name
vcr_name <- "VCR___processed-data.csv"

# Export a new file locally
write.csv(x = vcr_actual, row.names = F, file = file.path("data", "raw", vcr_name))

# Upload to the relevant Drive folder
googledrive::drive_upload(media = file.path("data", "raw", vcr_name), overwrite = T,
                          path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/14t9inCjWw7erT1c7RBLxYTPCHFTr5blf"))

# End ----
