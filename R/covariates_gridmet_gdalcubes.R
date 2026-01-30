#' Create a gridMET covariate specification
#'
#' @param vars Character vector of gridMET variables.
#' @param dt Temporal resolution (ISO8601 duration string).
#' @param agg_time Optional temporal aggregation function.
#' @param agg_space Spatial aggregation function for polygons.
#' @param res Spatial resolution in degrees.
#'
#' @return An object of class `ml_cov_spec`.
#' @export
ml_cov_gridmet_spec <- function(
  vars = c("tmmx", "tmmn", "pr"),
  dt = "P1D",
  agg_time = NULL,
  agg_space = "mean",
  res = c(0.04, 0.04)
) {
  spec <- list(
    id = "gridmet",
    vars = vars,
    dt = dt,
    agg_time = agg_time,
    agg_space = agg_space,
    res = res,
    description = "gridMET-style climate covariates"
  )
  class(spec) <- "ml_cov_spec"
  spec
}

ml_cov_extract_gridmet <- function(cube, locations_sf, vars, dt, res, agg_space) {
  if (!requireNamespace("gdalcubes", quietly = TRUE)) {
    stop("gdalcubes is required for covariate extraction.", call. = FALSE)
  }
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("sf is required for covariate extraction.", call. = FALSE)
  }

  if (!all(c("site_id", "plot_id") %in% names(locations_sf))) {
    stop("locations must include site_id and plot_id columns.", call. = FALSE)
  }

  geom_type <- unique(sf::st_geometry_type(locations_sf))
  supported <- c("POINT", "MULTIPOINT", "POLYGON", "MULTIPOLYGON")
  if (!all(geom_type %in% supported)) {
    stop("Unsupported geometry type in locations.", call. = FALSE)
  }

  locations_tbl <- sf::st_drop_geometry(locations_sf)
  locations_tbl$.ml_row_id <- seq_len(nrow(locations_tbl))

  extract_one <- function(one_cube, var_name) {
    extracted <- gdalcubes::extract_geom(one_cube, locations_sf, func = agg_space)
    extracted <- tibble::as_tibble(extracted)

    id_col <- if ("FID" %in% names(extracted)) "FID" else if ("id" %in% names(extracted)) "id" else NULL
    if (is.null(id_col)) {
      stop("Extraction output missing feature identifier column.", call. = FALSE)
    }

    time_col <- if ("time" %in% names(extracted)) "time" else if ("datetime" %in% names(extracted)) "datetime" else NULL
    if (is.null(time_col)) {
      stop("Extraction output missing time column.", call. = FALSE)
    }

    value_col <- if (var_name %in% names(extracted)) {
      var_name
    } else if ("value" %in% names(extracted)) {
      "value"
    } else {
      stop("Extraction output missing value column.", call. = FALSE)
    }

    extracted$.ml_row_id <- extracted[[id_col]]
    extracted$date <- as.Date(extracted[[time_col]])
    extracted$value <- extracted[[value_col]]

    out <- extracted[, c(".ml_row_id", "date", "value")]
    out <- dplyr::left_join(locations_tbl, out, by = ".ml_row_id")
    out <- dplyr::select(out, site_id, plot_id, date, value)
    names(out)[4] <- paste0("clim_", var_name)
    tibble::as_tibble(out)
  }

  if (is.list(cube) && !inherits(cube, "gdalcubes_cube")) {
    if (is.null(vars)) {
      vars <- names(cube)
    }
    tables <- lapply(vars, function(var_name) {
      if (is.null(cube[[var_name]])) {
        stop(sprintf("Missing cube for variable %s", var_name), call. = FALSE)
      }
      extract_one(cube[[var_name]], var_name)
    })
  } else {
    tables <- lapply(vars, function(var_name) extract_one(cube, var_name))
  }

  covariates <- Reduce(
    function(x, y) dplyr::full_join(x, y, by = c("site_id", "plot_id", "date")),
    tables
  )

  covariates
}

