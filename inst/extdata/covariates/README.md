# Climate covariate fixtures

This folder documents the expected layout for local climate covariate files
used with gdalcubes. We do not store raster fixtures in the repository because
binary files are not supported by the PR workflow.

## Expected files

Provide local NetCDF or GeoTIFF files with dates embedded in the filename
(YYYY-MM-DD). For example:

- `gridmet_tmmx_2019-06-15.tif`
- `gridmet_tmmx_2020-06-15.tif`

## Usage

Use `ml_cube_from_local_netcdf()` to build a cube from your local files, then
run `ml_add_covariates()` to join covariates to the harmonized `obs` table.
