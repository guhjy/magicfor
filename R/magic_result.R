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
  text <- sprintf("data.frame(%s = I(.result_env$input), stringsAsFactors = FALSE)", .result_env$input_name)
  df_input <- eval(parse(text = text))
  df_result <- data.frame(Map(I, .result_env$result))
  cbind(df_input, df_result)
}
