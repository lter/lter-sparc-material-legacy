test_that("ml_schema returns prototypes", {
  schema <- ml_schema()

  expect_true(is.list(schema))
  expect_true(all(c("obs_ptype", "systems_ptype") %in% names(schema)))

  expect_true(all(
    c(
      "site_id",
      "system_id",
      "plot_id",
      "date",
      "year",
      "design",
      "legacy_type",
      "legacy_metric",
      "legacy_value",
      "legacy_unit",
      "response_type",
      "response_metric",
      "response_value",
      "response_unit"
    ) %in% names(schema$obs_ptype)
  ))

  expect_true(all(
    c(
      "system_id",
      "site_id",
      "ecosystem_type",
      "ecosystem_subtype",
      "foundation_species",
      "legacy_type",
      "legacy_metric",
      "response_type",
      "response_metric",
      "design",
      "data_years_start",
      "data_years_end",
      "mechanism_class",
      "mechanism_notes"
    ) %in% names(schema$systems_ptype)
  ))
})
