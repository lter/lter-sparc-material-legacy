test_that("hello_material_legacy returns a greeting", {
  expect_match(hello_material_legacy("Team"), "material", ignore.case = TRUE)
})
