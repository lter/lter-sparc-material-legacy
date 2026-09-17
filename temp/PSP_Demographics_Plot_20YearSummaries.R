# Objective: Calculate tree density and basal area change (growth, mortality, and ingrowth)
## for each species and plot. Only TV010

#clear workspace

rm(list = ls()); gc()

# TV010 data locations
## file.path() combines text strings into a file path (useful modification of paste)

#On EDI: https://portal.edirepository.org/nis/mapbrowse?packageid=knb-lter-and.2742.28
#Note that the version number might be slightly different
mort_data = read.csv(file.path("data", "raw", "00_AND__Individual tree mortality.csv")) %>% 
  dplyr::filter(SPECIES == "PSME")
dplyr::glimpse(mort_data)

tree_data = read.csv(file.path("data", "raw", "00_AND__Individual tree remeasurement.csv")) %>% 
    dplyr::filter(SPECIES == "PSME")
dplyr::glimpse(tree_data)

init_data = read.csv(file.path("data", "raw", "00_AND__Initial tree conditions with spatial coordinates.csv")) %>% 
  dplyr::filter(SPECIES == "PSME")
dplyr::glimpse(init_data)

#On HJA website: https://andrewsforest.oregonstate.edu/data/datacatalog/TP001
#Note that the version number might be slightly different
meas_data = read.csv(file.path("data", "from-drive", "TP00112_v13.csv"))
dplyr::glimpse(meas_data)

#based on Kai's code and https://portal.edirepository.org/nis/mapbrowse?packageid=knb-lter-and.4032.10
SiteSummaries <- read.csv(file.path("data", "from-drive", "OHJA_downed wood summary_v2.csv"))
str(SiteSummaries)

#Break up plot ID into stand and plot for meas_data
meas_data <- meas_data %>% 
  dplyr::mutate(StandID = substr(meas_data$PLOTID,1,4),
    Plot = as.integer(substr(meas_data$PLOTID,5,8)))
str(meas_data)

# #Print total number of stands and trees
message(paste0("Number of trees = ", length(unique(tree_data$TREEID))))

# # Set appropriate stand IDs to use based on down wood
StandIDs <- sort(unique(SiteSummaries$stand))

if(!is.null(StandIDs)){
  mort_data = mort_data[mort_data$STANDID %in% StandIDs,]
  tree_data = tree_data[tree_data$STANDID %in% StandIDs,]
  init_data = init_data[init_data$STANDID %in% StandIDs,]
  meas_data = meas_data[meas_data$StandID %in% tree_data$STANDID,]
}

#Print total number of trees after censoring
message(paste0("Number of trees after censoring = ", length(unique(tree_data$TREEID))))

# Get appropriate plots
PlotIDs <- paste(SiteSummaries$stand, SiteSummaries$plot)
PlotYears <- SiteSummaries$year

if(!is.null(PlotIDs)){
  mort_data = mort_data[paste(mort_data$STANDID,mort_data$PLOTNUMBER) %in% PlotIDs,]
  tree_data = tree_data[paste(tree_data$STANDID,tree_data$PLOTNUMBER) %in% PlotIDs,]
  init_data = init_data[paste(init_data$STANDID,init_data$PLOTNUMBER) %in% PlotIDs,]
  meas_data = meas_data[paste(meas_data$StandID,meas_data$Plot) %in% PlotIDs,]
}


#ensure that species in init_data euqls species in tree_data
unique(tree_data$SPECIES)
init_data$SPECIES <- ifelse(init_data$TREEID %in% tree_data$TREEID,
  yes = "PSME", no = init_data$SPECIES)

#Print total number of trees after censoring
message("Number of trees after censoring = ", length(unique(tree_data$TREEID)))

#Generate for each plot the growth and mortality over a ~20 year window following dead wood


# create vector of stands with at least 100 trees of the focal species 
(StandUniq <- sort(unique(tree_data$STANDID)))
(StandPlotUniq <- sort(unique(paste(tree_data$STANDID,tree_data$PLOTNUMBER))))

