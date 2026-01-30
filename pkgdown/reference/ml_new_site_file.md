# Create a new site standardizer file

Creates a new site standardizer file from the template in `R/sites/`.
This is for site contributors. The function does not register the site.

## Usage

``` r
ml_new_site_file(site_id, path = "R/sites", open = FALSE)
```

## Arguments

- site_id:

  Site identifier (uppercase letters, numbers, underscores).

- path:

  Directory where the new site file should be created.

- open:

  Logical; if TRUE, prints the file path.

## Value

The path to the newly created file.
