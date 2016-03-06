#' Magic for() convert to apply
#'
#' @export
magic_for_apply <- function() {
  rm(list=ls(.result_env, all.names = TRUE), envir = .result_env)
  calling_env <- parent.frame()
  my_for <- function(var, seq, call) {
    rm("for", envir = calling_env)

    var <- substitute(var)
    var_name <- as.character(var)
    if(var_name == ".result") stop(sprintf("Connot use the variable name '%s'.", as.character(var)))
    if(object.size(seq) < 1 * 1000 * 1000) {
      .result_env$input_name <- var_name
      .result_env$input <- seq
    }
    call <- substitute(call)

    last_print_position <- Position(function(x) x[[1]] == "print", call, right = TRUE)
    last_print <- call[[last_print_position]]
    call[[last_print_position]] <- base::call("<-", quote(.result), last_print[[-1]])
    call <- as.call(append(as.list(call), quote(.result), after = length(call)))

    result_var_name <- make.names(gsub("\\s+", "", paste(deparse(last_print[[-1]]), collapse="")))

    f <- function() {}
    formals(f) <- eval(parse(text = sprintf("alist(%s=)", as.character(var))))
    body(f) <- call
    environment(f) <- parent.frame()

    .result_env$result <- list(lapply(seq, f))
    names(.result_env$result) <- result_var_name
    invisible(.result_env$result)
  }
  assign("for", my_for, envir = calling_env)
  invisible(.result_env)
}
