MB <- 1000 * 1000

reserved_names <- c(".i", ".result", ".result_env")

check_reserved <- function(var_name) {
  if(var_name %in% reserved_names){
    stop(sprintf("Connot use the variable name '%s'.", var_name))
  }
}

remove_myself_from_calling_env <- function(calling_env) {
  rm("for", envir = calling_env)
}

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

get_arg_names <- function(statements) {
  arg_names <- names(statements)
  if (is.null(arg_names)) {
    arg_names <- rep("", length(statements))
  }
  mapply(function(name, arg) {
    if (name == "") {
      gsub("\\s+", "", deparse(arg))
    } else {
      name
    }
  }, arg_names, statements)
}

to_assign_lines <- function(arg_names, statements) {
  mapply(function(name, arg) {
    bquote(.result[[.(name)]][[.i]] <- .(arg))
  }, arg_names, statements)
}

