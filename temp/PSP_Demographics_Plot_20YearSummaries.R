# Objective: Calculate tree density and basal area change (growth, mortality, and ingrowth)
## for each species and plot. Only TV010

#clear workspace

rm(list = ls()); gc()

# TV010 data locations
## file.path() combines text strings into a file path (useful modification of paste)

#On EDI: https://portal.edirepository.org/nis/mapbrowse?packageid=knb-lter-and.2742.28
#Note that the version number might be slightly different
mort_data = read.csv(file.path("data", "raw", "00_AND__Individual tree mortality.csv"))
str(mort_data)

tree_data = read.csv(file.path("data", "raw", "00_AND__Individual tree remeasurement.csv"))
str(tree_data)

init_data = read.csv(file.path("data", "raw", "00_AND__Initial tree conditions with spatial coordinates.csv"))
str(init_data)

#On HJA website: https://andrewsforest.oregonstate.edu/data/datacatalog/TP001
#Note that the version number might be slightly different
meas_data = read.csv(file.path("data", "from-drive", "TP00112_v13.csv"))
str(meas_data)

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

# Set appropriate stand IDs to use based on down wood
StandIDs <- unique(SiteSummaries$stand)

if(!is.null(StandIDs)){
  mort_data = mort_data[mort_data$STANDID %in% StandIDs,]
  tree_data = tree_data[tree_data$STANDID %in% StandIDs,]
  init_data = init_data[init_data$STANDID %in% StandIDs,]
  meas_data = meas_data[meas_data$StandID %in% tree_data$STANDID,]
}

#Print total number of trees after censoring
message(paste0("Number of trees after censoring = ", length(unique(tree_data$TREEID))))

# Get appropriate plots
PlotIDs <- paste(SiteSummaries$stand,SiteSummaries$plot)
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
(SpeciesUniq <- sort(unique(init_data$SPECIES)))

out_sp_st_pl <- list()

