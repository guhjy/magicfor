.onLoad <- function(libname, pkgname) {
  assign(".result_env", new.env(), envir = asNamespace(pkgname))
}
