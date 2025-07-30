## --------------------------------------------------------------------- ##
# Material Legacy - Upload Products to Drive
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Upload data products of earlier scripts into the relevant part(s) of the Drive

# Pre-Requisites
## Have run at least one of the numbered scripts preceding 99

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, googledrive)

# Clear environment
rm(list = ls()); gc()

## -------------------------------------------- ##
# Tidy Data ----
## -------------------------------------------- ##

# Identify relevant files
(tidy_local <- dir(path = file.path("data", "tidy")))

# Identify destination Drive folder
tidy_drive <- googledrive::as_id("https://drive.google.com/drive/u/0/folders/16OmDBb4tf1qZkPZSs8n5y5kFJsiGlOQ1")

# Upload tidied data files to Drive
purrr::walk(.x = tidy_local,
            .f = ~ googledrive::drive_upload(media = file.path("data", "tidy", .x), 
                                             overwrite = T, path = tidy_drive))

# End ----
