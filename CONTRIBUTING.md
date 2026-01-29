# Contributing to lterSparcMaterialLegacy

Thanks for your interest in contributing! We welcome issues,
documentation improvements, and pull requests.

## Getting started

1.  Fork the repository and create your branch from `main`.
2.  Install development dependencies:

``` r
install.packages(c("devtools", "roxygen2", "testthat"))
```

3.  Run the tests:

``` r
devtools::test()
```

4.  Run a full check before opening a PR:

``` r
devtools::check()
```

## Documentation

- Update documentation with `devtools::document()` after changing
  exported functions.
- Re-render `README.Rmd` if you change the README:

``` r
rmarkdown::render("README.Rmd")
```

## Infrastructure-first development

This repository established cross-platform CI and documentation tooling
early so contributors can build on a stable foundation. Treat CI results
as guidance for improving reproducibility and code quality, even when a
check is advisory. As the package matures, maintainers may tighten
checks and make more items required.

See the project documentation for more detail on infrastructure and
reproducibility:
<https://lter.github.io/lter-sparc-material-legacy/development/>.

### Notebook → package promotion

- Exploratory work can live in notebooks or scripts while ideas are
  forming.
- Once code is stable and reusable, move it into `R/` with tests and
  documentation.
- Prefer small, well-documented functions that can be reused across
  analyses.

## Adding tests

- Add tests under `tests/testthat/`.
- Aim for clear, focused tests that cover new behavior.

## NEWS

Add a short entry to `NEWS.md` for user-facing changes.

## Contribution expectations

- Keep pull requests small and focused when possible.
- Link to an issue for larger changes.
- Provide a reproducible example (reprex) for bugs.

Thank you for helping make this project better!
