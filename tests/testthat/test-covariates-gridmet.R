test_that("ml_add_covariates joins gridmet covariates", {
  testthat::skip_if_not_installed("sf")
  testthat::skip_if_not_installed("gdalcubes")

  files <- list.files(
    system.file("extdata/covariates", package = "macabre"),
    pattern = "gridmet_tmmx_.*\\.tif$",
    full.names = TRUE
  )

  if (length(files) == 0) {
    testthat::skip("No local covariate fixtures available")
  }

  h <- harmonize_material_legacies(
    sites = "HFR",
    inputs = list(HFR = list(use_fixture = TRUE)),
    quiet = TRUE
  )

  loc_path <- system.file("extdata/locations/plots_points.geojson", package = "macabre")
  loc <- sf::st_read(loc_path, quiet = TRUE)

  cube <- ml_cube_from_local_netcdf(files, var_names = "tmmx")
  spec <- ml_cov_gridmet_spec(vars = "tmmx")

  h2 <- ml_add_covariates(
    h,
    covariates = list(list(spec = spec, cube = cube)),
    locations = loc,
    join = "plot_date"
  )

  expect_s3_class(h2, "ml_harmonized")
  expect_true("clim_tmmx" %in% names(h2$obs))
  expect_true(nrow(h2$joins) >= 1)
  expect_true(all(c("n_obs_before", "na_rate") %in% names(h2$joins)))
})
