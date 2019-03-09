#' choreography
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .formulas TODO
#' @param .env TODO
#'
#' @export
choreography <- function(.tbl, ..., .formulas = list2(...), .env = caller_env()) {
  args <- tbl_slicer_args(.tbl)
  body <- expr(list(!!!map(.formulas, f_rhs)))
  structure(rlang::new_function(args, body, env = .env), class = "choreography")
}

#' @export
print.choreography <- function(x, ...) {
  expr_print(unclass(x))
  invisible(x)
}
