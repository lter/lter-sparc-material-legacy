#' Say hello to the material legacy project
#'
#' @param name A character string with a name to greet.
#'
#' @return A character string with a friendly greeting.
#' @export
#'
#' @examples
#' hello_material_legacy("LTER")
hello_material_legacy <- function(name = "LTER") {
  paste("Hello", name, "from the Material Legacy project!")
}
