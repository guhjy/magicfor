#' Magicalize for()
#'
#' @export
magic_for <- function() {
  rm(list=ls(.result_env, all.names = TRUE), envir = .result_env)
  calling_env <- parent.frame()
  my_for <- function(var, seq, call) {
    rm("for", envir = calling_env)

    var <- substitute(var)
    .result_env$input_name <- var
    .result_env$input <- seq
    call <- substitute(call)

    if(call[[1]] != "{") {
      call <- base::call("{", call)
    }
    result_var_names <- c()
    call[-1] <- lapply(call[-1], function(x) {
      if(x[[1]] == "print") {
        var_name <- make.names(gsub("\\s+", "", paste(deparse(x[[-1]]), collapse="")))
        result_var_names <<- c(result_var_names, var_name)
        base::as.call(c(quote(result$add_value), var_name, x[[-1]]))
      } else {
        x
      }
    })

    call <- as.call(append(as.list(call), quote(result$increment_position()), after = 1))

    body <-
      base::call("{",
                 base::call("for", var, seq, call),
                 quote(assign("result", result$get_result(), result_env))
      )

    f <- function() {}
    formals(f) <- alist(result=, result_env=)
    body(f) <- body
    environment(f) <- parent.frame()

    result <- ForResults$new(result_var_names, length(seq))
    f(result, .result_env)
  }
  assign("for", my_for, envir = calling_env)
  invisible(.result_env)
}
