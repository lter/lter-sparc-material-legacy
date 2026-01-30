test_that("ml_new_site_file copies template and replaces placeholders", {
  tmp_dir <- file.path(tempdir(), "site-authoring")
  if (!dir.exists(tmp_dir)) {
    dir.create(tmp_dir, recursive = TRUE)
  }

  new_file <- ml_new_site_file("NEWSITE", path = tmp_dir)
  expect_true(file.exists(new_file))

  contents <- readLines(new_file, warn = FALSE)
  expect_true(any(grepl("standardize_NEWSITE", contents)))
  expect_false(any(grepl("<SITE>", contents, fixed = TRUE)))

  expect_error(
    ml_new_site_file("NEWSITE", path = tmp_dir),
    "already exists"
  )
})
