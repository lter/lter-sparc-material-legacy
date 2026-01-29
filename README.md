# lterSparcMaterialLegacy

<!-- badges: start -->
[![R-CMD-check](https://github.com/lter/lter-sparc-material-legacy/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lter/lter-sparc-material-legacy/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/lter/lter-sparc-material-legacy/branch/main/graph/badge.svg)](https://codecov.io/gh/lter/lter-sparc-material-legacy)
[![pkgdown](https://github.com/lter/lter-sparc-material-legacy/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/lter/lter-sparc-material-legacy/actions/workflows/pkgdown.yaml)
<!-- badges: end -->

## Purpose

`lterSparcMaterialLegacy` provides shared utilities and workflows for analyzing
material legacy effects in LTER SPARC projects. It is designed to make
collaboration on datasets, analyses, and reporting consistent across the
community.

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

- The pkgdown site is rebuilt automatically on merges to the default branch.
- The `gh-pages` branch is generated output; do not edit it by hand.
- If the site breaks, check the GitHub Actions logs for the `pkgdown` workflow.
- GitHub Pages should be configured to serve from the `gh-pages` branch (root).

## Contributing

- Run tests with `devtools::test()`.
- Run a full check with `devtools::check()` or `R CMD check --as-cran`.
- Update documentation with `devtools::document()`.
- Add NEWS entries for user-facing changes.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full contributor guide.
