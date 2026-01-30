# Harmonization workflow

## How it works

Each site provides a site standardizer that maps its raw tables into the shared `macabre` schemas. `harmonize_material_legacies()` runs those standardizers, validates the results, and binds them into a single harmonized object.

## Run a subset of sites

```r
library(macabre)

h <- harmonize_material_legacies(sites = c("EXAMPLE", "HFR"))
```

## Pass inputs to a site

If a site needs a local file path or other inputs, pass them in a named list keyed by site ID:

```r
h <- harmonize_material_legacies(
  sites = "HFR",
  inputs = list(
    HFR = list(path = "path/to/raw/data")
  )
)
```

## Interpreting errors

Common validation errors include:

- **Type mismatch**: a column has the wrong data type.
- **Missing columns**: required fields are absent after the site standardizer runs.
- **System ID mismatch**: `obs` rows reference system IDs that are not present in `systems`.

### Troubleshooting

- Fix the site standardizer to align columns and types with the shared schema.
- Avoid bypassing validation; it keeps multi-site analyses consistent.
- If you are unsure how to fix a site standardizer, consult the contributor guide in GitHub.

Read more in the repo:

- <https://github.com/lter/lter-sparc-material-legacy/blob/main/CONTRIBUTING.md>
- <https://github.com/lter/lter-sparc-material-legacy>
