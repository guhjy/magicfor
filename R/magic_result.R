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
  res <- .result_env$result
  if(length(res) == 1) {
    unlist(res[[1]])
  } else {
    Map(unlist, .result_env$result)
  }
}

#' Get Magic Result as data.frame
#'
#' @export
magic_result_as_dataframe <- function() {
  data.frame(Map(I, .result_env$result))
}