#create list to hold output
out_st_pl <- list()

for(st in seq_along(StandUniq)){
  # st <- 1
  
  #subselect data to focal stand within the focal species
  mort_std = mort_data[mort_data$STANDID == StandUniq[st],]
  tree_std = tree_data[tree_data$STANDID == StandUniq[st],]
  init_std = init_data[init_data$STANDID == StandUniq[st],]
  meas_std = meas_data[meas_data$StandID == StandUniq[st],]
  
  (SP_tmp <- unique(paste(tree_std$STANDID,tree_std$PLOTNUMBER)))
  
  out_pl <- list()
  
  for(pl in seq_along(SP_tmp)){
    # pl <- 1
    
    CWD_year <- PlotYears[PlotIDs == SP_tmp[pl]]
    
    mort_pl <- mort_std[mort_std$PLOTNUMBER == unlist(strsplit(SP_tmp[pl]," "))[2],]
    tree_pl <- tree_std[tree_std$PLOTNUMBER == unlist(strsplit(SP_tmp[pl]," "))[2],]
    init_pl <- init_std[init_std$PLOTNUMBER == unlist(strsplit(SP_tmp[pl]," "))[2],]
    meas_pl <- meas_std[meas_std$Plot == unlist(strsplit(SP_tmp[pl]," "))[2],]
    
    # Create df with measurement years & type of measurement
    YearUniq <- data.frame("year" = meas_pl$YEAR_RAW,
        "establishment" = FALSE, 
        "remeasurement" = FALSE,
        "mortality" = FALSE,
        "aggYear" = meas_pl$YEAR_AGG) %>% 
      dplyr::distinct() %>% 
      dplyr::arrange(year)
    
    # Re-set establishment if any plots in stand established or plot addition that year
    YearUniq$establishment[YearUniq$year %in% meas_pl$YEAR_RAW[meas_pl$ACTIVITY %in% c("A","E")]] = TRUE
    #sets remeasuremement to TRUE if any plots in stand remeasured that year
    YearUniq$remeasurement[YearUniq$year %in% meas_pl$YEAR_RAW[meas_pl$ACTIVITY == "R"]] = TRUE
    #sets mortality to TRUE if any plots in stand remeasured or checked for mortality that year
    YearUniq$mortality[YearUniq$year %in% meas_pl$YEAR_RAW[meas_pl$ACTIVITY == "R"]] = TRUE
    YearUniq$mortality[YearUniq$year %in% meas_pl$YEAR_RAW[meas_pl$ACTIVITY == "M"]] = TRUE
    
    # Identify years without measurements
    treeYearMissing <- dplyr::filter(tree_pl, !YEAR %in% YearUniq$year) %>% 
      dplyr::pull(YEAR)
          
    if(length(treeYearMissing) > 0) 
      YearUniq <- dplyr::bind_rows(YearUniq,
        data.frame("year" = treeYearMissing,
          "establishment" = FALSE,
          "remeasurement" = TRUE,
          "mortality" = TRUE,
          "aggYear" = treeYearMissing))
    
    # Identify years missing mortality info
    mortYearMissing <- mort_pl %>% 
      dplyr::filter(!YEAR %in% YearUniq$year) %>% 
      dplyr::pull(YEAR) %>%
      unique()
    
    # Get agg years
    aggYear <- sort(unique(YearUniq$aggYear))
    
    # Make a dataframe for summaries
    out_df <- data.frame(
      "Species" = "PSME",
      "Stand" = unlist(strsplit(SP_tmp[pl]," "))[1],
      "Plot" = unlist(strsplit(SP_tmp[pl]," "))[2],
      "CWDYear" = CWD_year, 
      "treeYear1" = min(aggYear[aggYear >= (CWD_year - 10)]),
      "area_ha" = (meas_pl$PLOT_AREA_M2_CORR / 10^4), 
      "minDBH_cm" = meas_pl$DBH_MINIMUM)

    # Get the years that match tree year 1
    yearList <- YearUniq$year[which(YearUniq$aggYear == out_df$treeYear1)]
    
    # Do extra calculations for output df
    out_df <- out_df %>% 
      dplyr::mutate(
        treeYear2 = min(aggYear[aggYear >= (unique(treeYear1 + 20))]),
        dYear = treeYear2 - treeYear1,
        .after = treeYear1 )
    
    # Check structure
    # dplyr::glimpse(out_df)
      
    # Get initial tree measurement
    treeList_all_0 <- dplyr::filter(tree_pl, YEAR == unique(out_df$treeYear1))
    
    # If there are no measurements for that time step, skip subsequent computation
    if(nrow(treeList_all_0) == 0) next
    
    # Otherwise, grab the DBH of all trees with status 1 or 2
    tree_stat_0 <- treeList_all_0$DBH[treeList_all_0$TREE_STATUS %in% c(1,2)]

    # Use that to calculate some key metrics
    out_df <- out_df %>% 
      dplyr::mutate(
        tph0_spp = length(tree_stat_0) / area_ha,
        ba0_spp = ((sum(pi * (tree_stat_0 / 2)) / 10^4) / area_ha),
        .after = dYear)
    
    # And ditch that tree stat object
    rm(list = "tree_stat_0")
    
    # Check structure
    # dplyr::glimpse(out_df)

    # Get tree meaasurement at time 2
    treeList_all_1 <- dplyr::filter(tree_pl, YEAR == unique(out_df$treeYear2))
    
    # If there are no measurements for that time step, skip subsequent computation
    if(nrow(treeList_all_1) == 0) next

    # Otherwise, grab the DBH of all trees with status 1 or 2
    tree_stat_1 <- treeList_all_1$DBH[treeList_all_1$TREE_STATUS %in% c(1,2)]

    # Use that to calculate some key metrics
    out_df <- out_df %>% 
      dplyr::mutate(
        tph1_spp = length(tree_stat_1) / area_ha,
        ba1_spp = ((sum(pi * (tree_stat_1 / 2)) / 10^4) / area_ha),
        .after = ba0_spp)
    
    # And ditch that tree stat object
    rm(list = "tree_stat_1")
    
    # Check structure
    # dplyr::glimpse(out_df)
    
    #get growth of trees alive at time 1 and time 2
    tmp0 <- treeList_all_0[treeList_all_0$TREE_STATUS %in% c(1,2),]
    tmp1 <- treeList_all_1[treeList_all_1$TREE_STATUS %in% c(1,2),]
    
    keep0 <- which(tmp0$TAG %in% tmp1$TAG)
    keep1 <- match(tmp0$TAG[keep0], tmp1$TAG)
    
    # If any trees survived to the next time step, compute growth
    if(length(keep1) > 0){
      out_df <- out_df %>% 
        dplyr::mutate(
          keep0_ba = ((sum(pi * (tmp0$DBH[keep0] / 2)^2) / 10^4) / area_ha),
          keep1_ba = ((sum(pi*(tmp1$DBH[keep1] / 2)^2) / 10^4) / area_ha),
          growth_ba_spp = (keep1_ba - keep0_ba),
          .after = ba1_spp)
    }

    # Calculate surival proportions
    out_df <- out_df %>% 
      dplyr::mutate(
        surv_prop_spp = length(keep0) / nrow(tmp0),
        .after = growth_ba_spp)

    # Check structure
    # dplyr::glimpse(out_df)

    # Add to plot list & end loop
    out_pl[[pl]] <- out_df }
  
  # Unlist plots, add to stand list, and end loop
  out_st_pl[[st]] <- purrr::list_rbind(out_pl) }

# Make a final output
final_df <- purrr::list_rbind(out_st_pl)

# Check structure
str(final_df)

##save
write.csv(final_df, file.path("data", "AND_test-out.csv"), 
  row.names = FALSE)


