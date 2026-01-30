# Climate covariates (gridMET-style)

## What this does

This vignette shows how to add climate covariates after harmonization.
The covariate step is separate from site standardizers.

## What you need

- A harmonized object (from
  [`harmonize_material_legacies()`](https://lter.github.io/lter-sparc-material-legacy/pkgdown/reference/harmonize_material_legacies.md))
- A locations file with `site_id`, `plot_id`, and point or polygon
  geometry
- Local climate raster files (NetCDF or GeoTIFF) with dates in filenames

## Step-by-step

The code below is shown for reference. Run it locally after installing
the optional spatial packages.

``` r
h <- harmonize_material_legacies(sites = "HFR", inputs = list(HFR = list(use_fixture = TRUE)))
loc <- sf::st_read(system.file("extdata/locations/plots_points.geojson", package = "macabre"))

files <- list.files(
  "path/to/local/covariates",
  pattern = "gridmet_tmmx_.*\\.tif$",
  full.names = TRUE
)

cube <- ml_cube_from_local_netcdf(files, var_names = "tmmx")

spec <- ml_cov_gridmet_spec(vars = c("tmmx"))

h2 <- ml_add_covariates(
  h,
  covariates = list(list(spec = spec, cube = cube)),
  locations = loc,
  join = "plot_date"
)
```

## Common mistakes

- Missing `site_id` or `plot_id` columns in the locations file.
- Dates in the covariate files do not overlap the observation dates.
- Using site-level locations but choosing `plot_date` joins.
