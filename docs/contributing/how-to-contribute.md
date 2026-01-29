# How to contribute

This guide explains how to contribute to the macabre R package and its
documentation. The repository hosts:

- **MkDocs narrative documentation** (the site you are reading now)
- **pkgdown API documentation** (generated from roxygen2)
- **An R package** that powers the data harmonization, analysis, and reporting
  workflows

## What this repo is

The `lter-sparc-material-legacy` repo is both a research package and a
documentation hub:

- **MkDocs (docs/)**: narrative documentation, science concepts, and guides.
- **pkgdown (pkgdown/)**: generated API reference from the package.
- **R package**: source code in `R/`, documentation in `man/`, tests in
  `tests/`.

## Where things go

- `R/`: R function implementations.
- `man/`: Generated `.Rd` files from roxygen2 (commit these).
- `tests/`: Testthat tests.
- `docs/`: MkDocs documentation (editable Markdown).
- `vignettes/`: Long-form package vignettes (if used).
- `.github/workflows/`: CI automation (R CMD check, pkgdown, MkDocs).

## Add a function

1. **Create or edit an R file** in `R/` (e.g., `R/harmonize.R`).
2. **Follow style expectations**:
   - Use clear, explicit inputs/outputs.
   - Validate inputs early (types, lengths, required columns).
   - Prefer explicit namespaces for non-base functions (e.g., `dplyr::mutate`).
3. **Keep functions focused** and unit-testable.

## Document a function (roxygen2)

Add a roxygen2 block directly above your function:

```r
#' Title of the function
#'
#' A short description of what the function does.
#'
#' @param data A data.frame with required columns.
#' @param method A character string indicating the method to use.
#' @return A data.frame with harmonized results.
#' @export
my_function <- function(data, method = "default") {
  # ...
}
```

**Tips**

- Use `@export` for public functions; omit for internal helpers.
- Add `@examples` where reasonable (use `\dontrun{}` for long-running examples).
- Run documentation generation:

```r
devtools::document()
```

Commit the updated `NAMESPACE` and `man/*.Rd` files.

## Add tests (testthat)

1. Create a test file under `tests/testthat/`, e.g. `tests/testthat/test-harmonize.R`.
2. Cover:
   - **Happy path** outputs.
   - **Bad inputs** (missing columns, invalid types).
   - **Edge cases** (empty data, unusual values).
3. Run targeted tests:

```r
testthat::test_file("tests/testthat/test-harmonize.R")
```

Or run the full suite:

```r
devtools::test()
```

## Run local checks

Before opening a PR, run:

```r
devtools::check()
```

Read the output carefully:

- **ERROR**: must be fixed before merge.
- **WARNING**: investigate and fix unless explicitly justified.
- **NOTE**: review and confirm it is acceptable.

## CI debugging guide (GitHub Actions)

When a workflow fails:

1. Open the **Actions** tab in GitHub.
2. Click the failed workflow run.
3. Expand the job with the red ❌.
4. Read the step logs near the failure.

Common failures and fixes:

- **Missing docs / roxygen2**:
  - Run `devtools::document()` locally.
  - Commit updated `NAMESPACE` and `man/*.Rd`.
- **Missing imports / namespace issues**:
  - Add packages to `DESCRIPTION` (`Imports`/`Suggests`).
  - Use explicit namespaces in code.
- **Test failures**:
  - Make tests deterministic (set seeds).
  - Avoid OS-specific paths; use `tempdir()` or `withr::local_tempdir()`.
  - Avoid external calls or guard them with `skip_if_offline()`.
  - Be explicit about timezones and locale.
- **pkgdown build failures**:
  - Long-running examples should be wrapped in `\dontrun{}`.
  - Ensure all exported functions have complete roxygen2 docs.
- **MkDocs link check failures**:
  - Ensure moved files have updated relative links.
  - Prefer site-root links for pkgdown (`/lter-sparc-material-legacy/pkgdown/`).

## PR expectations

Reviewers will look for:

- A clear purpose and description of changes.
- Updated documentation for user-facing behavior.
- Tests for new/changed functionality.
- Passing local checks (or a clear explanation of any known limitations).

Minimum acceptable PR contents:

- Code change + documentation update.
- Tests for new logic or a clear justification for why tests are unnecessary.
- Successful `devtools::check()` or explanation of any unavoidable issues.
