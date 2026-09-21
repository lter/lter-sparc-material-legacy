## -------------------------------------------- ##
# Download Data - Moorea Coral Reef (MCR)
## -------------------------------------------- ##
# Purpose
## Download data from this site from the Environmental Data Initiative

# Load libraries
# install.packages("librarian")
librarian::shelf(EDIutils, tidyverse, tools)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

# Define 3-letter site abbreviation
site_abbrev <- "MCR"

## -------------------------------------------- ##
# Authentication with EDI ----
## -------------------------------------------- ##
# The following code will prompt you to define your EDI Access Key
## !!! Make one _before_ attempting to run this code !!!
## See the README of this folder for details: 
### https://github.com/lter/lter-sparc-material-legacy_data/tree/main/00_download-data#edi-authentication

# Define your EDI key
(edi_key <- readline(prompt = "Copy/paste your EDI Access Key here: "))

# Log in with that key
EDIutils::login(key = edi_key)

# Set HTTP option
options(HTTPUserAgent = "EDI_CodeGen")

## -------------------------------------------- ##
# Download Data ----
## -------------------------------------------- ##

# Iterate across package IDs
for(pkg_id in c("knb-lter-mcr.5063.1")){
  # pkg_id <- "knb-lter-mcr.5063.1"

  # Check out data
  (ents <- EDIutils::read_data_entity_names(packageId = pkg_id))

  # Loop across entities
  for(k in seq_along(ents$entityName)){
    # k <- 2

    # Grab just that entity
    focal_ent <- ents[k, ]

    # Progress message
    message("Downloading file ", k, " of ", nrow(ents))
    
    # Assemble URL to that entity
    in_url <- paste0("https://pasta.lternet.edu/package/data/eml/",
      gsub(pattern = "\\.", "/", x = pkg_id), "/",
      focal_ent$entityId, "?key=", edi_key)

    # Identify entity file type
    ent_type <- tools::file_ext(focal_ent$entityName)
    
    # If unidentified, assume CSV
    if(nchar(ent_type) == 0 | is.na(ent_type)){
      focal_ent$entityName <- paste0(focal_ent$entityName, ".csv")
    }
    
    # Assemble local file name
    in_file <- file.path("data", "raw",
      paste0("00_", site_abbrev, "__", focal_ent$entityName))

    # If the entity is a data file, download it!
    if(tools::file_ext(focal_ent$entityName) %in% c("txt", "csv", "xls", "xlsx")){
      download.file(url = in_url, destfile =  in_file,
        method = "curl", extra = paste0(' -A "', getOption("HTTPUserAgent"), '"')) 
    } else { message("Skipping download because file is a ", 
      tools::file_ext(focal_ent$entityName)) }    
  }
}

# End ----
