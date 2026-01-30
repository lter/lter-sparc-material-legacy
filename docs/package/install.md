# Install macabre

## Prerequisites

- R (current stable release; R 4.3+ recommended)
- Rtools on Windows if you need to compile packages

## Install from GitHub (recommended)

`macabre` is developed in the `lter-sparc-material-legacy` repository. The most reliable way to install it is directly from GitHub.

```r
install.packages("pak")
pak::pak("lter/lter-sparc-material-legacy")
```

If `pak` fails due to dependency resolution on your system, fall back to `remotes`:

```r
install.packages("remotes")
remotes::install_github(
  "lter/lter-sparc-material-legacy",
  subdir = ".",
  build_vignettes = TRUE
)
```

For developer details, see the repository README and contributor guide:

- <https://github.com/lter/lter-sparc-material-legacy>
- <https://github.com/lter/lter-sparc-material-legacy/blob/main/CONTRIBUTING.md>
