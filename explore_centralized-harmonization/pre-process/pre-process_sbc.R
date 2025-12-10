# ## --------------------------------------------------------------------- ##
# # Material Legacy - Pre-Processing
# ## --------------------------------------------------------------------- ##
# # Code author(s): Nick J Lyon, 
# 
# # Purpose
# ## Harmonization expects one data file per site
# ## This code does needed joining to get from multiple raw files to a single raw (mostly) file
# ## This script works on data from: Santa Barbara Coastal (SBC) LTER
# 
# ## -------------------------------------------- ##
# # Housekeeping ----
# ## -------------------------------------------- ##
# 
# # Load libraries
# librarian::shelf(tidyverse)
# 
# # Clear environment
# rm(list = ls()); gc()
# 
# # Identify files for this site
# (focal_files <- dir(path = file.path("data", "raw", "not-ready"), pattern = "SBC___") )
# 
# ## -------------------------------------------- ##
# # Join Inputs ----
# ## -------------------------------------------- ##
# 
# # Read in data
# sbc_dead_v1 <- read.csv(file.path("data", "raw", "not-ready", focal_files[[1]]))
# sbc_live_v1 <- read.csv(file.path("data", "raw", "not-ready", focal_files[[2]]))
# 
# # Check structure
# dplyr::glimpse(sbc_dead_v1)
# dplyr::glimpse(sbc_live_v1)
# 
# # Join the data
# 
# ## -------------------------------------------- ##
# # Export ----
# ## -------------------------------------------- ##
# 
# # Make a final object
# sbc_actual <- sbc_v2
# 
# # Decide on a nice new file name
# sbc_name <- "SBC___processed-data.csv"
# 
# # Export a new file locally
# write.csv(x = sbc_actual, row.names = F,
#           file = file.path("data", "raw", sbc_name))
# 
# # Upload to the relevant Drive folder
# googledrive::drive_upload(media = file.path("data", "raw", sbc_name), overwrite = T,
#                           path = googledrive::as_id("https://drive.google.com/drive/u/0/folders/14t9inCjWw7erT1c7RBLxYTPCHFTr5blf"))
# 
# # End ----
