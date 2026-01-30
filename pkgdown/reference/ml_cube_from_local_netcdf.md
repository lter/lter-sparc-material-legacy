# Create a gdalcubes cube from local files

Builds a gdalcubes image collection and raster cube from local NetCDF or
GeoTIFF files. This is a convenience helper for local data.

## Usage

``` r
ml_cube_from_local_netcdf(
  files,
  var_names = NULL,
  view = NULL,
  dt = "P1D",
  res = c(0.04, 0.04),
  srs = "EPSG:4326"
)
```

## Arguments

- files:

  Character vector of local NetCDF or GeoTIFF files.

- var_names:

  Optional variable names, length 1 or length of files.

- view:

  Optional gdalcubes cube view.

- dt:

  Temporal resolution (ISO8601 duration string).

- res:

  Spatial resolution in degrees.

- srs:

  Spatial reference system string.

## Value

A gdalcubes raster cube.
