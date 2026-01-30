#' Create a gdalcubes cube from local NetCDF or GeoTIFF files
#'
#' @param files Character vector of local NetCDF/GeoTIFF files.
#' @param var_names Optional vector of variable names, one per file or a single
#'   value recycled across files.
#' @param view Optional gdalcubes cube view.
#' @param dt Temporal resolution (ISO8601 duration string).
#' @param res Spatial resolution in degrees.
#' @param srs Spatial reference system (e.g., "EPSG:4326").
#'
#' @return A gdalcubes raster_cube.
#' @export
ml_cube_from_local_netcdf <- function(
  files,
  var_names = NULL,
  view = NULL,
  dt = "P1D",
  res = c(0.04, 0.04),
  srs = "EPSG:4326"
) {
  if (!requireNamespace("gdalcubes", quietly = TRUE)) {
    stop("gdalcubes is required to build cubes.", call. = FALSE)
  }
  if (length(files) == 0) {
    stop("files must include at least one file path.", call. = FALSE)
  }

  format <- if (all(grepl("\\.nc$", files, ignore.case = TRUE))) {
    "NetCDF"
  } else if (all(grepl("\\.tif(f)?$", files, ignore.case = TRUE))) {
    "GTiff"
  } else {
    stop("files must be all NetCDF or all GeoTIFF.", call. = FALSE)
  }

  dates <- regmatches(files, regexpr("\\d{4}-\\d{2}-\\d{2}", files))
  if (any(dates == "")) {
    stop("file names must contain a YYYY-MM-DD date string.", call. = FALSE)
  }

  if (is.null(var_names)) {
    var_names <- rep("var", length(files))
  } else if (length(var_names) == 1) {
    var_names <- rep(var_names, length(files))
  } else if (length(var_names) != length(files)) {
    stop("var_names must be length 1 or match length of files.", call. = FALSE)
  }

  collection <- gdalcubes::create_image_collection(
    files = files,
    format = format,
    datetime = "\\d{4}-\\d{2}-\\d{2}"
  )

  if (is.null(view)) {
    view <- gdalcubes::cube_view(
      collection,
      srs = srs,
      dx = res[1],
      dy = res[2],
      dt = dt
    )
  }

  cube <- gdalcubes::raster_cube(collection, view)
  cube
}
