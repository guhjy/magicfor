#' Magicalize for()
#'
#' @param func function name. The target function for magicalization.
#' @param progress logical. If TRUE, show progress bar.
#' @param test logical or a number. If TRUE or a number, limit iteration times to it.
#' @param silent logical. If TRUE, do not execute func. Usually, func is print something.
#' @param temporary logical. If TRUE, once run for(), free magicalization.
#' @param max_object_size a number. Prevent to store large iterator. Default to 1 MB.
#'
#' @importFrom utils object.size setTxtProgressBar txtProgressBar
#'
#' @export
magic_for <- function(func = put, progress = FALSE, test = FALSE, silent = FALSE,
                      temporary = FALSE, max_object_size = 1 * MB) {
  magic_free()
  calling_env <- parent.frame()
  func <- substitute(func)
  silent <- silent || progress

  my_for <- function(for_var_symbol, for_seq, for_body) {
    if (!silent || progress)
      message(sprintf("The loop is%s magicalized with %s().",
                      ifelse(temporary , " temporary", ""), as.character(func)))
    if (temporary) remove_myself_from_calling_env(calling_env)

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
    transformed_info <- transform_lines(for_body, func, silent)
    transformed_lines <- transformed_info$lines
    result_var_names <- transformed_info$names
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

transform_lines <- function(call, func, silent) {
  if (is.symbol(call)) {
    name <- get_arg_names(call)
    assign_line <- bquote(.result[[.(name)]][[.i]] <- .(call))
    list(lines = list(assign_line), assign = TRUE, names = name)
  } else if (main_func_of(call) == "{") {
    line_info_list <- lapply(call[-1], transform_lines, func, silent)
    lines <- unlist(lapply(line_info_list, function(info) info$lines))
    assign <- unlist(lapply(line_info_list, function(info) info$assign))
    names <- unlist(lapply(line_info_list, function(info) info$names))
    list(lines = lines, assign = assign, names = names)
  } else if(main_func_of(call) == "if") {
    line_info <- transform_lines(call[[3]], func, silent)
    if (length(call) == 3) {
      names <- line_info$names
      assign_lines <- line_info$lines[line_info$assign]
      else_lines <- lapply(assign_lines, function(line) {line[[3]] <- NA; line})
    } else if (length(call) == 4) {
      line_info_else <- transform_lines(call[[4]], func, silent)
      names <- c(line_info$names, line_info_else$names)
      else_lines <- line_info_else$lines
    } else {
      stop(sprintf("Wrong if statement: %s", call))
    }
    if_body <- do.call(base::call, c(name = "{", line_info$lines), quote = TRUE)
    else_body <- do.call(base::call, c(name = "{", else_lines), quote = TRUE)
    line <- base::call("if", call[[2]], if_body, else_body)
    list(lines = list(line), assign = FALSE, names = names)
  } else if (main_func_of(call) == func) {
    arg_names <- get_arg_names(call[-1])
    assign_lines <- to_assign_lines(arg_names, call[-1])
    assign <- rep(TRUE, length(assign_lines))
    if (silent) {
      list(lines = assign_lines, assign = assign, names = arg_names)
    } else {
      list(lines = c(assign_lines, call), assign = c(assign, FALSE), names = arg_names)
    }
  } else {
    list(lines = list(call), assign = FALSE, names = NULL)
  }
}

to_assign_lines <- function(arg_names, statements) {
  mapply(function(name, arg) {
    bquote(.result[[.(name)]][[.i]] <- .(arg))
  }, arg_names, statements)
}
