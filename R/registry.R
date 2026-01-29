ml_registry <- function() {
  list(
    EXAMPLE = standardize_EXAMPLE,
    HFR = standardize_HFR
  )
}

#' List available site standardizers
#'
#' Use this to see which site standardizers are currently available in the
#' package.
#'
#' @return A character vector of site identifiers.
#' @export
ml_list_sites <- function() {
  names(ml_registry())
}
