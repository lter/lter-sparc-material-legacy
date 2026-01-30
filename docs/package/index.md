# macabre R package

## What it is

`macabre` is an R package for harmonizing material legacy data across LTER sites so it can be combined for synthesis work. It turns site-specific inputs into a common set of tables that are consistent enough for analysis and modeling.

## What problem it solves

Different sites store measurements in different formats. `macabre` runs site standardizers to map those raw tables into shared schemas, checks for common errors, and bundles the results so you can analyze across sites without rebuilding the same data-wrangling steps.

## What it produces

A typical run returns:

- A harmonized observations table (`obs`) with consistent column names and units.
- A systems table (`systems`) describing experimental or observational systems.
- Optional climate covariates that can be joined after harmonization.

## Who it is for

- Working group members who need a repeatable harmonization workflow.
- Site specialists who can contribute or review standardizers for their own data.

## Learn more

Developer and contributor details live in GitHub so the website stays user focused:

- Repository overview: <https://github.com/lter/lter-sparc-material-legacy>
- Contributor guide: <https://github.com/lter/lter-sparc-material-legacy/blob/main/CONTRIBUTING.md>
