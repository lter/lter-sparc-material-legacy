standardize_EXAMPLE <- function(path, ...) {
  system_id <- "EXAMPLE__deadwood__growth__01"

  obs <- tibble::tibble(
    site_id = "EXAMPLE",
    system_id = system_id,
    plot_id = "plot-1",
    date = as.Date("2020-06-01"),
    year = 2020L,
    design = factor("observational", levels = ml_vocab()$design),
    legacy_type = factor("deadwood", levels = ml_vocab()$legacy_type),
    legacy_metric = "volume",
    legacy_value = 1.5,
    legacy_unit = "m3",
    response_type = factor("growth", levels = ml_vocab()$response_type),
    response_metric = "biomass",
    response_value = 2.1,
    response_unit = "g"
  )

  systems <- tibble::tibble(
    system_id = system_id,
    site_id = "EXAMPLE",
    ecosystem_type = factor("terrestrial", levels = ml_vocab()$ecosystem_type),
    ecosystem_subtype = "forest",
    foundation_species = "Example species",
    legacy_type = factor("deadwood", levels = ml_vocab()$legacy_type),
    legacy_metric = "volume",
    response_type = factor("growth", levels = ml_vocab()$response_type),
    response_metric = "biomass",
    design = factor("observational", levels = ml_vocab()$design),
    data_years_start = 2020L,
    data_years_end = 2021L,
    mechanism_class = factor("resource", levels = ml_vocab()$mechanism_class),
    mechanism_notes = "Synthetic example."
  )

  list(obs = obs, systems = systems)
}
