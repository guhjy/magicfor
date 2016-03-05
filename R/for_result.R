ForResult <-
  R6::R6Class("ForResult",
              private = list(
                result = NULL,
                position = 0
              ),
              public = list(
                initialize = function(length) {
                  private$result <- vector("list", length)
                },
                increment_position = function() {
                  private$position <- private$position + 1
                },
                add_value = function(value) {
                  private$result[[private$position]] <- value
                },
                get_result = function() {
                  private$result
                }
              )
  )

ForResults <-
  R6::R6Class("ForResults",
              private = list(
                results = NULL,
                length = NULL
              ),
              public = list(
                initialize = function(var_names, length) {
                  private$results <- replicate(length(var_names), ForResult$new(length))
                  names(private$results) <- var_names
                  private$length <- length
                },
                increment_position = function() {
                  for(res in private$results) res$increment_position()
                },
                add_value = function(var_name, value) {
                  private$results[[var_name]]$add_value(value)
                },
                get_result = function() {
                  lapply(private$results, function(res) res$get_result())
                }
              )
  )
