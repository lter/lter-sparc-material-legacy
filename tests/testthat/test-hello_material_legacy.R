test_that("hello_material_legacy returns a greeting", {
  expect_match(hello_material_legacy("Team"), "Hello Team")
})
