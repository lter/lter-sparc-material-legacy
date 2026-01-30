# Internal helpers for schema validation

ml_vocab <- function() {
  list(
    design = c("observational", "experimental"),
    ecosystem_type = c("marine", "terrestrial"),
    mechanism_class = c("resource", "structural", "mixed", "unknown"),
    legacy_type = c(
      "deadwood", "snag", "litter", "shell", "skeleton", "wrack",
      "canopy_detritus", "holdfast", "burned_tree", "debris", "other"
    ),
    response_type = c(
      "recruitment", "growth", "survival", "productivity", "settlement",
      "seed_release", "clonal_regrowth", "establishment", "other"
    )
  )
}

ml_schema <- function() {
  vocab <- ml_vocab()
  list(
    obs_ptype = tibble::tibble(
      site_id = character(),
      system_id = character(),
      plot_id = character(),
      date = as.Date(character()),
      year = integer(),
      design = factor(levels = vocab$design),
      legacy_type = factor(levels = vocab$legacy_type),
      legacy_metric = character(),
      legacy_value = double(),
      legacy_unit = character(),
      response_type = factor(levels = vocab$response_type),
      response_metric = character(),
      response_value = double(),
      response_unit = character()
    ),
    systems_ptype = tibble::tibble(
      system_id = character(),
      site_id = character(),
      ecosystem_type = factor(levels = vocab$ecosystem_type),
      ecosystem_subtype = character(),
      foundation_species = character(),
      legacy_type = factor(levels = vocab$legacy_type),
      legacy_metric = character(),
      response_type = factor(levels = vocab$response_type),
      response_metric = character(),
      design = factor(levels = vocab$design),
      data_years_start = integer(),
      data_years_end = integer(),
      mechanism_class = factor(levels = vocab$mechanism_class),
      mechanism_notes = character()
    )
  )
}

ml_validate_tbl <- function(x, ptype, name, strict = TRUE) {
  required <- names(ptype)
  missing <- setdiff(required, names(x))
  if (length(missing) > 0) {
    stop(
      sprintf(
        "Table %s is missing required columns: %s",
        name,
        paste(missing, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  # Drop extra columns (if any) but keep a comment here so it's not silent.
  x <- tibble::as_tibble(x)
  x <- x[, required, drop = FALSE]

  out <- tryCatch(
    vctrs::vec_cast(x, ptype),
    error = function(e) {
      stop(
        sprintf("Table %s failed to cast columns: %s", name, e$message),
        call. = FALSE
      )
    }
  )

  out
}

ml_validate_site_bundle <- function(bundle, schema, strict = TRUE) {
  if (!is.list(bundle)) {
    stop("Site bundle must be a list.", call. = FALSE)
  }
  if (!all(c("obs", "systems") %in% names(bundle))) {
    stop("Site bundle must include 'obs' and 'systems' tables.", call. = FALSE)
  }

  obs <- ml_validate_tbl(bundle$obs, schema$obs_ptype, "obs", strict = strict)
  systems <- ml_validate_tbl(
    bundle$systems,
    schema$systems_ptype,
    "systems",
    strict = strict
  )

  if (anyDuplicated(systems$system_id) > 0) {
    dupes <- unique(systems$system_id[duplicated(systems$system_id)])
    stop(
      sprintf(
        "Table systems has duplicate system_id values: %s",
        paste(dupes, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  missing_ids <- setdiff(unique(obs$system_id), systems$system_id)
  if (length(missing_ids) > 0) {
    stop(
      sprintf(
        "Table obs references unknown system_id values: %s",
        paste(missing_ids, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  bundle$obs <- obs
  bundle$systems <- systems
  bundle
}
