#' Magicalize for()
#'
#' @export
magic_for <- function() {
  rm(list=ls(.result_env, all.names = TRUE), envir = .result_env)
  calling_env <- parent.frame()
  my_for <- function(var, seq, call) {
    rm("for", envir = calling_env)

    var <- substitute(var)
    var_name <- as.character(var)
    if(var_name %in% c(".i", ".result", ".result_env")) stop(sprintf("Connot use the variable name '%s'.", as.character(var)))
    if(object.size(seq) < 1 * 1000 * 1000) {
      .result_env$input_name <- var_name
      .result_env$input <- seq
    }
    call <- substitute(call)

    if(call[[1]] != "{") {
      call <- base::call("{", call)
    }
    result_var_names <- c()
    call[-1] <- lapply(call[-1], function(x) {
      if(x[[1]] == "print") {
        var_name <- make.names(gsub("\\s+", "", paste(deparse(x[[-1]]), collapse="")))
        result_var_names <<- c(result_var_names, var_name)
        substitute(.result[[var_name]][[.i]] <- calc, list(var_name = var_name, calc = x[[-1]]))
      } else {
        x
      }
    })
    result_var_names <- unique(result_var_names)

    call <- as.call(append(as.list(call), quote(.i <- .i + 1), after = 1))

    body <-
      base::call("{",
                 substitute(.result <- vector("list", n), list(n = length(result_var_names))),
                 substitute(for(i in seq_along(.result)) .result[[i]] <- vector("list", n), list(n = length(seq))),
                 substitute(names(.result) <- result_var_names, list(result_var_names = result_var_names)),
                 quote(.i <- 0),
                 base::call("for", var, seq, call),
                 quote(assign("result", .result, .result_env))
      )

    f <- function() {}
    formals(f) <- alist(.result=, .result_env=)
    body(f) <- body
    environment(f) <- parent.frame()

    f(result, .result_env)
  }
  assign("for", my_for, envir = calling_env)
  invisible(.result_env)
}
