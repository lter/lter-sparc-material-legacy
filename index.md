# lterSparcMaterialLegacy

## Purpose

`lterSparcMaterialLegacy` provides shared utilities and workflows for
analyzing material legacy effects in LTER SPARC projects. It is designed
to make collaboration on datasets, analyses, and reporting consistent
across the community.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("lter/lter-sparc-material-legacy")
```

## Quick example

``` r
library(lterSparcMaterialLegacy)

hello_material_legacy("LTER")
```

## pkgdown site

- The pkgdown site is rebuilt automatically on merges to the default
  branch.
- The `gh-pages` branch is generated output; do not edit it by hand.
- If the site breaks, check the GitHub Actions logs for the `pkgdown`
  workflow.
- GitHub Pages should be configured to serve from the `gh-pages` branch
  (root).

## Contributing

- Run tests with `devtools::test()`.
- Run a full check with `devtools::check()` or `R CMD check --as-cran`.
- Update documentation with `devtools::document()`.
- Add NEWS entries for user-facing changes.

See
[CONTRIBUTING.md](https://lter.github.io/lter-sparc-material-legacy/CONTRIBUTING.md)
for the full contributor guide.
