## -------------------------------------------- ##
# Standardize Data - Andrews Forest (AND)
## -------------------------------------------- ##
# Purpose
## Get these data into a standard format with that of other sites

## !!! DATA SOURCE NOTE !!!
# One (of 5) input files from Google Drive (_not_ EDI)
## That file is downloaded from Google Drive by `_TEMPORARY_drive-download.r`
# Remaining input files are downloaded from EDI by `00_download-and.r`
## !!! SEE ABOVE !!!

# Load libraries
# install.packages("librarian")
librarian::shelf(tidyverse, janitor, supportR, magrittr)

# Get set up
source(file.path("-setup.r"))

# Clear environment/collect garbage
rm(list = ls()); gc()

## -------------------------------------------- ##
# Load Dead Wood Data ----
## -------------------------------------------- ##

# Load in relevant data
and_wood_v01 <- read.csv(file.path("data", "raw", "00_AND__TD01204.csv")) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(and_wood_v01)

## -------------------------------------------- ##
# Filter & Tidy Wood Data ----
## -------------------------------------------- ##

# Filter to only desired rows
and_wood_v02 <- and_wood_v01 %>% 
  dplyr::filter(studyid == "OHJA") %>% 
  # NL: '89 was absent from old ver of data so removing it here too
  dplyr::filter(year != 1989)

# Check structure
dplyr::glimpse(and_wood_v02)

# Tidy up plot & stand
and_wood_v03 <- and_wood_v02 %>% 
  dplyr::mutate(plot_og = gsub(pattern = " ", replacement = "", x = plot)) %>% 
  dplyr::mutate(plot_num = as.numeric(gsub("R", "", plot_og))) %>% 
  # DB: "[Need] to coallpase a few stands into a single stand/plot due to some oddities in our database structure"
  dplyr::mutate(plot = dplyr::case_when(
    # NL: Need to include "RS17" even though it wasn't in DB's list;
    ## Checked against old ver of data and that stand only has one plot,
    ## which means it has to be collapsed 
    stand %in% c(paste0("RS0", c(4:5, 7:8)), paste0("RS", c(10, 12, 14:18))) ~ 99,
    TRUE ~ plot_num))

# Check gained & lost stand/plot combinations
supportR::diff_check(old = unique(paste(and_wood_v03$stand, and_wood_v03$plot_num)),
  new = unique(paste(and_wood_v03$stand, and_wood_v03$plot)))

# Check structure
dplyr::glimpse(and_wood_v03)

## -------------------------------------------- ##
# Summarize Wood Data ----
## -------------------------------------------- ##

# Summarize dead wood metrics by plot
and_dead <- and_wood_v03 %>% 
  dplyr::mutate(plot = ifelse(plot == 99, yes = 1, no = plot)) %>% 
  dplyr::mutate(stand_plot = paste(stand, plot)) %>% 
  dplyr::group_by(stand_plot, stand, plot, year) %>% 
  dplyr::summarize(
    total_volume = sum(wvol, na.rm = TRUE),
    total_mass = sum(wmass, na.rm = TRUE),
    total_cover = sum(pcover, na.rm = TRUE),
    total_area = sum(surfarea, na.rm = TRUE),
    .groups = "drop")

# Check structure
dplyr::glimpse(and_dead)

## -------------------------------------------- ##
# Load Tree Data ----
## -------------------------------------------- ##

# Read in the four necessary data files
mort_v01 <- read.csv(file.path("data", "raw", "00_AND__Individual tree mortality.csv"))
tree_v01 <- read.csv(file.path("data", "raw", "00_AND__Individual tree remeasurement.csv")) 
init_v01 <- read.csv(file.path("data", "raw", "00_AND__Initial tree conditions with spatial coordinates.csv"))
meas_v01 <- read.csv(file.path("data", "from-drive", "TP00112_v13.csv"))

# Check structure
dplyr::glimpse(mort_v01)
dplyr::glimpse(tree_v01)
dplyr::glimpse(init_v01)
dplyr::glimpse(meas_v01)

## -------------------------------------------- ##
# Filter Tree Data to Desired Rows ----
## -------------------------------------------- ##

# Make necessary additional columns
mort_v02 <- mort_v01 %>% 
  dplyr::mutate(STAND_PLOT = paste(STANDID, PLOTNUMBER))
tree_v02 <- tree_v01 %>% 
  dplyr::mutate(STAND_PLOT = paste(STANDID, PLOTNUMBER))
init_v02 <- init_v01 %>% 
  dplyr::mutate(STAND_PLOT = paste(STANDID, PLOTNUMBER))
