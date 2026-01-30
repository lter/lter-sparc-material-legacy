#' Harmonize material legacy data across sites
#'
#' This function runs one or more site standardizers, checks that the results
#' match the canonical tables, and then combines them into a single output.
#' A site standardizer is a function that reads one site’s raw data and returns
#' two canonical tables: `obs` and `systems`.
#'
#' If a site fails validation, the error is recorded in the output. By default,
#' the function continues and processes the remaining sites. You can change that
#' behavior with `continue_on_error = FALSE`.
#'
#' The returned object contains:
#' - `obs`: observation-level data
#' - `systems`: metadata describing each legacy–demography relationship
#' - `site_log`: a summary of per-site results
#' - `errors`: any site-level errors
#' - `timestamp`: when the harmonization was run
#'
#' @param sites Character vector of site identifiers to run. Defaults to all
#'   registered sites.
#' @param registry Named list of site standardizers keyed by site identifier.
#' @param inputs Named list of arguments to pass to each standardizer.
#' @param strict Logical indicating whether to enforce strict validation.
#' @param continue_on_error Logical indicating whether to continue after site
#'   errors.
#' @param quiet Logical indicating whether to suppress progress messages.
#' @param return_site_outputs Logical indicating whether to include cleaned
#'   site outputs in the result.
#'
#' @return An object of class `ml_harmonized`.
#' @examples
#' harmonize_material_legacies(sites = "EXAMPLE", quiet = TRUE)
#' 
#' harmonize_material_legacies(
#'   sites = "EXAMPLE",
#'   inputs = list(EXAMPLE = list(path = "data/raw/EXAMPLE")),
#'   quiet = TRUE
#' )
#'
#' @export
harmonize_material_legacies <- function(
  sites = NULL,
  registry = ml_registry(),
  inputs = NULL,
  strict = TRUE,
  continue_on_error = TRUE,
  quiet = FALSE,
  return_site_outputs = FALSE
) {
  available_sites <- names(registry)
  if (is.null(sites)) {
    sites <- available_sites
  } else {
    missing_sites <- setdiff(sites, available_sites)
    if (length(missing_sites) > 0) {
      stop(
        sprintf(
          "Unknown site identifiers: %s",
          paste(missing_sites, collapse = ", ")
        ),
        call. = FALSE
      )
    }
  }

  if (is.null(inputs)) {
    inputs <- stats::setNames(
      lapply(sites, function(site) list(path = file.path("data/raw", site))),
      sites
    )
  } else {
    if (is.null(names(inputs))) {
      stop("inputs must be a named list keyed by site_id.", call. = FALSE)
    }
    for (site in sites) {
      if (is.null(inputs[[site]])) {
        inputs[[site]] <- list(path = file.path("data/raw", site))
      }
    }
  }

  schema <- ml_schema()
  obs_list <- list()
  systems_list <- list()
  site_outputs <- list()
  site_log <- tibble::tibble(
    site_id = character(),
    n_obs = integer(),
    n_systems = integer(),
    status = character()
  )
  errors <- tibble::tibble(site_id = character(), error_message = character())

  for (site in sites) {
    fn <- registry[[site]]
    if (!quiet) {
      message(sprintf("Harmonizing site %s", site))
    }

    result <- tryCatch(
      {
        bundle <- do.call(fn, inputs[[site]])
        clean_bundle <- ml_validate_site_bundle(bundle, schema, strict = strict)
        list(bundle = clean_bundle, error = NULL)
      },
      error = function(e) list(bundle = NULL, error = e)
    )

    if (!is.null(result$error)) {
      errors <- tibble::add_row(
        errors,
        site_id = site,
        error_message = result$error$message
      )
      site_log <- tibble::add_row(
        site_log,
        site_id = site,
        n_obs = NA_integer_,
        n_systems = NA_integer_,
        status = "error"
      )
      if (!continue_on_error) {
        stop(result$error)
      }
      next
    }

    bundle <- result$bundle
    obs_list[[site]] <- bundle$obs
    systems_list[[site]] <- bundle$systems
    site_log <- tibble::add_row(
      site_log,
      site_id = site,
      n_obs = nrow(bundle$obs),
      n_systems = nrow(bundle$systems),
      status = "ok"
    )
    if (return_site_outputs) {
      site_outputs[[site]] <- bundle
    }
  }

  obs_all <- if (length(obs_list) > 0) {
    dplyr::bind_rows(obs_list)
  } else {
    schema$obs_ptype[0, ]
  }
  systems_all <- if (length(systems_list) > 0) {
    dplyr::bind_rows(systems_list)
  } else {
    schema$systems_ptype[0, ]
  }

  if (anyDuplicated(systems_all$system_id) > 0) {
    dupes <- unique(systems_all$system_id[duplicated(systems_all$system_id)])
    stop(
      sprintf(
        "Global systems table has duplicate system_id values: %s",
        paste(dupes, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  missing_ids <- setdiff(unique(obs_all$system_id), systems_all$system_id)
  if (length(missing_ids) > 0) {
    stop(
      sprintf(
        "Global obs table references unknown system_id values: %s",
        paste(missing_ids, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  output <- list(
    obs = obs_all,
    systems = systems_all,
    site_log = site_log,
    errors = errors,
    timestamp = Sys.time()
  )
  if (return_site_outputs) {
    output$site_outputs <- site_outputs
  }
  class(output) <- "ml_harmonized"
  output
}

#' @export
print.ml_harmonized <- function(x, ...) {
  cat("ml_harmonized object\n")
  cat(sprintf("  Sites: %s\n", nrow(x$site_log)))
  cat(sprintf("  Observations: %s\n", nrow(x$obs)))
  cat(sprintf("  Systems: %s\n", nrow(x$systems)))
  if (nrow(x$errors) > 0) {
    cat(sprintf("  Errors: %s\n", nrow(x$errors)))
  }
  invisible(x)
}

#' @export
summary.ml_harmonized <- function(object, ...) {
  list(
    n_sites = nrow(object$site_log),
    n_obs = nrow(object$obs),
    n_systems = nrow(object$systems),
    errors = object$errors,
    timestamp = object$timestamp
  )
}
