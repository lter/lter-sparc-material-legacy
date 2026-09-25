## -------------------------------------------- ##
# Create Data Paper Table
## -------------------------------------------- ##
# Purpose
## Calculate Z scores and make a cross-site table
## Works for all sites (but depends on outputs of respective `01` scripts)

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

# Make a list for outputs
z_list <- list()

## -------------------------------------------- ##
# Analyze Andrews Forest (AND) ----
## -------------------------------------------- ##

# Load data
and_df <- read.csv(file.path("data", "standard", "01_AND_live-dead-wood.csv"))

# Check structure
dplyr::glimpse(and_df)

# Scale response/explanatory to Z scores
and_z <- and_df %>% 
  dplyr::mutate(
    tree.growth.m2.indiv.yr_z = scale(and_df$tree.growth.m2.indiv.yr)[, 1],
    dead.wood.mass.kg.ha_z = scale(and_df$dead.wood.mass.kg.ha)[, 1] ) %>% 
  dplyr::select(site = stand, dplyr::ends_with("_z")) %>% 
  dplyr::group_by(site) %>% 
  dplyr::summarize(
    material.legacy.predictor = mean(dead.wood.mass.kg.ha_z, na.rm = TRUE),
    foundation.sp.response = mean(tree.growth.m2.indiv.yr_z, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::rename(plot = site)

# Check structure
dplyr::glimpse(and_z)

# Add to list
z_list[["AND"]] <- and_z

## -------------------------------------------- ##
# Analyze Bonanza Creek (BNZ) ----
## -------------------------------------------- ##

# Load data
bnz_df <- read.csv(file.path("data", "standard", "01_BNZ_forest-fire.csv"))

# Check structure
dplyr::glimpse(bnz_df)

# Scale response/explanatory to Z scores
bnz_z <- bnz_df %>% 
  dplyr::mutate(
    mean.seeds.m2_z = scale(bnz_df$mean.seeds.m2)[, 1],
    black.spruce.basal.area.cm2.m2_z = scale(bnz_df$black.spruce.basal.area.cm2.m2)[, 1] ) %>% 
  dplyr::group_by(burn, site) %>% 
  dplyr::summarize(
    material.legacy.predictor = mean(black.spruce.basal.area.cm2.m2_z, na.rm = TRUE),
    foundation.sp.response = mean(mean.seeds.m2_z, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::mutate(plot = paste0(burn, "-", site)) %>% 
  dplyr::select(-burn, -site)

# Check structure
dplyr::glimpse(bnz_z)
    
# Fit GLMM and add to list
z_list[["BNZ"]] <- bnz_z

## -------------------------------------------- ##
# Analyze Florida Coastal Everglades (FCE) ----
## -------------------------------------------- ##

# Load data
fce_df <- read.csv(file.path("data", "standard", "01_FCE_root-litter.csv"))

# Check structure
dplyr::glimpse(fce_df)

# Scale response/explanatory to Z scores
fce_z <- fce_df %>% 
  dplyr::mutate(
    mean.root.production.g.m2.yr_z = scale(fce_df$mean.root.production.g.m2.yr)[, 1],
    mean.litter.g_z = scale(fce_df$mean.litter.g)[, 1] ) %>% 
    dplyr::group_by(site) %>% 
    dplyr::summarize(
      material.legacy.predictor = mean(mean.litter.g_z, na.rm = TRUE),
      foundation.sp.response = mean(mean.root.production.g.m2.yr_z, na.rm = TRUE),
      .groups = "drop") %>% 
  dplyr::rename(plot = site)

# Check structure
dplyr::glimpse(fce_z)

# Add to list
z_list[["FCE"]] <- fce_z

## -------------------------------------------- ##
# Analyze Georgia Coastal Ecosystems (GCE) ----
## -------------------------------------------- ##

# Load data
gce_df <- read.csv(file.path("data", "standard", "01_GCE_marsh-biomass.csv"))

# Check structure
dplyr::glimpse(gce_df)

# Scale response/explanatory to Z scores
gce_z <- gce_df %>% 
  dplyr::mutate(mean.plant.biomass.g.m2_z = scale(gce_df$mean.plant.biomass.g.m2)[, 1] ) %>% 
  dplyr::group_by(disturbance, site, year) %>% 
  dplyr::summarize(
    foundation.sp.response = mean(mean.plant.biomass.g.m2_z, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::rename(material.legacy.predictor = disturbance,
    plot = site)

# Check structure
dplyr::glimpse(gce_z)

# Add to list
z_list[["GCE"]] <- gce_z

## -------------------------------------------- ##
# Analyze Harvard Forest (HFR) ----
## -------------------------------------------- ##

# Load data
hfr_df <- read.csv(file.path("data", "standard", "01_HFR_hemlock-removal.csv"))

# Check structure
dplyr::glimpse(hfr_df)

# Scale response/explanatory to Z scores
hfr_z <- hfr_df %>% 
  dplyr::mutate(hemlock.density.ha_z = scale(hfr_df$hemlock.density.ha)[, 1] ) %>% 
  dplyr::group_by(block, plot, treatment, year) %>% 
  dplyr::summarize(
    foundation.sp.response = mean(hemlock.density.ha_z, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::rename(material.legacy.predictor = treatment,
    tmp = plot) %>% 
  dplyr::mutate(plot = paste0(block, "-", tmp)) %>% 
  dplyr::select(-block, -tmp)

# Check structure
dplyr::glimpse(hfr_z)

# Add to list
z_list[["HFR"]] <- hfr_z

## -------------------------------------------- ##
# Analyze Konza Prairie (KNZ) ----
## -------------------------------------------- ##

# Load data
knz_df <- read.csv(file.path("data", "standard", "01_KNZ_grass.csv"))

# Check structure
dplyr::glimpse(knz_df)

# Scale response/explanatory to Z scores
knz_z <- knz_df %>% 
  dplyr::mutate(mean.live.grass.g.dm2_z = scale(knz_df$mean.live.grass.g.dm2)[, 1] ) %>% 
  dplyr::group_by(burn, year, transect) %>% 
  dplyr::summarize(
    foundation.sp.response = mean(mean.live.grass.g.dm2_z, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::rename(material.legacy.predictor = burn,
    plot = transect)

# Check structure
dplyr::glimpse(knz_z)

# Add to list
z_list[["KNZ"]] <- knz_z

## -------------------------------------------- ##
# Analyze Luquillo (LUQ) ----
## -------------------------------------------- ##

# Load data
luq_df <- read.csv(file.path("data", "standard", "01_LUQ_seedlings.csv"))

# Check structure
dplyr::glimpse(luq_df)

# Scale response/explanatory to Z scores
luq_z <- luq_df %>% 
  dplyr::mutate(seedling.count_z = scale(luq_df$seedling.count)[, 1] ) %>% 
  dplyr::group_by(block, plot, year, treatment) %>% 
  dplyr::summarize(
    foundation.sp.response = mean(seedling.count_z, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::rename(material.legacy.predictor = treatment,
    tmp = plot) %>% 
  dplyr::mutate(plot = paste0(block, "-", tmp)) %>% 
  dplyr::select(-block, -tmp)

# Check structure
dplyr::glimpse(luq_z)

# Fit GLMM and add to list
z_list[["LUQ"]] <- luq_z

## -------------------------------------------- ##
# Analyze Moorea Coral Reef (MCR) ----
## -------------------------------------------- ##

# Load data
mcr_df <- read.csv(file.path("data", "standard", "01_MCR_corals.csv"))

# Check structure
dplyr::glimpse(mcr_df)

# Scale response/explanatory to Z scores
mcr_z <- mcr_df %>% 
  dplyr::mutate(
    coral.live.percent.change_z = scale(mcr_df$coral.live.percent.change)[, 1],
    coral.dead.m2.start_z = scale(mcr_df$coral.dead.m2.start)[, 1] ) %>% 
  dplyr::group_by(plot, year, treatment) %>% 
  dplyr::summarize(
    foundation.sp.response = mean(coral.live.percent.change_z, na.rm = TRUE),
    material.legacy.predictor = mean(coral.dead.m2.start_z, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::rename(tmp = plot) %>% 
  dplyr::mutate(plot = paste0(treatment, "-", tmp)) %>% 
  dplyr::select(-treatment, -tmp)

# Check structure
dplyr::glimpse(mcr_z)

# Fit GLMM and add to list
z_list[["MCR"]] <- mcr_z

## -------------------------------------------- ##
# Analyze SONGS ----
## -------------------------------------------- ##
# San Onofre Nuclear Generating Station (SONGS)

# Load data
songs_df <- read.csv(file.path("data", "standard", "01_SONGS_kelp-holdfasts.csv"))

# Check structure
dplyr::glimpse(songs_df)

# Scale response/explanatory to Z scores
songs_z <- songs_df %>% 
  dplyr::mutate(
    kelp.recruit.density.m2_z = scale(songs_df$kelp.recruit.density.m2)[, 1],
    kelp.holdfast.dead.percent.cover_z = scale(songs_df$kelp.holdfast.dead.percent.cover)[, 1] ) %>% 
  dplyr::group_by(reef, transect, year) %>% 
  dplyr::summarize(
    foundation.sp.response = mean(kelp.recruit.density.m2_z, na.rm = TRUE),
    material.legacy.predictor = mean(kelp.holdfast.dead.percent.cover_z, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::mutate(plot = paste0(reef, "-", transect)) %>% 
  dplyr::select(-reef, -transect)

# Check structure
dplyr::glimpse(songs_z)

# Fit GLMM and add to list
z_list[["SONGS"]] <- songs_z

## -------------------------------------------- ##
# Analyze Virginia Coastal Reserve (VCR) ----
## -------------------------------------------- ##

# Load data
vcr_df <- read.csv(file.path("data", "standard", "01_VCR_oysters.csv"))

# Check structure
dplyr::glimpse(vcr_df)

# Scale response/explanatory to Z scores
vcr_z <- vcr_df %>% 
  dplyr::mutate(
    mean.juvenile.oyster.count.quarter.m2_z = scale(vcr_df$mean.juvenile.oyster.count.quarter.m2)[, 1],
    mean.dead.oyster.count.quarter.m2_z = scale(vcr_df$mean.dead.oyster.count.quarter.m2)[, 1] ) %>% 
  dplyr::group_by(site, year) %>% 
  dplyr::summarize(
    foundation.sp.response = mean(mean.juvenile.oyster.count.quarter.m2_z, na.rm = TRUE),
    material.legacy.predictor = mean(mean.dead.oyster.count.quarter.m2_z, na.rm = TRUE),
    .groups = "drop") %>% 
  dplyr::rename(plot = site)

# Check structure
dplyr::glimpse(vcr_z)

# Fit GLMM and add to list
z_list[["VCR"]] <- vcr_z

## -------------------------------------------- ##
# Process Table ----
## -------------------------------------------- ##

# Calculate effect sizes and get a tidy table
tab_v01 <- z_list %>% 
  purrr::map(.f = ~ dplyr::mutate(.data = .x, 
    dplyr::across(.cols = dplyr::everything(), .fns = as.character))) %>% 
  purrr::imap(.f = ~ dplyr::mutate(.data = .x, site = .y,
    .before = dplyr::everything())) %>% 
  purrr::list_rbind() %>% 
  dplyr::relocate(year, .before = plot) %>% 
  dplyr::rename_with(.fn = ~ paste0(., "_z.score"),
    .cols = -site:-plot)
  
# Check structure
dplyr::glimpse(tab_v01)

# Summarize across years (to make a simpler table in case that's desired)
mean_z_list <- list()
for(site in unique(names(z_list))){
  # site <- "AND"

  # Grab that site
  focal_df <- z_list[[site]]

  # If material legacy predictor is numeric, average it across years
  if(all(!is.na(suppressWarnings(as.numeric(focal_df$material.legacy.predictor))))){

    # Summarize!
    focal_done <- focal_df %>% 
      dplyr::group_by(dplyr::across(dplyr::all_of(setdiff(x = names(focal_df), 
        y = c("year", "material.legacy.predictor", "foundation.sp.response"))))) %>% 
      dplyr::summarize(
        material.legacy.predictor_z.score = mean(material.legacy.predictor, na.rm = TRUE),
        foundation.sp.response_z.score = mean(foundation.sp.response, na.rm = TRUE),
        .groups = "drop")

  # If material legacy _is not_ numeric, grab a unique value across years
  } else {
    focal_done <- focal_df %>% 
      dplyr::group_by(dplyr::across(dplyr::all_of(setdiff(x = names(focal_df), 
        y = c("year", "foundation.sp.response"))))) %>% 
      dplyr::summarize(
        foundation.sp.response_z.score = mean(foundation.sp.response, na.rm = TRUE),
        .groups = "drop") %>% 
      dplyr::rename(material.legacy.predictor_z.score = material.legacy.predictor)
  }

  # Add output to list
  mean_z_list[[site]] <- focal_done }

tab_v02 <- mean_z_list %>% 
  purrr::map(.f = ~ dplyr::mutate(.data = .x, 
    dplyr::across(.cols = dplyr::everything(), .fns = as.character))) %>% 
  purrr::imap(.f = ~ dplyr::mutate(.data = .x, site = .y,
    .before = dplyr::everything())) %>% 
  purrr::list_rbind()

# Check structure
dplyr::glimpse(tab_v02)

## -------------------------------------------- ##
# Export ----
## -------------------------------------------- ##

# Make a final object
tab_v99 <- tab_v01

# Check structure
dplyr::glimpse(tab_v99)

# Export locally
write.csv(tab_v99, row.names = FALSE, na = '',
  file = file.path("data", "02_z-score-table.csv"))

# End ----