meas_v02 <- meas_v01 %>% 
  dplyr::mutate(STANDID = substr(PLOTID, start = 1, stop = 4),
    PLOTNUMBER = as.integer(substr(PLOTID, start = 5, stop = 8)),
    STAND_PLOT = paste(STANDID, PLOTNUMBER))

# Filter these as needed
mort_v03 <- mort_v02 %>% 
  dplyr::filter(SPECIES == "PSME") %>% 
  dplyr::filter(STANDID %in% unique(and_dead$stand)) %>% 
  dplyr::filter(STAND_PLOT %in% unique(and_dead$stand_plot))
tree_v03 <- tree_v02 %>% 
  dplyr::filter(SPECIES == "PSME") %>% 
  dplyr::filter(STANDID %in% unique(and_dead$stand)) %>% 
  dplyr::filter(STAND_PLOT %in% unique(and_dead$stand_plot))
init_v03 <- init_v02 %>% 
  dplyr::filter(SPECIES == "PSME") %>% 
  dplyr::filter(STANDID %in% unique(and_dead$stand)) %>% 
  dplyr::filter(STAND_PLOT %in% unique(and_dead$stand_plot))
meas_v03 <- meas_v02 %>% 
  dplyr::filter(STANDID %in% unique(and_dead$stand)) %>% 
  dplyr::filter(STAND_PLOT %in% unique(and_dead$stand_plot))

# Make computation-ready versions of each
mort_data <- mort_v03
tree_data <- tree_v03
init_data <- init_v03
meas_data <- meas_v03

# Check structure
dplyr::glimpse(mort_data)
dplyr::glimpse(tree_data)
dplyr::glimpse(init_data)
dplyr::glimpse(meas_data)

# Print total number of stands and trees
message("Number of trees = ", length(unique(tree_data$TREEID)))

# Get stand/plot combos & years from dead wood data
(stand.plots_dead <- and_dead$stand_plot)
(years_dead <- and_dead$year)

## -------------------------------------------- ##
# Calculate Per-Plot Growth/Mortality ----
## -------------------------------------------- ##
# Goal: for each plot, get the growth and mortality over a ~20 year window following dead wood

# Create list for storing outputs
list.01_stand.plot <- list()

