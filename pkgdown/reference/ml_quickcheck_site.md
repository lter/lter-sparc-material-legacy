# Quick diagnostics for a single site standardizer

Runs a site standardizer, prints a short summary, and stops on errors.
This should be the first check you run before opening a pull request.

## Usage

``` r
ml_quickcheck_site(site_id, inputs = list(), strict = TRUE)
```

## Arguments

- site_id:

  Site identifier registered in `ml_registry()`.

- inputs:

  Named list of arguments passed to the site standardizer.

- strict:

  Logical indicating whether to enforce strict validation.

## Value

An `ml_harmonized` object (invisibly).
