# Objective: Calculate tree density and basal area change (growth, mortality, and ingrowth)
## for each species and plot

library(magrittr)

# Clear environment & collect garbage
rm(list = ls()); gc()

# Grab the 'site summaries' file to know desired plots/stands/etc.
SiteSummaries <- read.csv(file.path("data", "from-drive", "OHJA_downed wood summary_v2.csv")) %>% 
  dplyr::mutate(stand_plot = paste(stand, plot))

# Check structure
dplyr::glimpse(SiteSummaries)

# Read in the four necessary data files
mort_v01 <- read.csv(file.path("data", "raw", "00_AND__Individual tree mortality.csv"))
tree_v01 <- read.csv(file.path("data", "raw", "00_AND__Individual tree remeasurement.csv")) 
init_v01 <- read.csv(file.path("data", "raw", "00_AND__Initial tree conditions with spatial coordinates.csv"))
meas_v01 <- read.csv(file.path("data", "from-drive", "TP00112_v13.csv"))

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
  dplyr::filter(STANDID %in% unique(SiteSummaries$stand)) %>% 
  dplyr::filter(STAND_PLOT %in% unique(SiteSummaries$stand_plot))
tree_v03 <- tree_v02 %>% 
  dplyr::filter(SPECIES == "PSME") %>% 
  dplyr::filter(STANDID %in% unique(SiteSummaries$stand)) %>% 
  dplyr::filter(STAND_PLOT %in% unique(SiteSummaries$stand_plot))
init_v03 <- init_v02 %>% 
  dplyr::filter(SPECIES == "PSME") %>% 
  dplyr::filter(STANDID %in% unique(SiteSummaries$stand)) %>% 
  dplyr::filter(STAND_PLOT %in% unique(SiteSummaries$stand_plot))
meas_v03 <- meas_v02 %>% 
  dplyr::filter(STANDID %in% unique(SiteSummaries$stand)) %>% 
  dplyr::filter(STAND_PLOT %in% unique(SiteSummaries$stand_plot))

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

# Get appropriate plots & years
(PlotIDs <- SiteSummaries$stand_plot)
(PlotYears <- SiteSummaries$year)

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
    cwd.year_vec <- PlotYears[PlotIDs == focal_plot]
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
    tree.stat_0 <- tree_0[tree_0$TREE_STATUS %in% c(1,2)]
    tree.stat_1 <- tree_1[tree_1$TREE_STATUS %in% c(1,2)]

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
and_live <- purrr::list_rbind(list.01_stand.plot)

# Check structure
dplyr::glimpse(and_live)

# Export locally (uncomment if desired)
# write.csv(and_live, row.names = FALSE, na = '', 
#   file.path("data", "01_AND-live-tree-data.csv"))
