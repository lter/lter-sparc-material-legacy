# Join climate covariates onto harmonized data

Adds climate covariates to the harmonized observation table using a join
mode such as plot-date or site-year. This step does not modify site
standardizers.

## Usage

``` r
ml_add_covariates(
  h,
  covariates,
  locations,
  join = c("plot_date", "site_date", "plot_year", "site_year"),
  keep = "all",
  warn_join_loss = TRUE
)
```

## Arguments

- h:

  An `ml_harmonized` object.

- covariates:

  A covariate spec or list of specs.

- locations:

  An sf object with `site_id`, `plot_id`, and geometry.

- join:

  Join mode for covariates.

- keep:

  Whether to keep all rows or only matched rows.

- warn_join_loss:

  Warn if the join introduces missing values.

## Value

An updated `ml_harmonized` object with covariates and join logs.
