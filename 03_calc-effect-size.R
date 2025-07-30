## --------------------------------------------------------------------- ##
# Material Legacy - Calculate Effect Sizes
## --------------------------------------------------------------------- ##
# Code author(s): Nick J Lyon, 

# Purpose
## Fit models for each LTER and extract effect sizes

# Pre-Requisites
## Have wrangled data (can be done by running `02_wrangle.R`)

## -------------------------------------------- ##
# Housekeeping ----
## -------------------------------------------- ##

# Load libraries
librarian::shelf(tidyverse, glmmTMB, broom.mixed, ggeffects)

# Clear environment
rm(list = ls()); gc()

# Read in data
ef_v1 <- read.csv(file.path("data", "tidy", "02_wrangled.csv")) %>% 
  # Make empty cells into true NAs
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
                              .fns = ~ ifelse(nchar(.) == 0, yes = NA, no = .)))

# Check structure
dplyr::glimpse(ef_v1)

## -------------------------------------------- ##
# Prepare Data ----
## -------------------------------------------- ##

# Each LTER uses a different model structure based on what is appropriate for that context

# Make an empty list
lter_list <- list()

# Split data into a named list
for(focal_lter in sort(unique(ef_v1$lter))){
  
  # Separate out that LTER's data and drop any columns that aren't needed for that LTER
  focal_sub <- ef_v1 %>% 
    dplyr::filter(lter == focal_lter) %>% 
    dplyr::select(-dplyr::where(fn = ~ all(is.na(.))))
  
  # Add to list
  lter_list[[focal_lter]] <- focal_sub
}

# Check structure
dplyr::glimpse(lter_list)

## -------------------------------------------- ##
# Fit Models ----
## -------------------------------------------- ##

# Make an empty list
model_list <- list()

# BNZ: does continuous treatment (standing dead area) affect the response?
## Random effects = random slope of categorical treatment within site
model_list[["BNZ"]] <- glmmTMB::glmmTMB(response ~ treatment_continuous + 
                                          (1 | treatment_categorical/site),
                                        family = glmmTMB::tweedie(link = "log"),
                                        data = lter_list[["BNZ"]])
## From Kai: "False convergence warning; tried many alternative options, none of which resolved this. Proceeding anyway, but with caution; diagnostics tests won't run due to non-convergence"

# GCE: does categorical treatment affect the response?
## Random effects = random intercepts for site and year
model_list[["GCE"]] <- glmmTMB::glmmTMB(response ~ treatment_categorical + 
                                          (1 | site) + (1 | year),
                                        family = stats::gaussian(link = "logit"),
                                     data = lter_list[["GCE"]])

# LUQ: does categorical treatment affect the response?
## Random effects = random slope of block within plot and an intercept of year
model_list[["LUQ"]] <- glmmTMB::glmmTMB(response ~ treatment_categorical + 
                                       (1 | block/plot) + (1 | year),
                                     family = glmmTMB::nbinom2,
                                     data = lter_list[["LUQ"]])

# MCR: does continuous treatment (starting dead coral area) affect the response?
## Random effects = random slope of categorical treatment nested in plot and intercept of year
model_list[["MCR"]] <- glmmTMB::glmmTMB(response ~ treatment_continuous + 
                                       (1 | treatment_categorical/plot) + (1 | year),
                                     family = stats::gaussian(link = "identity"),
                                     data = lter_list[["MCR"]])

# VCR: does taxa (oyster juvenile/dead) affect the response?
## Random effects = random intercept of site and year
model_list[["VCR"]] <- glmmTMB::glmmTMB(response ~ taxa + 
                                       (1 | site) + (1 | year),
                                       family = stats::Gamma(link = "log"),
                                       ## Gamma doesn't support non-positive responses
                                       data = dplyr::filter(lter_list[["VCR"]],
                                                            response > 0))

## -------------------------------------------- ##
# Calculate Effect Sizes ----
## -------------------------------------------- ##

# Calculate effect sizes
ef_v2 <- model_list %>% 
  # Get tidy tables for all models
  purrr::map(.x = ., 
             .f = ~ broom.mixed::tidy(x = .x, effects = "fixed", 
                                      conf.int = T, conf.level = 0.95)) %>% 
  # Add a column for LTER
  purrr::imap(.x = .,
              .f = ~ dplyr::mutate(.data = .x, lter = .y,
                                   .before = dplyr::everything())) %>% 
  # Collapse to dataframe
  purrr::list_rbind(x = .)

# Check structure
dplyr::glimpse(ef_v2)

## -------------------------------------------- ##
# Export Effect Sizes ----
## -------------------------------------------- ##

# Make a final data object
ef_v99 <- ef_v2

# Export this locally
write.csv(ef_v99, row.names = F, na = '',
          file = file.path("data", "tidy", "03_effect-sizes.csv"))

## -------------------------------------------- ##
# Extract Model Predictions ----
## -------------------------------------------- ##

# Extract model predictions
pred_v1 <- model_list %>% 
  # Get predictions
  purrr::map(.x = .,
             .f = ~ ggeffects::ggpredict(model = .x,
                                         term = attr(.x$modelInfo$terms$cond$fixed, 
                                                     "term.labels"))) %>% 
  # Force them into dataframe format
  purrr::map(.x = ., .f = as.data.frame) %>% 
  # Add a column for LTER
  purrr::imap(.x = ., .f = ~ dplyr::mutate(.data = .x, lter = .y,
                                           .before = dplyr::everything())) %>% 
  # Ditch group column
  purrr::map(.x = ., .f = ~ dplyr::select(.data = .x, -dplyr::starts_with("group"))) %>% 
  # Make everything into characters
  purrr::map(.x = ., .f = ~ dplyr::mutate(.data = .x,
                                          dplyr::across(.cols = dplyr::everything(),
                                                        .fns = ~ as.character(.)))) %>% 
  
  # Collapse to dataframe
  purrr::list_rbind(x = .)

# Check structure
dplyr::glimpse(pred_v1)

# Duplicate that object and add a placeholder column
pred_v2 <- pred_v1 %>% 
  dplyr::mutate(term = NA, .before = x)

# Attach what the term actual was (rather than levels within term)
for(focal_lter in sort(unique(pred_v1$lter))){
  
  # Grab the relevant term for that LTER
  pred_v2 <- pred_v2 %>% 
    dplyr::mutate(term = ifelse(lter != focal_lter, yes = term,
                                no = attr(model_list[[focal_lter]]$modelInfo$terms$cond$fixed,
                                          "term.labels")))
}

# Check structure
dplyr::glimpse(pred_v2)

## -------------------------------------------- ##
# Export Predictions ----
## -------------------------------------------- ##

# Make a final data object
pred_v99 <- pred_v2

# Export this locally
write.csv(pred_v99, row.names = F, na = '',
          file = file.path("data", "tidy", "03_model-predictions.csv"))

# End ----
