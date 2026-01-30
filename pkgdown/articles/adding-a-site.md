# Adding a site to the harmonization workflow

## What this does

This vignette explains how to add a site standardizer and run
harmonization. It focuses on the canonical tables (`obs` and `systems`)
and the steps a site contributor should follow.

## What you need

- Raw data for your site
- A site identifier (uppercase letters, numbers, underscores)
- The template file in `R/sites/site_TEMPLATE.R`

## Step-by-step

1.  Copy the template and rename it:

        R/sites/site_TEMPLATE.R -> R/sites/site_NEWSITE.R

2.  Edit `standardize_NEWSITE()` to read raw data and build `obs` and
    `systems`.

3.  Register the site in `ml_registry()`.

4.  Run harmonization for your site:

    ``` r
    harmonize_material_legacies(
      sites = "NEWSITE",
      inputs = list(NEWSITE = list(path = "path/to/raw"))
    )
    ```

## Common mistakes

- **Missing columns**: the canonical tables must include every required
  column.
- **Wrong factor levels**: use `ml_vocab()` to see allowed values.
- **Date/year mismatch**: `date` must be a `Date` and `year` must be
  integer.
- **System ID mismatch**: every `obs$system_id` must exist in
  `systems$system_id`.

## Real example: HFR

The package includes a small HFR fixture for demonstration.

``` r
harmonize_material_legacies(
  sites = "HFR",
  inputs = list(HFR = list(use_fixture = TRUE))
)
```

To use local data instead, point to your raw-data folder:

``` r
harmonize_material_legacies(
  sites = "HFR",
  inputs = list(HFR = list(path = "path/to/hfr/raw"))
)
```
