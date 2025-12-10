## --------------------------------------------------------------------- ##
# Material Legacy - Pre-Processing
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Harmonization expects one data file per site
## This code does needed joining to get from multiple raw files to a single raw (mostly) file
## This script works on data from: Florida Coastal Everglades (FCE) LTER

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, googledrive)

# Clear environment
rm(list = ls()); gc()

# Identify files for this site
(focal_files <- dir(path = file.path("data", "raw", "not-ready"), pattern = "FCE___") )

## -------------------------------------------- ##
# Wrangle Input (Roots) ----
## -------------------------------------------- ##

# Read in data
fce_root_v1 <- read.csv(file.path("data", "raw", "not-ready", focal_files[[1]]))

# Check structure
dplyr::glimpse(fce_root_v1)

# Do needed wrangling
fce_root_v2 <- fce_root_v1 %>% 
  # Filter to only fine roots with non-zero production
  dplyr::filter(Root_size_class == "Fine" & Root_Production > 0) %>% 
  # Generate a new plot column using the point information
  dplyr::mutate(plot = dplyr::case_when(
    Point %in% c("A", "B") ~ 1,
    Point %in% c("C", "D") ~ 2,
    T ~ NA)) %>% 
  # Summarize root production within plot and site
  dplyr::group_by(SITENAME, plot) %>% 
  dplyr::summarize(root_prod_mean = mean(Root_Production, na.rm = T),
                   root_prod_sd = sd(Root_Production, na.rm = T),
                   root_prod_se = root_prod_sd / sqrt(dplyr::n()),
                   .groups = "keep") %>% 
  dplyr::ungroup()

# Re-check structure
dplyr::glimpse(fce_root_v2)

## -------------------------------------------- ##
# Wrangle Input (Litter) ----
## -------------------------------------------- ##

# Read in data
fce_litter_v1 <- read.csv(file.path("data", "raw", "not-ready", focal_files[[2]]))

# Check structure
dplyr::glimpse(fce_litter_v1)

# Do needed wrangling
fce_litter_v2 <- fce_litter_v1 %>% 
  # Pare down to only dates in specified range
  dplyr::mutate(Date = as.Date(Date)) %>% 
  dplyr::filter(Date > as.Date("2017-09-17") & Date < as.Date("2019-03-01")) %>% 
  # Sum weights within baskets
  dplyr::group_by(SITENAME, Plot_ID, Basket_ID) %>% 
  dplyr::summarize(wt = sum(Total_Weight, na.rm = T),
                   .groups = "keep") %>% 
  dplyr::ungroup() %>% 
  # Average litter weight within plots (across baskets)
  dplyr::group_by(SITENAME, Plot_ID) %>% 
  dplyr::summarize(litter_weight_mean = mean(wt, na.rm = T),
                   litter_weight_sd = sd(wt, na.rm = T),
                   litter_weight_se = litter_weight_sd / sqrt(dplyr::n()),
                   .groups = "keep") %>% 
  dplyr::ungroup()

# Re-check structure
dplyr::glimpse(fce_litter_v2)

## -------------------------------------------- ##
# Join Inputs ----
## -------------------------------------------- ##

# Join the data
fce_v1 <- fce_root_v2 %>% 
  # Filter to only sites actually in the other table
  dplyr::filter(SITENAME %in% fce_litter_v2$SITENAME) %>% 
  # Do the joining
  dplyr::left_join(y = fce_litter_v2, by = c("SITENAME",
                                             "plot" = "Plot_ID"))

# Check structure
dplyr::glimpse(fce_v1)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final object
fce_actual <- fce_v1

# Decide on a nice new file name
fce_name <- "FCE___processed-data.csv"

# Export a new file locally
write.csv(x = fce_actual, row.names = F,
          file = file.path("data", "raw", fce_name))

# Upload to the relevant Drive folder
googledrive::drive_upload(media = file.path("data", "raw", fce_name), overwrite = T,
                          path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/14t9inCjWw7erT1c7RBLxYTPCHFTr5blf"))

# End ----
