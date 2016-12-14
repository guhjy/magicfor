#' Clear the result
#'
#' @export
magic_free <- function() {
  calling_env <- parent.frame()
  if (!is.primitive(get("for", calling_env))) {
    remove(list = "for", envir = calling_env)
  }

  var_names <- ls(.result_env, all.names = TRUE)
  rm(list = var_names, envir = .result_env)
}
