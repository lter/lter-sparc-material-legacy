## -------------------------------------------- ##
# Standardize Data - Moorea Coral Reef (MCR)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites
## Data downloaded from EDI by `00_download-mcr.r`

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, janitor)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Tidy Coral Data ----
## -------------------------------------------- ##

# Load in the relevant file
mcr_v01 <- read.csv(file.path("data", "raw", "00_MCR__Regions master.csv"))

# Check structure
dplyr::glimpse(mcr_v01)

# Filter as needed
mcr_v02 <- mcr_v01 %>% 
  dplyr::filter(TagLab.Class.name %in% c("Acropora", "Pocillopora", "Dead coral"))

# Check structure
dplyr::glimpse(mcr_v02)

# Generate needed columns or streamline existing ones
mcr_v03 <- mcr_v02 %>% 
  # Identify study year
  dplyr::mutate(
    year = substr(x = TagLab.Date, start = 1, stop = 4),
    coral_status = ifelse(TagLab.Class.name == "Dead coral",
      yes = "dead", no = "live"))
    
# Check structure
dplyr::glimpse(mcr_v03)

## -------------------------------------------- ##
# Summarize & Reshape Coral Data ----
## -------------------------------------------- ##

# Summarize the coral area info
mcr_v04 <- mcr_v03 %>% 
  dplyr::group_by(Plot, Treatment, year, coral_status) %>% 
  dplyr::summarize(coral_m.sq = mean((TagLab.Surf..area * 0.0001), na.rm = TRUE),
    .groups = "drop")

# Check structure
dplyr::glimpse(mcr_v04)

# Reshape the data to wide format and sort by plot and year
mcr_v05 <- mcr_v04 %>% 
  tidyr::pivot_wider(names_from = coral_status, values_from = coral_m.sq) %>% 
  dplyr::arrange(Plot, year)

# Check structure
dplyr::glimpse(mcr_v05)

## -------------------------------------------- ##
# Calculate Additional Coral Metrics ----
## -------------------------------------------- ##

# Calculate some key metrics within plot
mcr_v06 <- mcr_v05 %>% 
  dplyr::group_by(Plot) %>% 
  dplyr::mutate(coral_live_start = dplyr::lag(live, n = 1L),
    coral_live_change_pct = ((live - coral_live_start) / coral_live_start) * 100,
    coral_dead_start = dplyr::lag(dead, n = 1L)) %>% 
  dplyr::ungroup()
  
# Check structure
dplyr::glimpse(mcr_v06)

# Streamline this data table somewhat
mcr_v07 <- mcr_v06 %>% 
  dplyr::filter(!is.na(coral_live_change_pct) & !is.na(coral_dead_start)) %>% 
  dplyr::select(-dead, -live, -coral_live_start) %>% 
  janitor::clean_names() %>% 
  dplyr::mutate(treatment = tolower(treatment))

# Check structure
dplyr::glimpse(mcr_v07)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
mcr_v99 <- mcr_v07 %>% 
  dplyr::rename_with(.fn = ~ tolower(gsub(pattern = "_", replacement = ".", x = .))) %>% 
  dplyr::rename(coral.live.percent.change = coral.live.change.pct,
    coral.dead.m2.start = coral.dead.start)

# One last structure check
dplyr::glimpse(mcr_v99)

# Export locally
write.csv(mcr_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_MCR_corals.csv"))

# End ----
