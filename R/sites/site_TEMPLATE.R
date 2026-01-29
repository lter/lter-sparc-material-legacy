# This file is for site contributors.
#
# You will edit this file to create a site standardizer. A site standardizer
# reads one site’s raw data and produces two canonical tables: `obs` and
# `systems`. Do not change the harmonizer or schema files when working here.

standardize_TEMPLATE <- function(path, ...) {
  # ---------------------------------------------------------------------------
  # What you are responsible for
  # ---------------------------------------------------------------------------
  # - Read your raw data files here.
  # - Create one row per plot per date in the obs table.
  # - Choose the correct legacy_type and response_type from the allowed lists.
  # - Build a systems table that describes each legacy–demography relationship.
  # - Keep system_id values stable over time.
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # What the harmonizer will take care of for you
  # ---------------------------------------------------------------------------
  # - Check that required columns exist.
  # - Check that factor levels match the allowed vocabularies.
  # - Check that obs and systems share the same system_id values.
  # - Combine all sites into a single harmonized output.
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # Step-by-step worksheet
  # ---------------------------------------------------------------------------
  # 1) Read your raw data files.
  # raw_obs <- read.csv(file.path(path, "observations.csv"))
  # raw_systems <- read.csv(file.path(path, "systems.csv"))

  # 2) Create the obs table (one row per plot per date).
  # obs <- tibble::tibble(
  #   site_id = "<SITE>",
  #   system_id = raw_obs$system_id,
  #   plot_id = raw_obs$plot,
  #   date = as.Date(raw_obs$date),
  #   year = as.integer(format(as.Date(raw_obs$date), "%Y")),
  #   design = factor(raw_obs$design, levels = ml_vocab()$design),
  #   legacy_type = factor(raw_obs$legacy_type, levels = ml_vocab()$legacy_type),
  #   legacy_metric = raw_obs$legacy_metric,
  #   legacy_value = as.numeric(raw_obs$legacy_value),
  #   legacy_unit = raw_obs$legacy_unit,
  #   response_type = factor(raw_obs$response_type, levels = ml_vocab()$response_type),
  #   response_metric = raw_obs$response_metric,
  #   response_value = as.numeric(raw_obs$response_value),
  #   response_unit = raw_obs$response_unit
  # )

  # 3) Choose legacy_type and response_type from these lists:
  # legacy_type: deadwood, snag, litter, shell, skeleton, wrack,
  #              canopy_detritus, holdfast, burned_tree, debris, other
  # response_type: recruitment, growth, survival, productivity, settlement,
  #                seed_release, clonal_regrowth, establishment, other

  # 4) Define your system_id values.
  # Use this exact format and keep it stable:
  # "<SITE>__{legacy_type}__{response_type}__{nn}"
  # - nn must be two digits (01, 02, ...)
  # - If multiple systems, use __01, __02, etc.
  # Example: "<SITE>__deadwood__growth__01"

  # 5) Build the systems table (one row per system_id).
  # systems <- tibble::tibble(
  #   system_id = "<SITE>__deadwood__growth__01",
  #   site_id = "<SITE>",
  #   ecosystem_type = factor("terrestrial", levels = ml_vocab()$ecosystem_type),
  #   ecosystem_subtype = "forest",
  #   foundation_species = "Example species",
  #   legacy_type = factor("deadwood", levels = ml_vocab()$legacy_type),
  #   legacy_metric = "volume",
  #   response_type = factor("growth", levels = ml_vocab()$response_type),
  #   response_metric = "biomass",
  #   design = factor("observational", levels = ml_vocab()$design),
  #   data_years_start = 2020L,
  #   data_years_end = 2021L,
  #   mechanism_class = factor("resource", levels = ml_vocab()$mechanism_class),
  #   mechanism_notes = "Explain unclear mechanisms here."
  # )

  # 6) If you do not have a perfect vocabulary match, use "other" and explain
  # the choice in mechanism_notes or ecosystem_subtype. Do not add new words
  # to the vocabulary without discussing it in a PR.

  # Placeholder objects to show required list structure.
  obs <- tibble::tibble()
  systems <- tibble::tibble()

  # Optional outputs for QA/provenance.
  qa <- tibble::tibble()
  provenance <- list(path = path)

  # ---------------------------------------------------------------------------
  # Checklist before opening a pull request
  # ---------------------------------------------------------------------------
  # - Run ml_quickcheck_site("<SITE>", inputs = list(path = "..."))
  # - Make sure date is a Date and year is an integer
  # - Make sure obs and systems share the same system_id values
  # - Make sure factor levels match the allowed vocabularies
  # - Register the site in ml_registry()
  # ---------------------------------------------------------------------------

  list(obs = obs, systems = systems, qa = qa, provenance = provenance)
}
