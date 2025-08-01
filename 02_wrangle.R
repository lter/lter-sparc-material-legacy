## --------------------------------------------------------------------- ##
# Material Legacy - Wrangling
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

# Check existing 'LTER's
sort(unique(qc_v2$lter))

# Re-check structure
dplyr::glimpse(qc_v2)

## -------------------------------------------- ##
# Handle Years / Dates ----
## -------------------------------------------- ##

# Want year information for all data where it is available
qc_v3 <- qc_v2 %>% 
  # Strip year out from certain formats of date
  ## Not currently needed
  # Make a single year column
  dplyr::mutate(year = dplyr::case_when(
    !is.na(year) ~ as.character(year),
    !is.na(date_yyyy.mm.dd) ~ stringr::str_sub(string = date_yyyy.mm.dd, start = 1, end = 4),
    source == "BNZ___AK2004 sites seeds.csv" ~ "2004",
    T ~ NA)) %>% 
  # Make year truly numeric
  dplyr::mutate(year = as.numeric(year)) %>% 
  # Ditch temporary columns and date columns
  dplyr::select(-date_yyyy.mm.dd)

# How many years were identified?
supportR::count_diff(vec1 = qc_v2$year, vec2 = qc_v3$year, what = NA)

# Which datasets lack year?
qc_v3 %>% 
  dplyr::filter(is.na(year)) %>% 
  dplyr::select(source) %>% 
  dplyr::distinct()

# Check structure
dplyr::glimpse(qc_v3)

## -------------------------------------------- ##
# Filter Unwanted Info ----
## -------------------------------------------- ##

# For each dataset, there are unwanted values
## Doing this piece-wise to better show how many rows are lost per step

# AND (currently fine)
qc_v4a <- qc_v3 %>% 
  dplyr::filter(lter != "AND" | (lter == "AND"))

# BNZ (currently fine)
qc_v4b <- qc_v4a %>% 
  dplyr::filter(lter != "BNZ" | (lter == "BNZ"))

# FCE (good to go because of pre-processing)
qc_v4c <- qc_v4b %>% 
  dplyr::filter(lter != "FCE" | (lter == "FCE"))

# GCE should be only 0.25m^2 samples
qc_v4d <- qc_v4c %>% 
  dplyr::filter(lter != "GCE" | (lter == "GCE" & sample_area_m2 == 0.25))

# HFR should be only hemlock species and certain treatments and only saplings
qc_v4e <- qc_v4d %>% 
  dplyr::filter(lter != "HFR" | (lter == "HFR" & taxon == "TSCA" & 
                                   forest_stratum == "Sapling" &
                                   treatment_logging %in% c("girdled", "logged")))

# KNZ (good to go because of pre-processing)
qc_v4f <- qc_v4e %>% 
  dplyr::filter(lter != "KNZ" | (lter == "KNZ"))

# LUQ should only be some treatments and certain years
qc_v4g <- qc_v4f %>% 
  dplyr::filter(lter != "LUQ" | (lter == "LUQ" & year >= 2005 & year <= 2013 &
                                   treatment_litter %in% c("Trim&clear", "Trim+Debris")))

# MCR is good to go because of pre-processing
qc_v4h <- qc_v4g %>% 
  dplyr::filter(lter != "MCR" | (lter == "MCR"))

# SONGS should be only non-zero for response and continuous treatment
qc_v4i <- qc_v4h %>% 
  dplyr::filter(lter != "SONGS" | (lter == "SONGS" & response > 0 & 
                                     treatment_continuous > 0))

# VCR is good to go because of pre-processing
qc_v4j <- qc_v4i %>% 
  dplyr::filter(lter != "VCR" | (lter == "VCR"))

# Make final object (for this section)
qc_v5 <- qc_v4j %>% 
  # Remove unwanted columns
  dplyr::select(-sample_area_m2, -forest_stratum)

# Check final rows lost
message(nrow(qc_v3) - nrow(qc_v5), " rows lost")

# Any datasets completely lost? (shouldn't be any)
setdiff(x = unique(qc_v3$source), y = unique(qc_v5$source))

# Check structure
dplyr::glimpse(qc_v5)

## -------------------------------------------- ##
# Treatment Coalescing ----
## -------------------------------------------- ##

# Coalesce treatment info into a single column
qc_v6 <- qc_v5 %>% 
  dplyr::mutate(
    # Resolve *categorical* treatment information
    treatment_categorical = dplyr::case_when(
      ## BNZ should just use whatever the fire treatments are
      lter == "BNZ" ~ paste0("fire_", treatment_fire),
      ## GCE disturbance treatments
      treatment_disturbance == 1 ~ "disturbed",
      treatment_disturbance == 0 ~ "undisturbed",
      ## HFR logging treatments
      lter == "HFR" ~ paste0("logging_", treatment_logging),
      ## KNZ fire treatments
      lter == "KNZ" ~ paste0("fire_", treatment_fire),
      ## LUQ litter treatments
      treatment_litter == "Trim&clear" ~ "litter_removed",
      treatment_litter == "Trim+Debris" ~ "litter_added",
      ## MCR removal treatments
      treatment_remove == "Removal" ~ "coral_remove",
      treatment_remove == "Retention" ~ "coral_retain",
      # Any unspecified should just be 'none'
      T ~ NA),
    # Resolve taxa information
    taxa = dplyr::case_when(
      ## VCR oyster taxa
      taxon == "Spat Oyster" ~ "oyster_juvenile",
      taxon == "Box Adult Oyster" ~ "oyster_dead",
      # Any unspecified should just be 'none'
      T ~ NA))

