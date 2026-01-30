standardize_HFR <- function(path = NULL, use_fixture = FALSE, ...) {
  if (isTRUE(use_fixture) || is.null(path)) {
    base_path <- system.file("extdata/sites/HFR", package = "macabre")
    if (!nzchar(base_path)) {
      stop("Fixture path for HFR not found.", call. = FALSE)
    }
    path <- base_path
  }

  obs_file <- file.path(path, "hfr_obs_raw.csv")
  systems_file <- file.path(path, "hfr_systems_raw.csv")
  if (!file.exists(obs_file)) {
    stop(sprintf("Missing HFR observations file: %s", obs_file), call. = FALSE)
  }
  if (!file.exists(systems_file)) {
    stop(sprintf("Missing HFR systems file: %s", systems_file), call. = FALSE)
  }

  raw_obs <- utils::read.csv(obs_file, stringsAsFactors = FALSE)
  raw_systems <- utils::read.csv(systems_file, stringsAsFactors = FALSE)

  system_id <- "HFR__deadwood__growth__01"

  obs_date <- as.Date(raw_obs$date)
  obs_year <- as.integer(format(obs_date, "%Y"))

  obs <- tibble::tibble(
    site_id = "HFR",
    system_id = system_id,
    plot_id = raw_obs$plot_id,
    date = obs_date,
    year = obs_year,
    design = factor(raw_obs$design, levels = ml_vocab()$design),
    legacy_type = factor("deadwood", levels = ml_vocab()$legacy_type),
    legacy_metric = "volume",
    legacy_value = as.numeric(raw_obs$legacy_volume_m3),
    legacy_unit = "m3",
    response_type = factor("growth", levels = ml_vocab()$response_type),
    response_metric = "biomass",
    response_value = as.numeric(raw_obs$response_biomass_g),
    response_unit = "g"
  )

  systems <- tibble::tibble(
    system_id = system_id,
    site_id = "HFR",
    ecosystem_type = factor(raw_systems$ecosystem_type,
                            levels = ml_vocab()$ecosystem_type),
    ecosystem_subtype = raw_systems$ecosystem_subtype,
    foundation_species = raw_systems$foundation_species,
    legacy_type = factor("deadwood", levels = ml_vocab()$legacy_type),
    legacy_metric = "volume",
    response_type = factor("growth", levels = ml_vocab()$response_type),
    response_metric = "biomass",
    design = factor(raw_systems$design, levels = ml_vocab()$design),
    data_years_start = as.integer(raw_systems$data_years_start),
    data_years_end = as.integer(raw_systems$data_years_end),
    mechanism_class = factor(raw_systems$mechanism_class,
                             levels = ml_vocab()$mechanism_class),
    mechanism_notes = raw_systems$mechanism_notes
  )

  qa <- list(
    n_obs = nrow(obs),
    n_systems = nrow(systems)
  )
  provenance <- list(
    path = path,
    files = c(obs_file = obs_file, systems_file = systems_file),
    timestamp = Sys.time()
  )

  list(obs = obs, systems = systems, qa = qa, provenance = provenance)
}
