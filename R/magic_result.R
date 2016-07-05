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
  result <- .result_env$result
  if(exists("input", envir = .result_env)) {
    result <- c(list(.result_env$input), result)
    names(result)[1] <- .result_env$input_name
  }
  data.frame(Map(function(res) if(is.atomic(res[[1]])) unlist(res) else I(res), result), stringsAsFactors = FALSE)
}
