# Quickstart

This is a minimal, runnable workflow to see `macabre` in action.

```r
library(macabre)

# See which sites are available
ml_list_sites()

# Run harmonization for the example site
h <- harmonize_material_legacies(sites = "EXAMPLE")

# Inspect the outputs
h$obs
h$systems
summary(h)
```

If you are authoring or testing a site, the quickcheck helper runs the same path with extra diagnostics:

```r
ml_quickcheck_site("EXAMPLE")
```
