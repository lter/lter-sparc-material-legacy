# macabre

macabre is an R package and analysis repository for the LTER SPARC
synthesis project on **ecological legacies of dead foundation species**
across marine and terrestrial ecosystems.

## Package rename (important)

This project was formerly distributed under the package name
`lterSparcMaterialLegacy`. The package has been renamed to `macabre` to
provide a short, memorable name for collaborators. If you have the old
package installed locally, remove it and reinstall `macabre`.

## Purpose

`macabre` provides shared utilities and workflows for analyzing material
legacy effects in LTER SPARC projects. It is designed to make
collaboration on datasets, analyses, and reporting consistent across the
community.

## Project status

- **Package name:** `macabre`.
- **Current purpose:** infrastructure plus early utilities that support
  data harmonization, documentation, and reproducible analysis.
- **Expected growth:** functions and datasets will expand as the project
  moves from exploratory work to cross-site synthesis and
  publication-ready outputs.

For the broader project overview and public-facing updates, visit the
[project website](https://lter.github.io/macabre/).

## How to use this package (for now)

- Install from GitHub with `pak::pak("lter/macabre")`.
- Load the package with
  [`library(macabre)`](https://lter.github.io/macabre/).
- Expect a small, evolving set of helper functions focused on
  infrastructure; interfaces may change as the scientific workflow
  matures.

## Installation

You can install the development version from GitHub:

``` r
# install.packages("pak")
pak::pak("lter/macabre")
```

## Website

Package documentation is published automatically as a pkgdown site. If
the website looks out of date or fails to update, check the GitHub
Actions logs. The `gh-pages` branch is generated output—do not edit it
by hand.

## Quick example

``` r
library(macabre)

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

See [CONTRIBUTING.md](https://lter.github.io/macabre/CONTRIBUTING.md)
for the full contributor guide.
