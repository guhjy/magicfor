#' Check whether for() is magicalized or not
#'
#' @param envir environment
#'
#' @return TRUE if for() is magicalized.
#'
#' @export
is_magicalized <- function(envir = parent.frame()) {
  !is.primitive(get("for", envir = envir))
}
