#' Print values
#'
#' @param ... values
#' @param envir environment
#'
#' @export
put <- function (..., envir = parent.frame()) {
  vars <- substitute(list(...))
  var_names <- get_arg_names(vars[-1])
  message(paste(sprintf("%s: %s", var_names, eval(vars, envir = envir)), collapse = ", "))
}
