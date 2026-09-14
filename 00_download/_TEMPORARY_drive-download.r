## -------------------------------------------- ##
# Download Data from Google Drive
## -------------------------------------------- ##
# Purpose
## Download data not available on the Environmental Data Initiative from the group's Shared Drive
## Site-specific 'chunks' of this code will be deleted as the data are found in/uploaded to EDI

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, googledrive)

# Get set up
source(file.path("-setup.r"))
dir.create(path = file.path("data", "from-drive"), showWarnings = FALSE, recursive = TRUE)

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Download AND Data ----
## -------------------------------------------- ##

# Identify relevant Drive folder link
url <- googledrive::as_id("https://drive.google.com/drive/folders/1eAivlIGIzfXTjrE4_ki4Cgp5Ij-wqIbW")

# Get the contents of that folder
(conts <- googledrive::drive_ls(path = url))

# Download 'em (overwriting local copies if needed)
purrr::walk2(.x = conts$id, .y = conts$name,
  .f = ~ googledrive::drive_download(file = .x, overwrite = TRUE,
    path = file.path("data", "from-drive", .y)))

## -------------------------------------------- ##
# Download MCR Data ----
## -------------------------------------------- ##
# Identify relevant Drive folder link
url <- googledrive::as_id("https://drive.google.com/drive/folders/1oEPZerjUrfz3btBuzzY4MlGV5C5jbwEs")

# Get the contents of that folder
(conts <- googledrive::drive_ls(path = url))

# Download 'em (overwriting local copies if needed)
purrr::walk2(.x = conts$id, .y = conts$name,
  .f = ~ googledrive::drive_download(file = .x, overwrite = TRUE,
    path = file.path("data", "from-drive", .y)))

# End ----
