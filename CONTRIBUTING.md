# Contributing to macabre

Thank you for your interest in contributing. This project welcomes site
contributors and collaborators.

This repository includes:
- The R package (code, tests, and vignettes)
- A separate MkDocs website in the top-level `docs/` directory

Please do not edit `docs/` or `mkdocs.yml` when you are working on the R package.

## Adding or updating a site

If you are a site contributor, you only need to touch your site standardizer
and the registry that lists available sites.

Start by creating a new site standardizer file:

```r
ml_new_site_file("NEWSITE")
```

Then:
1. Edit `R/sites/site_NEWSITE.R` to read your raw data and build the canonical
   tables (`obs` and `systems`).
2. Register your site in `ml_registry()`.
3. Run a quick diagnostic check:

```r
ml_quickcheck_site("NEWSITE", inputs = list(path = "path/to/raw"))
```

4. Run tests and open a pull request.

## Core package development (maintainers only)

Core changes include the harmonizer, schema, and covariate tools. These files
should only be changed by maintainers or by request in an issue. If you are not
sure, please open an issue first.

## If something goes wrong

Validation errors are expected while you are building a site standardizer. The
error messages are meant to be read literally. Fix the issue in your site
standardizer rather than trying to bypass validation.

If you are stuck, open an issue and include the error message and a short
summary of your data.
