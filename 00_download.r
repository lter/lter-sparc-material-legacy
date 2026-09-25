## -------------------------------------------- ##
# Download Raw Data
## -------------------------------------------- ##
# Purpose
## Download data from the Environmental Data Initiative (EDI)
## Also downloads data from Google Drive as/if needed

# Load libraries
# install.packages("librarian")
librarian::shelf(EDIutils, tidyverse, tools, googledrive)

# Get set up
source(file.path("-setup.r"))
dir.create(path = file.path("data", "from-drive"), showWarnings = FALSE, recursive = TRUE)

# Clear environment/collect garbage
rm(list = ls()); gc()

# Assemble full list of EDI package IDs for all sites
edi_data <- dplyr::bind_rows(
  data.frame(site_abbrev = "AND", id = c("knb-lter-and.4032.10", "knb-lter-and.2742.28")),
  data.frame(site_abbrev = "BNZ", id = c("knb-lter-bnz.342.21", "knb-lter-bnz.390.18")),
  data.frame(site_abbrev = "FCE", id = c("knb-lter-fce.1278.1", "knb-lter-fce.1195.14")),
  data.frame(site_abbrev = "GCE", id = "knb-lter-gce.590.37"),
  data.frame(site_abbrev = "HFR", id = "knb-lter-hfr.106.35"),
  data.frame(site_abbrev = "KNZ", id = c("knb-lter-knz.55.19", "knb-lter-knz.56.8", "knb-lter-knz.42.20")),
  data.frame(site_abbrev = "LUQ", id = c("knb-lter-luq.165.519604", "knb-lter-luq.143.1058123")),
  data.frame(site_abbrev = "MCR", id = "knb-lter-mcr.5063.1"),
  data.frame(site_abbrev = "SONGS", id = "edi.2041.1"),
  data.frame(site_abbrev = "VCR", id = "knb-lter-vcr.351.8") )

# Check structure
dplyr::glimpse(edi_data)

## -------------------------------------------- ##
# Authentication with EDI ----
## -------------------------------------------- ##
# The following code will prompt you to define your EDI Access Key
## !!! Make one _before_ attempting to run this code !!!
### For instructions on getting an EDI Access Key,
### Watch this YouTube video: https://youtu.be/fieZSmHk2H4?si=Wo9a5GsAOYp3dnWS
### Or check out EDI's Identity & Access Manager: (ttps://auth.edirepository.org

# Define your EDI key
(edi_key <- readline(prompt = "Copy/paste your EDI Access Key here: "))

# Log in with that key
EDIutils::login(key = edi_key)

# Set HTTP option
options(HTTPUserAgent = "EDI_CodeGen")

## -------------------------------------------- ##
# Download Data From EDI ----
## -------------------------------------------- ##

# If data are already downloaded, should they be downloaded again?
overwrite <- FALSE

# Identify data that are already present locally
(local_raw <- dir(path = file.path("data", "raw"), pattern = "*.csv"))

# Iterate across package IDs
for(pkg_id in edi_data$id){
  # pkg_id <- "knb-lter-vcr.351.8"

  # Grab focal site abbreviation
  focal_abbrev <- edi_data$site_abbrev[edi_data$id == pkg_id]

  # Progress message
  message("Downloading ", focal_abbrev, " data from '", pkg_id, "'")

  # Check out data
  (ents <- EDIutils::read_data_entity_names(packageId = pkg_id) %>% 
    dplyr::mutate(local_name = paste0("00_", focal_abbrev, "__", entityName)))

  # Loop across entities
  for(k in seq_along(ents$entityName)){
    # k <- 2

    # Progress message
    message("Downloading file ", k, " of ", nrow(ents))

    # Grab just that entity
    focal_ent <- ents[k, ]

    # Identify entity file type
    ent_type <- tools::file_ext(focal_ent$entityName)

    # If unidentified, assume CSV
    if(nchar(ent_type) == 0 | is.na(ent_type)){
      focal_ent$entityName <- paste0(focal_ent$entityName, ".csv")
      focal_ent$local_name <- paste0(focal_ent$local_name, ".csv")
    }

    # Skip the download step (and all assoc. computation) if _either_:
    ## (A) it's present locally and overwriting isn't desired
    if(overwrite != TRUE & focal_ent$local_name %in% local_raw){
      message("Skipping download because file is already downloaded")
      next } 
    ## (B) it's not a tabular data file
    if(tools::file_ext(focal_ent$entityName) %in% c("txt", "csv", "xls", "xlsx") != TRUE){
      message("Skipping download because file is a ", tools::file_ext(focal_ent$entityName))
      next } 

    # Assemble URL to that entity
    in_url <- paste0("https://pasta.lternet.edu/package/data/eml/",
      gsub(pattern = "\\.", "/", x = pkg_id), "/",
      focal_ent$entityId, "?key=", edi_key)
    
    # Assemble local file name
    in_file <- file.path("data", "raw", paste0(focal_ent$local_name))

    # If the entity is a data file, download it!
    download.file(url = in_url, destfile =  in_file,
      method = "curl", extra = paste0(' -A "', getOption("HTTPUserAgent"), '"')) 
    
  } # Close entity loop
} # Close EDI package ID loop

## -------------------------------------------- ##
# Download AND Data From Google Drive ----
## -------------------------------------------- ##
# The following code will attempt to download data not available on EDI from this group's Shared Google Drive
## !!! Authenticate _before_ attempting to run this code !!!
### For instructions on `googledrive` authentication,
### Check out this tutorial: https://lter.github.io/scicomp/tutorial_googledrive-pkg.html

# Identify relevant Drive folder link
drive_url <- googledrive::as_id("https://drive.google.com/drive/folders/1eAivlIGIzfXTjrE4_ki4Cgp5Ij-wqIbW")

# Get the contents of that folder
(drive_and <- googledrive::drive_ls(path = drive_url) %>% 
  dplyr::filter(name == "TP00112_v13.csv"))

# Download 'em (overwriting local copies if needed)
purrr::walk2(.x = drive_and$id, .y = drive_and$name,
  .f = ~ googledrive::drive_download(file = .x, overwrite = TRUE,
    path = file.path("data", "from-drive", .y)))

# End ----