#iterate over ss = {1, ..., number of species}
for(sp in seq_along(SpeciesUniq)){
  # sp <- 1
  
  message("Processing ", SpeciesUniq[sp])

  #subselect data to focal species [TEMPORARY VARAIABLE]
  tree_spp <- dplyr::filter(tree_data, SPECIES == SpeciesUniq[sp])
  
  # create vector of stands with at least 100 trees of the focal species 
  (StandUniq <- sort(unique(tree_spp$STANDID)))
  (StandPlotUniq <- sort(unique(paste(tree_spp$STANDID,tree_spp$PLOTNUMBER))))
  
  rm(list = "tree_spp")
  
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
      
      # create data.frame with years of measurement (year) and whether that measurement is a full measurement (Type) 
      YearUniq <- data.frame(year = sort(unique(meas_pl$YEAR_RAW)),
                            establishment = FALSE, 
                            remeasurement = FALSE,
                            mortality = FALSE,
                            aggYear = NA)
      #sets establishment to TRUE if any plots in stand established or plot addition that year
      YearUniq$establishment[YearUniq$year %in% meas_pl$YEAR_RAW[meas_pl$ACTIVITY %in% c("A","E")]] = TRUE
      #sets remeasuremement to TRUE if any plots in stand remeasured that year
      YearUniq$remeasurement[YearUniq$year %in% meas_pl$YEAR_RAW[meas_pl$ACTIVITY == "R"]] = TRUE
      #sets mortality to TRUE if any plots in stand remeasured or checked for mortality that year
      YearUniq$mortality[YearUniq$year %in% meas_pl$YEAR_RAW[meas_pl$ACTIVITY == "R"]] = TRUE
      YearUniq$mortality[YearUniq$year %in% meas_pl$YEAR_RAW[meas_pl$ACTIVITY == "M"]] = TRUE
      
      #get aggreate year
      for(j in 1:nrow(YearUniq)){
        # j <- 1
        YearUniq$aggYear[j] = median(meas_pl$YEAR_AGG[meas_pl$YEAR_RAW == YearUniq$year[j]])}
      
      #check tree and mort data for additional years
      treeYearMissing <- unique(tree_pl$YEAR[! tree_pl$YEAR %in% YearUniq$year])
      
      if(length(treeYearMissing) > 0) 
        YearUniq <- rbind(YearUniq,cbind(year = treeYearMissing,
                                         establishment = FALSE,
                                         remeasurement = TRUE,
                                         mortality = TRUE,
                                         aggYear = treeYearMissing))
      
      mortYearMissing <- unique(mort_pl$YEAR[! mort_pl$YEAR %in% YearUniq$year])
      
      #get agg years
      aggYear <- sort(unique(YearUniq$aggYear))
      
      #create data.frame to hold data summaries
      cnames = c("Stand","Plot","CWDYear","treeYear1","treeYear2","Species",
                 "tph0_spp","tph1_spp","ba0_spp","ba1_spp",
                 "surv_prop_spp",
                 "growth_ba_spp",
                 "dYear","area_ha","minDBH_cm")
      out = data.frame(matrix(NA, nrow = 1, ncol = length(cnames)))
      colnames(out) = cnames
      
      out$CWDYear = CWD_year
      out$treeYear1 = min(aggYear[aggYear >= (CWD_year-10)])
      out$treeYear2 = min(aggYear[aggYear >= (out$treeYear1+20)])
      out$dYear = out$treeYear2 - out$treeYear1
      
      out$Stand = unlist(strsplit(SP_tmp[pl]," "))[1]
      out$Plot = unlist(strsplit(SP_tmp[pl]," "))[2]
      out$Species = SpeciesUniq[sp]
      rm(list = c("cnames"))
      
      #calculate area in hectares for stand and year during plot establishment for first post-CWD measurement
      yearList = YearUniq$year[which(YearUniq$aggYear == out$treeYear1)]###
      
      area_ha = meas_pl$PLOT_AREA_M2_CORR[meas_pl$YEAR_RAW == YearUniq$year[YearUniq$year == yearList[length(yearList)]]]/10000
      minDBH = meas_pl$DBH_MINIMUM [meas_pl$YEAR_RAW == YearUniq$year[YearUniq$year == yearList[length(yearList)]]]
      
      
      if(length(area_ha) == 0) {
        area_ha <- out$area_ha[1]
        minDBH <- out$minDBH_cm[1]
      }
      out$area_ha     <- area_ha
      out$minDBH_cm   <- minDBH
      
      #Get Tree Initial Measurement - all species
      treeList_all_0 = tree_pl[tree_pl$YEAR %in% YearUniq$year[YearUniq$aggYear == out$treeYear1],]
      #subselect to trees of focal species
      treeList_spp_0 = treeList_all_0[treeList_all_0$SPECIES == SpeciesUniq[sp],]
      if(nrow(treeList_spp_0) == 0) next
      
      out$tph0_spp <- nrow(treeList_spp_0[treeList_spp_0$TREE_STATUS %in% c(1,2),])/area_ha
      out$ba0_spp  <- sum(pi*(treeList_spp_0$DBH[treeList_spp_0$TREE_STATUS %in% c(1,2)]/2)^2)/10000/area_ha
      
      #get tph and ba in time 2
      treeList_all_1 = tree_pl[tree_pl$YEAR %in% YearUniq$year[YearUniq$aggYear == out$treeYear2],]
      #subselect to trees of focal species
      treeList_spp_1 = treeList_all_1[treeList_all_1$SPECIES == SpeciesUniq[sp],]
      
      if(nrow(treeList_spp_1) == 0) next
      
      out$tph1_spp <- nrow(treeList_spp_1[treeList_spp_1$TREE_STATUS %in% c(1,2),])/area_ha
      out$ba1_spp  <- sum(pi*(treeList_spp_1$DBH[treeList_spp_1$TREE_STATUS %in% c(1,2)]/2)^2)/10000/area_ha
      
      #get growth of trees alive at time 1 and time 2
      tmp0 <- treeList_spp_0[treeList_spp_0$TREE_STATUS %in% c(1,2),]
      tmp1 <- treeList_spp_1[treeList_spp_1$TREE_STATUS %in% c(1,2),]
      
      keep0 <- which(tmp0$TAG %in% tmp1$TAG)
      keep1 <- match(tmp0$TAG[keep0],tmp1$TAG)
      
      if(length(keep1) > 0)
        out$growth_ba_spp <- sum(pi*(tmp1$DBH[keep1]/2)^2)/10000/area_ha -
                             sum(pi*(tmp0$DBH[keep0]/2)^2)/10000/area_ha
      
      #get survival of trees alive at time 1
      out$surv_prop_spp <- length(keep0)/nrow(tmp0)
       
      out_pl[[pl]] <- out }
    
    out_st_pl[[st]] <- purrr::list_rbind(out_pl) }
  
  out_sp_st_pl[[sp]] <- purrr::list_rbind(out_st_pl)
  
  #clean up workspace
  rm(list = c("out", "area_ha"))
  
}


final_df <- purrr::list_rbind(out_sp_st_pl)

##save
write.csv(final_df[final_df$Species == "PSME",],
          file.path("data", "AND_test-out.csv"), 
          # Originally: "PSP_Plot_Change_20year_PSME_v2.csv"
          row.names = FALSE)

