#' Get Magic Result
#'
#' @export
magic_result <- function() {
  .result_env$result
}

#' Get Magic Result as data.frame
#'
#' @export
magic_result_as_vector <- function() {
  Map(unlist, .result_env$result)
}

#' Get Magic Result as data.frame
#'
#' @export
magic_result_as_dataframe <- function() {
  data.frame(Map(unlist, .result_env$result))
}
