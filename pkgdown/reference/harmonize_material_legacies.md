# Harmonize material legacy data across sites

Runs one or more site standardizers, checks that they match the
canonical \`obs\` and \`systems\` tables, and combines results into a
single object. A site standardizer reads one site’s raw data and returns
those two tables.

## Usage

``` r
harmonize_material_legacies(
  sites = NULL,
  registry = ml_registry(),
  inputs = NULL,
  strict = TRUE,
  continue_on_error = TRUE,
  quiet = FALSE,
  return_site_outputs = FALSE
)
```

## Arguments

- sites:

  Character vector of site identifiers to run. Defaults to all sites.

- registry:

  Named list of site standardizers keyed by site identifier.

- inputs:

  Named list of arguments passed to each site standardizer.

- strict:

  Logical indicating whether to enforce strict validation.

- continue_on_error:

  Logical indicating whether to continue after site errors.

- quiet:

  Logical indicating whether to suppress progress messages.

- return_site_outputs:

  Logical indicating whether to include per-site outputs.

## Value

An object of class `ml_harmonized` containing `obs`, `systems`,
`site_log`, `errors`, and a `timestamp`.

## Examples

``` r
harmonize_material_legacies(sites = "EXAMPLE", quiet = TRUE)
#> ml_harmonized object
#>   Sites: 1
#>   Observations: 1
#>   Systems: 1

harmonize_material_legacies(
  sites = "EXAMPLE",
  inputs = list(EXAMPLE = list(path = "data/raw/EXAMPLE")),
  quiet = TRUE
)
#> ml_harmonized object
#>   Sites: 1
#>   Observations: 1
#>   Systems: 1
```
