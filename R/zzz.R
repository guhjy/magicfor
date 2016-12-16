.onLoad <- function(libname, pkgname) {
  assign(".result_env", new.env(parent = emptyenv()), envir = asNamespace(pkgname))
}

.onUnload <- function(libpath) {
  magic_free()
}