#' Join climate covariates onto a harmonized object
#'
#' @param h An `ml_harmonized` object.
#' @param covariates A covariate spec or list of specs. Each element can also
#'   be a list with `spec` and `cube` entries.
#' @param locations An sf object with `site_id`, `plot_id`, and geometry.
#' @param join Join mode for covariates.
#' @param keep Whether to keep all rows or only matched rows.
#' @param warn_join_loss Warn if covariate join introduces missing values.
#'
#' @return Updated `ml_harmonized` object with covariates appended.
#' @export
ml_add_covariates <- function(
  h,
  covariates,
  locations,
  join = c("plot_date", "site_date", "plot_year", "site_year"),
  keep = "all",
  warn_join_loss = TRUE
) {
  join <- match.arg(join)
  if (!inherits(h, "ml_harmonized")) {
    stop("h must be an ml_harmonized object.", call. = FALSE)
  }
  if (!all(c("site_id", "plot_id", "date", "year") %in% names(h$obs))) {
    stop("h$obs is missing required join columns.", call. = FALSE)
  }
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("sf is required for covariate joins.", call. = FALSE)
  }
  if (!inherits(locations, "sf")) {
    stop("locations must be an sf object.", call. = FALSE)
  }

  cov_list <- covariates
  if (inherits(covariates, "ml_cov_spec")) {
    cov_list <- list(covariates)
  }

  if (is.null(h$covariates)) {
    h$covariates <- list()
  }
  if (is.null(h$joins)) {
    h$joins <- tibble::tibble(
      covariate_id = character(),
      join = character(),
      n_obs_before = integer(),
      n_obs_after = integer(),
      na_rate = double(),
      timestamp = as.POSIXct(character())
    )
  }

  join_keys <- switch(
    join,
    plot_date = c("site_id", "plot_id", "date"),
    site_date = c("site_id", "date"),
    plot_year = c("site_id", "plot_id", "year"),
    site_year = c("site_id", "year")
  )

  for (cov_item in cov_list) {
    if (inherits(cov_item, "ml_cov_spec")) {
      spec <- cov_item
      cube <- attr(cov_item, "cube")
    } else if (is.list(cov_item) && !is.null(cov_item$spec)) {
      spec <- cov_item$spec
      cube <- cov_item$cube
    } else {
      stop("covariates must be ml_cov_spec objects or list(spec=..., cube=...).", call. = FALSE)
    }

    if (is.null(cube)) {
      stop("No cube provided for covariate extraction.", call. = FALSE)
    }

    cov_tbl <- ml_cov_extract_gridmet(
      cube = cube,
      locations_sf = locations,
      vars = spec$vars,
      dt = spec$dt,
      res = spec$res,
      agg_space = spec$agg_space
    )

    cov_join <- cov_tbl
    if (join %in% c("plot_year", "site_year")) {
      cov_join <- cov_join |>
        dplyr::mutate(year = as.integer(format(date, "%Y"))) |>
        dplyr::select(-date)
    }

    if (join %in% c("site_date", "site_year")) {
      cov_join <- cov_join |>
        dplyr::mutate(plot_id = NA_character_)
    }

    n_before <- nrow(h$obs)
    h$obs <- dplyr::left_join(h$obs, cov_join, by = join_keys)

    cov_cols <- grep("^clim_", names(cov_join), value = TRUE)
    if (length(cov_cols) > 0) {
      na_rows <- apply(h$obs[, cov_cols, drop = FALSE], 1, function(row) all(is.na(row)))
      na_rate <- mean(na_rows)
      if (keep == "matched") {
        h$obs <- h$obs[!na_rows, , drop = FALSE]
      }
    } else {
      na_rate <- NA_real_
    }

    if (warn_join_loss && !is.na(na_rate) && na_rate > 0) {
      warning(sprintf("Covariate join introduced %s%% missing rows.", round(na_rate * 100, 1)))
    }

    n_after <- nrow(h$obs)
    cov_id <- paste0(spec$id, ":", paste(spec$vars, collapse = ","))

    h$covariates[[cov_id]] <- cov_tbl
    h$joins <- tibble::add_row(
      h$joins,
      covariate_id = cov_id,
      join = join,
      n_obs_before = n_before,
      n_obs_after = n_after,
      na_rate = na_rate,
      timestamp = Sys.time()
    )
  }

  h
}
