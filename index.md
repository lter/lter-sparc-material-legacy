# lterSparcMaterialLegacy

## Purpose

`lterSparcMaterialLegacy` provides shared utilities and workflows for
analyzing material legacy effects in LTER SPARC projects. It is designed
to make collaboration on datasets, analyses, and reporting consistent
across the community.

## Project status

- **Package name:** `lterSparcMaterialLegacy`.
- **Current purpose:** infrastructure plus early utilities that support
  data harmonization, documentation, and reproducible analysis.
- **Expected growth:** functions and datasets will expand as the project
  moves from exploratory work to cross-site synthesis and
  publication-ready outputs.

For the broader project overview and public-facing updates, visit the
[project website](https://lter.github.io/lter-sparc-material-legacy/).

## How to use this package (for now)

- Install from GitHub with
  `remotes::install_github("lter/lter-sparc-material-legacy")`.
- Load the package with
  [`library(lterSparcMaterialLegacy)`](https://github.com/lter/lter-sparc-material-legacy).
- Expect a small, evolving set of helper functions focused on
  infrastructure; interfaces may change as the scientific workflow
  matures.

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

## Notebooks and analyses

Exploratory notebooks and narrative analyses live in `project-notes/`.
They document decisions, prototypes, and analytical context, while
stable functions are promoted into the R package so they can be reused
across sites and workflows.

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
