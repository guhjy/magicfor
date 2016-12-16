#' Magicalize for()
#'
#' @param func function name. The target function for magicalization.
#' @param progress logical. If TRUE, show progress bar.
#' @param test logical or a number. If TRUE or a number, limit iteration times to it.
#' @param silent logical. If TRUE, do not execute func. Usually, func is print something.
#' @param temp logical. If TRUE, once run for(), free magicalization.
#' @param max_object_size a number. Prevent to store large iterator. Default to 1 MB.
#'
#' @importFrom utils object.size setTxtProgressBar txtProgressBar
#'
#' @export
magic_for <- function(func = put, progress = FALSE, test = FALSE, silent = FALSE,
                      temp = FALSE, max_object_size = 1 * MB) {
  magic_free()
  calling_env <- parent.frame()
  func <- substitute(func)
  silent <- silent || progress
  # TODO ignore func == if

  my_for <- function(for_var_symbol, for_seq, for_body) {
    if (!silent || progress) message(sprintf("The loop is magicalized with %s().", as.character(func)))
    if (temp) remove_myself_from_calling_env(calling_env)

    # Preprocess --------------------------------------------------------------
    for_var_symbol <- substitute(for_var_symbol)
    for_var_name <- as.character(for_var_symbol)
    check_reserved(for_var_name)

    for_body <- substitute(for_body)
    if (main_func_of(for_body) != "{") {
      for_body <- call("{", for_body)
    }

    if (test > 0) {
      for_seq <- for_seq[seq_len(test)]
    }

    if (object.size(for_seq) < max_object_size) {
      .result_env$input_name <- for_var_name
      .result_env$input <- for_seq
    }

    # Transform func to assign statements in the Body of for() ----------------
    result_var_names <- c()

    transformed_lines <- lapply(for_body[-1], function(line) {
      if (is.symbol(line)) {
        name <- get_arg_names(line)
        result_var_names <<- c(result_var_names, name)
        assign_line <- bquote(.result[[.(name)]][[.i]] <- .(line))
        assign_line
      } else if (main_func_of(line) == "if") {
        cond <- line[[2]]
        if_body <- line[[3]]
        if (main_func_of(if_body) != "{") {
          if_body <- call("{", if_body)
        }
        assign_lines <- lapply(if_body[-1], function(line) {
          if (main_func_of(line) == func) {
            arg_names <- get_arg_names(line[-1])
            result_var_names <<- c(result_var_names, arg_names)
            mapply(function(name, statement) {
              bquote(.result[[.(name)]][[.i]] <- ifelse (.(cond), .(statement), NA))
            }, arg_names, line[-1])
          } else {
            line
          }
        })
        if (silent) {
          unlist(assign_lines)
        } else {
          c(unlist(assign_lines), line)
        }
      } else if (main_func_of(line) == func) {
        arg_names <- get_arg_names(line[-1])
        result_var_names <<- c(result_var_names, arg_names)
        assign_lines <- to_assign_lines(arg_names, line[-1])
        if (silent) {
          assign_lines
        } else {
          c(assign_lines, line)
        }
      } else {
        line
      }
    })
    transformed_lines <- unlist(transformed_lines)
    if (progress) {
      transformed_lines <- append(transformed_lines,
                                  quote(setTxtProgressBar(progress_bar, .i)))
    }
    transformed_lines <- append(transformed_lines, quote(.i <- .i + 1L))
    transformed_for_body <- do.call(call, c(name = "{", transformed_lines), quote = TRUE)
    result_var_names <- unique(result_var_names)

    # Constract body ----------------------------------------------------------
    ncol <- length(result_var_names)
    nrow <- length(for_seq)
    body_lines <- list(
      bquote(.result <- vector("list", .(ncol))),
      bquote(for (i in seq_along(.result)) .result[[i]] <- vector("list", .(nrow))),
      bquote(names(.result) <- .(result_var_names)),
      quote(.i <- 1L),
      call("for", for_var_symbol, for_seq, transformed_for_body),
      quote(assign("result", .result, .result_env))
    )
    if (progress) {
      body_lines <-
        append(body_lines,
               bquote(progress_bar <- txtProgressBar(0L, .(nrow), style = 3L)),
               after = 4)
    }
    body <- do.call(call, c(name = "{", body_lines))

    # Execute for() -----------------------------------------------------------
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
