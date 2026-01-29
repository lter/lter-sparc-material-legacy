# Internal helpers -------------------------------------------------------

.ml_find_pkg_root <- function(start = getwd()) {
  current <- normalizePath(start, winslash = "/", mustWork = FALSE)
  repeat {
    desc <- file.path(current, "DESCRIPTION")
    if (file.exists(desc)) {
      return(current)
    }
    parent <- dirname(current)
    if (identical(parent, current)) {
      break
    }
    current <- parent
  }
  NULL
}

.ml_template_path <- function() {
  template_path <- system.file("sites/site_TEMPLATE.R", package = "macabre")
  if (nzchar(template_path) && file.exists(template_path)) {
    return(template_path)
  }

  root <- .ml_find_pkg_root()
  if (!is.null(root)) {
    candidate <- file.path(root, "R", "sites", "site_TEMPLATE.R")
    if (file.exists(candidate)) {
      return(candidate)
    }
  }

  stop("Could not locate site template file.", call. = FALSE)
}

.ml_validate_site_id <- function(site_id) {
  if (!is.character(site_id) || length(site_id) != 1 || is.na(site_id)) {
    stop("site_id must be a single, non-missing character value.", call. = FALSE)
  }
  if (!grepl("^[A-Z0-9_]+$", site_id)) {
    stop(
      "site_id must contain only uppercase letters, numbers, and underscores.",
      call. = FALSE
    )
  }
  invisible(site_id)
}

.ml_site_summary <- function(bundle) {
  obs <- bundle$obs
  systems <- bundle$systems

  year_range <- if (nrow(obs) > 0) {
    range(obs$year, na.rm = TRUE)
  } else {
    c(NA_integer_, NA_integer_)
  }

  missing_numeric <- list(
    legacy_value = sum(is.na(obs$legacy_value)),
    response_value = sum(is.na(obs$response_value))
  )

  legacy_types <- sort(unique(as.character(obs$legacy_type)))
  response_types <- sort(unique(as.character(obs$response_type)))

  cat("Quickcheck summary\n")
  cat(sprintf("  Observations: %s\n", nrow(obs)))
  cat(sprintf("  Systems: %s\n", nrow(systems)))
  cat(sprintf("  Year range: %s - %s\n", year_range[1], year_range[2]))
  cat(sprintf(
    "  Missing legacy_value: %s\n",
    missing_numeric$legacy_value
  ))
  cat(sprintf(
    "  Missing response_value: %s\n",
    missing_numeric$response_value
  ))
  cat(sprintf(
    "  legacy_type values: %s\n",
    paste(legacy_types, collapse = ", ")
  ))
  cat(sprintf(
    "  response_type values: %s\n",
    paste(response_types, collapse = ", ")
  ))
}

#' Create a new site standardizer file from the template
#'
#' Use this helper if you are adding a new site. It creates a new file named
#' `site_<SITE>.R` in `R/sites/` based on the package template. You still need
#' to edit the file and register your site in `ml_registry()`.
#'
#' @param site_id Site identifier (uppercase letters, numbers, underscores).
#' @param path Directory where the new site file should be created.
#' @param open Logical; if TRUE, prints the file path for convenience.
#'
#' @return The path to the newly created file.
#' @export
ml_new_site_file <- function(site_id, path = "R/sites", open = FALSE) {
  .ml_validate_site_id(site_id)

  template_path <- .ml_template_path()
  target_dir <- normalizePath(path, winslash = "/", mustWork = FALSE)
  if (!dir.exists(target_dir)) {
    dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)
  }

  target_file <- file.path(target_dir, paste0("site_", site_id, ".R"))
  if (file.exists(target_file)) {
    stop(
      sprintf("Site file already exists at %s", target_file),
      call. = FALSE
    )
  }

  lines <- readLines(template_path, warn = FALSE)
  lines <- gsub("standardize_TEMPLATE", paste0("standardize_", site_id), lines)
  lines <- gsub("<SITE>", site_id, lines, fixed = TRUE)

  writeLines(lines, target_file)

  if (isTRUE(open)) {
    message(sprintf("Created %s", target_file))
  }

  target_file
}

#' Quick diagnostics for a single site standardizer
#'
#' This helper runs your site standardizer and prints a short summary. It is
#' the first thing to run before opening a pull request. If it fails, read the
#' error message closely: most issues are missing columns, wrong factor levels,
#' or mismatched `system_id` values between the canonical tables.
#'
#' @param site_id Site identifier registered in `ml_registry()`.
#' @param inputs Named list of arguments to pass to the site standardizer.
#' @param strict Logical indicating whether to enforce strict validation.
#'
#' @return An `ml_harmonized` object (invisibly).
#' @export
ml_quickcheck_site <- function(site_id, inputs = list(), strict = TRUE) {
  .ml_validate_site_id(site_id)

  result <- harmonize_material_legacies(
    sites = site_id,
    inputs = setNames(list(inputs), site_id),
    strict = strict,
    continue_on_error = FALSE,
    return_site_outputs = TRUE,
    quiet = TRUE
  )

  .ml_site_summary(result)

  invisible(result)
}
