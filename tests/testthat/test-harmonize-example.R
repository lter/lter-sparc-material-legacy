test_that("harmonize_material_legacies works for EXAMPLE", {
  result <- harmonize_material_legacies(sites = "EXAMPLE", quiet = TRUE)

  expect_s3_class(result, "ml_harmonized")
  expect_gt(nrow(result$obs), 0)
  expect_gt(nrow(result$systems), 0)
  expect_equal(nrow(result$errors), 0)
})