# Iterate across stands in tree data
for(focal_stand in sort(unique(tree_data$STANDID))){
  # focal_stand <- "RS24"

  # Progress message
  message("Working on stand '", focal_stand, "'")

  # Subset the four key datasets to just this stand
  mort_stand <- dplyr::filter(mort_data, STANDID == focal_stand)
  tree_stand <- dplyr::filter(tree_data, STANDID == focal_stand)
  init_stand <- dplyr::filter(init_data, STANDID == focal_stand)
  meas_stand <- dplyr::filter(meas_data, STANDID == focal_stand)

  # Identify plots within this stand
  relevant_standplots <- unique(tree_stand$STAND_PLOT)

  # Make a list for storing stand/plot combination outputs
  list.02_plot <- list()

  # Iterate across stand/plot combinations
  for(focal_plot in relevant_standplots){
    # focal_plot <- "RS24 2"

    # Progress message
    message("Working on plot '", focal_plot, "'")

    # Subset the four key datasets to just this stand/plot combo
    mort_plot <- dplyr::filter(mort_stand, STAND_PLOT == focal_plot)
    tree_plot <- dplyr::filter(tree_stand, STAND_PLOT == focal_plot)
    init_plot <- dplyr::filter(init_stand, STAND_PLOT == focal_plot)
    meas_plot <- dplyr::filter(meas_stand, STAND_PLOT == focal_plot)

    # Generate a plot with years and types of measurement
    year_df <- meas_plot %>% 
      dplyr::mutate(establishment = ACTIVITY %in% c("A","E"),
        remeasurement = ACTIVITY == "R",
        mortality = ACTIVITY %in% c("R", "M"),
        .after = YEAR_RAW) %>% 
      dplyr::select(year = YEAR_RAW, aggYear = YEAR_AGG,
        establishment, remeasurement, mortality) %>% 
      dplyr::distinct() %>% 
      dplyr::arrange(year)

    # Check structure
    ## dplyr::glimpse(year_df)

    # Identify years without measurements
    treeYearMissing <- dplyr::filter(tree_plot, !YEAR %in% year_df$year)$YEAR
          
    # If any, add rows to the year output
    if(length(treeYearMissing) > 0) 
      year_df %<>% dplyr::bind_rows(year_df ,data.frame("year" = treeYearMissing,
            "establishment" = FALSE,
            "remeasurement" = TRUE,
            "mortality" = TRUE,
            "aggYear" = treeYearMissing))

    # Get vectors of some key metrics
    cwd.year_vec <- years_dead[stand.plots_dead == focal_plot]
    agg.year_vec <- sort(unique(year_df$aggYear))
    
    # Assemble the beginnings of an output dataframe
    out_v01 <- data.frame(
      "Species" = "PSME",
      "Stand" = focal_stand,
      "Plot" = unique(tree_plot$PLOTNUMBER),
      "CWDYear" = cwd.year_vec, 
      "treeYear1" = min(agg.year_vec[agg.year_vec >= (cwd.year_vec - 10)]),
      "area_ha" = (meas_plot$PLOT_AREA_M2_CORR / 10^4), 
      "minDBH_cm" = meas_plot$DBH_MINIMUM)

    # Check structure
    ## dplyr::glimpse(out_v01)
    
    # Identify the years that match tree year 1
    start.year_vec <- year_df$year[which(year_df$aggYear == out_v01$treeYear1)]

    # Compute more metrics with that
    out_v02 <- out_v01 %>% 
      dplyr::mutate(
        treeYear2 = min(agg.year_vec[agg.year_vec >= (unique(treeYear1 + 20))]),
        dYear = treeYear2 - treeYear1,
        .after = treeYear1)

    # Check structure
    ## dplyr::glimpse(out_v02)

    # Get the '0th' and time + 1 tree data
    tree_0 <- dplyr::filter(tree_plot, YEAR == unique(out_v02$treeYear1))
    tree_1 <- dplyr::filter(tree_plot, YEAR == unique(out_v02$treeYear2))

    # If there are no measurements for either, move on from this stand/plot combination entirely
    if(nrow(tree_0) == 0 | nrow(tree_1) == 0) next

    # Otherwise, grab all trees with status 1 or 2
    tree.stat_0 <- tree_0[tree_0$TREE_STATUS %in% c(1,2), ]
    tree.stat_1 <- tree_1[tree_1$TREE_STATUS %in% c(1,2), ]

    # Figure out which tags were present at time 0 or 1
    keep0 <- which(tree.stat_0$TAG %in% tree.stat_1$TAG)
    keep1 <- match(tree.stat_0$TAG[keep0], tree.stat_1$TAG)

    # And use the above to do some final calculations
    out_v03 <- out_v02 %>% 
      dplyr::mutate(
        tph0_spp = length(tree.stat_0$DBH) / area_ha,
        tph1_spp = length(tree.stat_1$DBH) / area_ha,
        ba0_spp = ((sum(pi * (tree.stat_0$DBH / 2)) / 10^4) / area_ha),
        ba1_spp = ((sum(pi * (tree.stat_1$DBH / 2)) / 10^4) / area_ha),
        keep0_ba = ifelse(length(keep1) == 0, yes = NA,
          no = ((sum(pi * (tree.stat_0$DBH[keep0] / 2)^2) / 10^4) / area_ha)),
        keep1_ba = ifelse(length(keep1) == 0, yes = NA,
          no = ((sum(pi * (tree.stat_1$DBH[keep1] / 2)^2) / 10^4) / area_ha)),
        growth_ba_spp = (keep1_ba - keep0_ba),
        surv_prop_spp = length(keep0) / nrow(tree.stat_0),
        .after = dYear) %>% 
      dplyr::select(-keep0_ba, -keep1_ba)
    
    # Check structure
    ## dplyr::glimpse(out_v03)

    # Add that output to the plot list
    list.02_plot[[focal_plot]] <- out_v03
    
  } # Close plot loop

  # Unlist plots within the stand and add that output to the stand/plot list
  list.01_stand.plot[[focal_stand]] <- purrr::list_rbind(list.02_plot) 

} # Close stand loop

# Unlist _that_ to generate the final 'all stands, all plots' output
and_live <- purrr::list_rbind(list.01_stand.plot) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(and_live)

## -------------------------------------------- ##
# Combine Tree & Dead Wood Data ----
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
    tree_growth_ind = (growth_ba_spp / (tph0_spp * surv_prop_spp) / d_year))

# Check structure
dplyr::glimpse(and_v02)

# Pare down to only needed columns
and_v03 <- and_v02 %>% 
  dplyr::select(stand, plot, year, ba0_spp, ba1_spp, dw_mass_ha:tree_growth_ind)

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
    dead.wood.mass.kg.ha = dw.mass.ha) %>% ## Dead wood mass (kg/ha)
  dplyr::distinct()

# One last structure check
dplyr::glimpse(and_v99)

# Export locally
write.csv(and_v99, row.names = FALSE, na = '',
  file = file.path("data", "standard", "01_AND_live-dead-wood.csv"))

# End ----
