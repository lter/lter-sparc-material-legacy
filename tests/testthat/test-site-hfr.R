test_that("standardize_HFR returns valid bundle", {
  bundle <- standardize_HFR(use_fixture = TRUE)
  schema <- ml_schema()

  cleaned <- ml_validate_site_bundle(bundle, schema)
  expect_true(all(c("obs", "systems") %in% names(cleaned)))
  expect_gt(nrow(cleaned$obs), 0)
  expect_gt(nrow(cleaned$systems), 0)

  expect_true(all(as.character(cleaned$obs$legacy_type) == "deadwood"))
  expect_true(all(as.character(cleaned$obs$response_type) == "growth"))
  expect_true(min(cleaned$obs$year) >= 2019)
})

test_that("harmonize_material_legacies works for HFR fixture", {
  result <- harmonize_material_legacies(
    sites = "HFR",
    inputs = list(HFR = list(use_fixture = TRUE)),
    quiet = TRUE
  )

  expect_s3_class(result, "ml_harmonized")
  expect_equal(nrow(result$errors), 0)
  expect_gt(nrow(result$obs), 0)
})
