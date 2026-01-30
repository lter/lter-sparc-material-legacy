# Covariates (climate)

## When covariates are added

Climate covariates are joined *after* harmonization. You first produce a harmonized object, then add covariates in a second step.

## Optional dependencies

Covariates rely on spatial packages that are not required for basic harmonization:

- `sf` for reading and working with spatial locations
- `gdalcubes` for working with gridded climate data

## Minimal example

```r
library(macabre)

h <- harmonize_material_legacies(sites = "EXAMPLE")

# Locations can come from a shapefile or any sf object
loc <- sf::st_read("path/to/plot_locations.gpkg")

cube <- ml_cube_from_local_netcdf(
  files = c("path/to/gridmet.nc"),
  var_names = "tmmx"
)

h2 <- ml_add_covariates(
  h,
  ml_cov_gridmet_spec(vars = c("tmmx", "pr")),
  locations = loc,
  join = "plot_date"
)
```

## Join modes (plain language)

- **plot_date**: join covariates for each plot on the exact observation date.
- **site_date**: join covariates for each site on the exact observation date.
- **plot_year**: join covariates for each plot by year (ignores day/month).
- **site_year**: join covariates for each site by year (ignores day/month).

Read more in the repo:

- <https://github.com/lter/lter-sparc-material-legacy>
