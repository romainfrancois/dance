
#' foxtrot
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .env TODO
#' @export
foxtrot <- function(.tbl, ..., .env = caller_env()) {
  # evaluate all the formulas in each group
  c(., steps, .) %<-% ballet(.tbl, ..., .env = .env)

  map(steps, ~as_tibble_splice(.))
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

#' jive
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .env TODO
#'
#' @export
jive <- function(.tbl, ..., .env = caller_env()) {
  chunks <- foxtrot(.tbl, ..., .env = .env)
  sizes  <- map_int(chunks, nrow)
  keys   <- group_keys(.tbl)
  gps    <- groups(.tbl)

  out <- vec_cbind(
    keys[rep(seq_len(nrow(keys)), sizes), ],
    vec_rbind(!!!chunks)
  )
  group_by(out, !!!gps)
}
