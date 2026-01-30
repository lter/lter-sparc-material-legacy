# Function index

This is a curated list of the exported `macabre` functions most users need. For full developer documentation, see the GitHub repository.

Repository: <https://github.com/lter/lter-sparc-material-legacy>

API reference (pkgdown): <https://lter.github.io/lter-sparc-material-legacy/pkgdown/>

## Harmonization

- `harmonize_material_legacies()` — run site standardizers, validate outputs, and return a harmonized object. [Developer docs in GitHub](https://github.com/lter/lter-sparc-material-legacy)
- `ml_list_sites()` — list available site IDs that can be harmonized. [Developer docs in GitHub](https://github.com/lter/lter-sparc-material-legacy)

## Site authoring helpers

- `ml_new_site_file()` — create a new site standardizer template file. [Developer docs in GitHub](https://github.com/lter/lter-sparc-material-legacy)
- `ml_quickcheck_site()` — run a fast diagnostics pass for a single site. [Developer docs in GitHub](https://github.com/lter/lter-sparc-material-legacy)

## Covariates

- `ml_add_covariates()` — join climate covariates to a harmonized object. [Developer docs in GitHub](https://github.com/lter/lter-sparc-material-legacy)
- `ml_cov_gridmet_spec()` — describe which GridMET variables to add. [Developer docs in GitHub](https://github.com/lter/lter-sparc-material-legacy)
- `ml_cube_from_local_netcdf()` — build a covariate cube from local NetCDF files. [Developer docs in GitHub](https://github.com/lter/lter-sparc-material-legacy)
