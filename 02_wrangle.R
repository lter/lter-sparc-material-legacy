## --------------------------------------------------------------------- ##
# Material Legacy - Harmonization
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Do quality control checks, filtering, and data structure edits
## Includes anything important before analysis

# Pre-Requisites
## Have harmonized data (can be done by running `01_harmonize.R`)

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, supportR)

# Clear environment
rm(list = ls()); gc()

# Read in data
qc_v1 <- read.csv(file.path("data", "tidy", "01_harmonized.csv")) %>% 
  # Make empty cells into true NAs
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                              .fns = ~ ifelse(nchar(.) == 0, yes = NA, no = .)))

# Check structure
dplyr::glimpse(qc_v1)

## -------------------------------------------- ##
# Identify 'LTER' ----
## -------------------------------------------- ##

# Want 'LTER' as a separate column
qc_v2 <- qc_v1 %>% 
  tidyr::separate_wider_delim(cols = source, delim = "___", 
                              names = c("lter", "junk"), 
                              cols_remove = F) %>% 
  dplyr::relocate(lter, .after = source) %>% 
  dplyr::select(-junk)

# Re-check structure
dplyr::glimpse(qc_v2)

## -------------------------------------------- ##
# Handle Years / Dates ----
## -------------------------------------------- ##

# Want year information for all data where it is available
qc_v3 <- qc_v2 %>% 
  # Strip year out from certain formats of date
  dplyr::mutate(year.yy = ifelse(!is.na(date_m.d.yy),
                                 yes = as.numeric(stringr::str_sub(string = date_m.d.yy, 
                                                                   start = nchar(date_m.d.yy) - 1, 
                                                                   end = nchar(date_m.d.yy))),
                                 no = NA)) %>% 
  # Make a single year column
  dplyr::mutate(year = dplyr::case_when(
    !is.na(year) ~ as.character(year),
    !is.na(year.yy) & year.yy <= 9 ~ paste0("200", year.yy),
    !is.na(year.yy) & year.yy > 9 & year.yy < 26 ~ paste0("20", year.yy),
    !is.na(year.yy) & year.yy >= 26 ~ paste0("19", year.yy),
    !is.na(date_yyyy.mm.dd) ~ stringr::str_sub(date_yyyy.mm.dd, start = 1, end = 4),
    source == "BNZ___AK2004 sites seeds.csv" ~ "2004",
    T ~ NA)) %>% 
  # Make year truly numeric
  dplyr::mutate(year = as.numeric(year)) %>% 
  # Ditch temporary columns and date columns
  dplyr::select(-year.yy, -date_m.d.yy, -date_yyyy.mm.dd)

# How many years were identified?
supportR::count_diff(vec1 = qc_v2$year, vec2 = qc_v3$year, what = NA)

# Check structure
dplyr::glimpse(qc_v3)

## -------------------------------------------- ##
# Filter Unwanted Info ----
## -------------------------------------------- ##




## -------------------------------------------- ##
# Aggregate Responses (As Needed) ----
## -------------------------------------------- ##




## -------------------------------------------- ##
# Reorder Columns ----
## -------------------------------------------- ##



## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final data object
qc_v99 <- qc_v3

# Export this locally
write.csv(qc_v99, row.names = F, na = '',
          file = file.path("data", "tidy", "02_wrangled.csv"))

# End ----
