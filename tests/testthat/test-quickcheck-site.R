test_that("ml_quickcheck_site returns ml_harmonized output", {
  result <- ml_quickcheck_site("EXAMPLE")

  expect_s3_class(result, "ml_harmonized")
  expect_true("site_outputs" %in% names(result))
  expect_true("EXAMPLE" %in% names(result$site_outputs))
  expect_equal(nrow(result$errors), 0)
})
