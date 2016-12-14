#' Magicalize for()
#'
#' @param func a name.
#' @param progress logical.
#' @param test logical or a number.
#' @param max_object_size a number. default 1 MB.
#'
#' @importFrom utils object.size setTxtProgressBar txtProgressBar
#'
#' @export
magic_for <- function(func = put, progress = FALSE, test = FALSE, max_object_size = 1 * MB) {
  magic_free()
  calling_env <- parent.frame()
  func <- substitute(func)

  my_for <- function(var, seq, call) {
    remove_myself_from_calling_env(calling_env)

    # Preprocess --------------------------------------------------------------
    var <- substitute(var)
    var_name <- as.character(var)
    check_reserved(var_name)

    call <- substitute(call)
    if (main_func_of(call) != "{") {
      call <- base::call("{", call)
    }

    if (test > 0) {
      if (identical(test, TRUE)) test <- 2
      seq <- seq[seq_len(test)]
    }

    if (object.size(seq) < max_object_size) {
      .result_env$input_name <- var_name
      .result_env$input <- seq
    }

    # Transform `func` to assign statements in the Body of for() --------------
    result_var_names <- c()
    call[-1] <- lapply(call[-1], function(statement) {
      if (main_func_of(statement) == func) {
        arg_names <- names(statement[-1])
        if (is.null(arg_names) || length(arg_names) == 1) {
          statement_var_name <- to_var_name(statement)
          result_var_names <<- c(result_var_names, statement_var_name)
          substitute(.result[[var_name]][[.i]] <- calc, list(var_name = statement_var_name, calc = statement[[-1]]))
        } else {
          statement[-1] <- mapply(function(statement_var_name, s) {
            if (statement_var_name == "") statement_var_name <- make.names(gsub("\\s+", "", paste(deparse(s), collapse="")))
            result_var_names <<- c(result_var_names, statement_var_name)
            substitute(.result[[var_name]][[.i]] <- calc, list(var_name = statement_var_name, calc = s))
          }, arg_names, statement[-1])
          do.call(base::call, c(name = "{", as.list(statement[-1])), quote = TRUE)
        }
      } else if (main_func_of(statement) == "if") {
        cond <- statement[[2]]
        statement <- statement[[3]]
        arg_names <- names(statement[-1])
        if (is.null(arg_names) || length(arg_names) == 1) {
          statement_var_name <- to_var_name(statement)
          result_var_names <<- c(result_var_names, statement_var_name)
          substitute(.result[[var_name]][[.i]] <- ifelse (cond, calc, NA),
                     list(var_name = statement_var_name, cond = cond, calc = statement[[-1]]))
        } else {
          statement[-1] <- mapply(function(statement_var_name, s) {
            result_var_names <<- c(result_var_names, statement_var_name)
            substitute(.result[[var_name]][[.i]] <- ifelse (cond, calc, NA),
                       list(var_name = statement_var_name, cond = cond, calc = s))
          }, arg_names, statement[-1])
          do.call(base::call, c(name = "{", as.list(statement[-1])), quote = TRUE)
        }
      } else {
        statement
      }
    })
    result_var_names <- unique(result_var_names)

    call <- as.call(append(as.list(call), quote(.i <- .i + 1), after = 1))

    if (progress) {
      call <- base::call("{", call, quote(setTxtProgressBar(progress_bar, .i)))
      body <-
        base::call("{",
                   substitute(.result <- vector("list", n), list(n = length(result_var_names))),
                   substitute(for (i in seq_along(.result)) .result[[i]] <- vector("list", n), list(n = length(seq))),
                   substitute(names(.result) <- result_var_names, list(result_var_names = result_var_names)),
                   quote(.i <- 0),
                   substitute(progress_bar <- txtProgressBar(0, max, style = 3), list(max = length(seq))),
                   base::call("for", var, seq, call),
                   quote(assign("result", .result, .result_env))
        )
    } else {
      body <-
        base::call("{",
                   substitute(.result <- vector("list", n), list(n = length(result_var_names))),
                   substitute(for (i in seq_along(.result)) .result[[i]] <- vector("list", n), list(n = length(seq))),
                   substitute(names(.result) <- result_var_names, list(result_var_names = result_var_names)),
                   quote(.i <- 0),
                   base::call("for", var, seq, call),
                   quote(assign("result", .result, .result_env))
        )
    }

    f <- function() {}
    formals(f) <- alist(.result_env=)
    body(f) <- body
    environment(f) <- parent.frame()

    f(.result_env)
    .result_env$my_for <- f
    invisible(.result_env$result)
  }
  assign("for", my_for, envir = calling_env)
  invisible(.result_env)
}

reserved_names <- c(".i", ".result", ".result_env")

check_reserved <- function(var_name) {
  if(var_name %in% reserved_names){
    stop(sprintf("Connot use the variable name '%s'.", var_name))
  }
}

remove_myself_from_calling_env <- function(calling_env) {
  rm("for", envir = calling_env)
}

MB <- 1000 * 1000

main_func_of <- function(call) {
  call[[1]]
}

to_var_name <- function(statement) {
  names <- names(statement[-1])
  if (is.null(names)) {
    names <- make.names(gsub("\\s+", "", paste(deparse(statement[[-1]]), collapse="")))
  }
  names
}

#' Print values
#'
#' @param ... values
#'
#' @export
put <- function (...) {
  vars <- substitute(list(...))
  var_names <- names(vars)
  if (is.null(var_names)) {
    var_names <- lapply(vars[-1], function(var) {
      gsub("\\s+", "", paste(deparse(var), collapse=""))
    })
  } else {
    var_names <- mapply(function(name, var) {
      if (name == "") {
        gsub("\\s+", "", paste(deparse(var), collapse=""))
      } else {
        name
      }
    }, var_names[-1], vars[-1])
  }
  message(paste(sprintf("%s: %s", var_names, eval(vars)), collapse = ", "))
}