# Check resulting treatments and taxa
sort(unique(qc_v6$treatment_categorical))
sort(unique(qc_v6$taxa))

# Look at original treatment columns where no treatment was identified
qc_v6 %>% 
  dplyr::filter(is.na(treatment_categorical) & is.na(treatment_continuous)) %>% 
  dplyr::select(source, dplyr::starts_with("treatment")) %>% 
  dplyr::distinct() %>% 
  dplyr::glimpse()
## VCR has no treatment because "taxa" is the critical column

# Structure check
dplyr::glimpse(qc_v6)

## -------------------------------------------- ##
# Reorder Columns ----
## -------------------------------------------- ##

# Let's reorder and pare down columns
qc_v7 <- qc_v6 %>% 
  # Macro grouping stuff before everything
  dplyr::relocate(source, lter, year, site, block, plot,
                  .before = dplyr::everything()) %>% 
  # Treatment & taxa next
  dplyr::relocate(dplyr::starts_with("treatment_"), taxa,
                  .after = year) %>% 
  # Responses after everything
  dplyr::relocate(dplyr::starts_with("response"), 
                  .after = dplyr::everything()) %>% 
  # Drop old treatment columns (incl. taxon column)
  dplyr::select(-treatment_fire, -treatment_disturbance, -treatment_litter, 
                -treatment_remove, -treatment_logging, -taxon)

# Any gained/lost columns?
supportR::diff_check(old = names(qc_v6), new = names(qc_v7))

# Structure check
dplyr::glimpse(qc_v7)

## -------------------------------------------- ##
# Aggregate Responses (As Needed) ----
## -------------------------------------------- ##

# Identify the response column names
(resp_colnames <- qc_v7 %>% 
  dplyr::select(dplyr::contains("response")) %>% 
  names())

# What non-numbers are in the response columns?
supportR::num_check(data = qc_v7, col = resp_colnames)

# Want to aggregate within certain grouping variables
qc_v8a <- qc_v7 %>% 
  # Fix any non-numbers in the response columns
  ## Currently unnecessary!
  # Make an observation ID column
  dplyr::mutate(id = 1:nrow(.)) 

# All fixed?
supportR::num_check(data = qc_v8a, col = resp_colnames)

# Split off any data that we don't want to aggregate and are not uniquely identified
qc_v8b <- dplyr::filter(qc_v8a, lter %in% c("SONGS"))
qc_v8c <- dplyr::filter(qc_v8a, lter %in% c("SONGS") != T)

# Now aggregate as needed
qc_v8d <- qc_v8c %>% 
  # Make sure response columns are all true numbers
  dplyr::mutate(dplyr::across(.cols = dplyr::starts_with("response"),
                              .fns = ~ as.numeric(.))) %>% 
  # Aggregate within all non-response columns
  dplyr::group_by(dplyr::across(dplyr::all_of(setdiff(x = names(.),
                                                      y = c(resp_colnames, "id"))))) %>% 
  dplyr::summarize(resp_og = unique(response),
                   resp_avg = mean(response_unavg, na.rm = T),
                   resp_sum = sum(response_unsum, na.rm = T),
                   obs = min(id, na.rm = T),
                   .groups = "keep") %>% 
  dplyr::ungroup() %>% 
  # Coalesce to a single 'true' response
  dplyr::mutate(response_actual = dplyr::case_when(
    !is.na(resp_og) ~ resp_og,
    !is.na(resp_avg) ~ resp_avg,
    T ~ resp_sum)) %>%
  # Rename actual response column & treatment column
  dplyr::rename(response = response_actual)
  
# Recombine SONGS with others
qc_v8e <- dplyr::bind_rows(qc_v8b, qc_v8d)

# Lack responses anywhere?
dplyr::filter(qc_v8b, is.na(response))

# If any, check the original dataframe responses out for that
dplyr::filter(qc_v8a, id %in% dplyr::filter(qc_v8e, is.na(response))$obs)
  
# Tidy up that object
qc_v9 <- qc_v8e %>% 
  # Drop all intermediary response columns & observation ID
  dplyr::select(-dplyr::starts_with("resp_"), -obs, -id)

# Check structure
dplyr::glimpse(qc_v9)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final data object
qc_v99 <- qc_v9

# Export this locally
write.csv(qc_v99, row.names = F, na = '',
          file = file.path("data", "tidy", "02_wrangled.csv"))

# End ----
