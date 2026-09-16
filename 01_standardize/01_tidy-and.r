## -------------------------------------------- ##
# Standardize Data - Andrews Forest (AND)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites

## !!! DATA SOURCE NOTE !!!
# Data taken from Google Drive (_not_ EDI)
## Data downloaded from Google Drive by `_TEMPORARY_drive-download.r`
## !!! SEE ABOVE !!!

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, janitor, supportR)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Identify Focal Plots ----
## -------------------------------------------- ##

# Load dead data
# and_plots_v01 <- read.csv(file = file.path("data", "from-drive", "OHJA_downed wood summary_v2.csv")) %>% 
#   janitor::clean_names()

# # Check structure
# dplyr::glimpse(and_plots_v01)

# # Pare down to just what is needed
# and_plots_v02 <- and_plots_v01 %>% 
#   dplyr::select(stand, plot, cwd_year = year) %>% 
#   dplyr::distinct()

# # Check structure
# dplyr::glimpse(and_plots_v02)

## -------------------------------------------- ##
# Parse Tree Data ----
## -------------------------------------------- ##

# # Load relevant files
# init <- read.csv(file.path("data", "raw", "00_AND__Initial tree conditions with spatial coordinates.csv"))
# str(init)


# tree <- read.csv(file.path("data", "raw", "00_AND__Individual tree remeasurement.csv"))
# str(tree)

# message("Number of trees = ", length(unique(tree$TREEID)))

# mort <- read.csv(file.path("data", "raw", "00_AND__Individual tree mortality.csv"))
# str(mort)


# meas <- read.csv(file.path("data", "from-drive", "TP00112_v13.csv")) %>% 
#   dplyr::mutate(StandID = substr(PLOTID,1,4),
#   Plot = as.integer(substr(PLOTID,5,8)),
#   .before = dplyr::everything())
# str(meas)

## -------------------------------------------- ##
# Load Live & Dead Wood Data ----
## -------------------------------------------- ##

# Load dead data
and_dead <- read.csv(file = file.path("data", "from-drive", "OHJA_downed wood summary_v2.csv")) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(and_dead)

# Load live data
and_live <- read.csv(file = file.path("data", "from-drive", "PSP_Plot_Change_20year_PSME.csv")) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(and_live)

## -------------------------------------------- ##
# Combine Live & Dead Wood ----
## -------------------------------------------- ##

# Join these files
and_v01 <- dplyr::inner_join(x = and_dead, y = and_live,
    by = c("stand", "plot", "year" = "cwd_year"))

# Check structure
dplyr::glimpse(and_v01)

# Calculate desired metrics
and_v02 <- and_v01 %>% 
  dplyr::mutate(dw_mass_ha = (total_mass / area_ha),
    dw_vol_ha = (total_volume / area_ha),
    dw_cover_ha = (total_cover / area_ha),
    dw_area_ha = (total_area / area_ha),
    tree_growth_ind = (growth_baph_spp / (tph0_spp * surv_prop_spp) / d_year))

# Check structure
dplyr::glimpse(and_v02)

# Pare down to only needed columns
and_v03 <- and_v02 %>% 
  dplyr::select(stand, plot, year, baph0_spp, baoh1_spp, dw_mass_ha:tree_growth_ind)

# Check what was lost
supportR::diff_check(old = names(and_v02), new = names(and_v03))

# Check structure
dplyr::glimpse(and_v03)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final version of the data
and_v99 <- and_v03 %>% 
  dplyr::rename_with(.fn = ~ tolower(gsub(pattern = "_", replacement = ".", x = .))) %>% 
  dplyr::select(stand, 
    tree.growth.m2.indiv.yr = tree.growth.ind, ## Tree growth (Douglas fir; m2/ind./yr)
    dead.wood.mass.kg.ha = dw.mass.ha) ## Dead wood mass (kg/ha)

# One last structure check
dplyr::glimpse(and_v99)

# Export locally
write.csv(and_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_AND_live-dead-wood.csv"))

# End ----
