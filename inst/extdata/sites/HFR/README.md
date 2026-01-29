# HFR fixture (Harvard Forest)

This directory contains a minimal raw-data subset used for testing the HFR
standardizer. The original source dataset is not stored in this repository, so
this fixture is a tiny, representative sample created solely for package tests
and documentation examples.

## Files

- `hfr_obs_raw.csv`: observation-level raw inputs.
- `hfr_systems_raw.csv`: site-level system metadata.

## Expected columns

### hfr_obs_raw.csv

- `plot_id`: plot identifier
- `date`: observation date (YYYY-MM-DD)
- `legacy_volume_m3`: deadwood volume (numeric)
- `response_biomass_g`: growth response (numeric)
- `design`: study design (observational/experimental)

### hfr_systems_raw.csv

- `ecosystem_type`: marine/terrestrial
- `ecosystem_subtype`: free-text subtype
- `foundation_species`: dominant species
- `design`: study design (observational/experimental)
- `data_years_start`: integer year
- `data_years_end`: integer year
- `mechanism_class`: resource/structural/mixed/unknown
- `mechanism_notes`: free-text notes

## Transformations

The standardizer maps raw columns into the harmonization schema:

- `legacy_volume_m3` -> `legacy_value` (metric = `volume`, unit = `m3`)
- `response_biomass_g` -> `response_value` (metric = `biomass`, unit = `g`)
- `legacy_type` is set to `deadwood`
- `response_type` is set to `growth`
- `system_id` is constructed as `HFR__deadwood__growth__01`
