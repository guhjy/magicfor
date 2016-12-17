#' Print values
#'
#' @param ... values
#' @param envir environment
#'
#' @export
put <- function (..., envir = parent.frame()) {
  vars <- substitute(list(...))
  var_names <- get_arg_names(vars[-1])
  values <- eval(vars, envir = envir)
  message(paste(sprintf("%s: %s", var_names, values),
                collapse = ", "))
  names(values) <- var_names
  invisible(values)
}
