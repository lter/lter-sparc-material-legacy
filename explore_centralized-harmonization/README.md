# Centralized Harmonization

Some groups appreciate a centralized approach to harmonization that uses the `standardize` function in the `ltertools` R package--see [the vignette](https://lter.github.io/ltertools/articles/ltertools.html#harmonization) for more details. The scripts in this folder and its subfolder(s) showcase what that workflow could look like for this group.

## Script Explanations

- `000_drive-download.R` -- Create needed folders and download needed inputs for scripts from group's Google Drive
    - Note you need to be in this group to have access to that Shared Drive!
- `01_harmonize.R` -- Standardize column names across input datasets and produce a single harmonized output
- `02_wrangle.R` -- Perform per-analysis wrangling (e.g., quality control, filtering, response summarization, etc.)
- `03_calc-effect-size.R` -- Fit relevant models, and extract effect sizes as well as model predictions 
- `999_drive-upload.R` -- Upload products of any/all preceding scripts to group's Google Drive
    - Note you need to be in this group to have access to that Drive!


