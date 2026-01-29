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
