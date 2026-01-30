# Create a gridMET covariate specification

Creates a specification for gridMET-style covariates. This is a settings
object and does not run extraction by itself.

## Usage

``` r
ml_cov_gridmet_spec(
  vars = c("tmmx", "tmmn", "pr"),
  dt = "P1D",
  agg_time = NULL,
  agg_space = "mean",
  res = c(0.04, 0.04)
)
```

## Arguments

- vars:

  Character vector of gridMET variables.

- dt:

  Temporal resolution (ISO8601 duration string).

- agg_time:

  Optional temporal aggregation function.

- agg_space:

  Spatial aggregation function for polygons.

- res:

  Spatial resolution in degrees.

## Value

An object of class `ml_cov_spec`.
