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
  text <- if(is.atomic(.result_env$input[[1]])) {
    sprintf("data.frame(%s = unlist(.result_env$input), stringsAsFactors = FALSE)", deparse(.result_env$input_name))
  } else {
    sprintf("data.frame(%s = I(.result_env$input), stringsAsFactors = FALSE)", deparse(.result_env$input_name))
  }
  df_input <- eval(parse(text = text))
  # df_result <- data.frame(Map(I, .result_env$result))
  df_result <- data.frame(Map(function(res) if(is.atomic(res[[1]])) unlist(res) else I(res), .result_env$result), stringsAsFactors = FALSE)
  cbind(df_input, df_result)
}
