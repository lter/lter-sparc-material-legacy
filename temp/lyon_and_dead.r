
# Load libraries
librarian::shelf(tidyverse, janitor, supportR)

# Clear environment
rm(list = ls()); gc()

# Load in relevant data
and_wood_v01 <- read.csv(file.path("data", "raw", "00_AND__TD01204.csv")) %>% 
  janitor::clean_names()

# Check structure
dplyr::glimpse(and_wood_v01)

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

# Summarize dead wood metrics by plot
and_wood_v04 <- and_wood_v03 %>% 
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
dplyr::glimpse(and_wood_v04)

# Load dead data
and_dead <- read.csv(file = file.path("data", "from-drive", "OHJA_downed wood summary_v2.csv")) %>% 
  janitor::clean_names() %>% 
  dplyr::mutate(stand_plot = paste(stand, plot))


supportR::diff_check(unique(and_wood_v04$stand), unique(and_dead$stand))
supportR::diff_check(unique(and_wood_v04$plot), unique(and_dead$plot))
supportR::diff_check(unique(and_wood_v04$stand_plot), unique(and_dead$stand_plot))
supportR::diff_check(unique(and_wood_v04$year), unique(and_dead$year))

glimpse(and_dead)

supportR::diff_check(unique(and_wood_v03$plot_og), unique(and_dead$plot_og))


filter(and_dead, stand_plot == "BRNA 4" & year == 1977) %>% dplyr::pull(total_cover)
filter(and_wood_v04, stand_plot == "BRNA 4" & year == 1977) %>% dplyr::pull(total_cover)

