
#' foxtrot
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .env TODO
#' @export
foxtrot <- function(.tbl, ..., .env = caller_env()) {
  # evaluate all the formulas in each group
  c(., steps, .) %<-% ballet(.tbl, ..., .env = .env)

  map(steps, as_tibble)
}

#' bachata
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .name TODO
#' @param .env TODO
#'
#' @export
bachata <- function(.tbl, ..., .name = "data", .env = caller_env()) {
  vec_cbind(polka(.tbl), !!.name := foxtrot(.tbl, ..., .env = .env))
}
