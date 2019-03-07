#' salsa
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .env TODO
#'
#' @export
salsa <- function(.tbl, ..., .env = caller_env()) {
  # evaluate all the formulas in each group
  c(ptypes, steps, rows) %<-% ballet(.tbl, ..., .env = .env)

  # check all results are length 1
  check_size <- function(result, group_size) {
    assert_that(vec_size(result) == group_size)
  }
  walk2(steps, rows, ~walk(.x, check_size, group_size = length(.y)))

  # transpose and combine
  results <- map2(ptypes, seq_along(ptypes), ~vec_c(!!!map(steps, .y), .ptype = .x))

  # structure results as a tibble
  as_tibble(results)
}

#' chacha
#'
#' @param .tbl TODO
#'
#' @export
chacha <- function(.tbl) {
  UseMethod("chacha")
}

#' @export
chacha.data.frame <- function(.tbl) {
  .tbl
}

#' @export
chacha.grouped_df <- function(.tbl) {
  rows <- group_rows(.tbl)

  sizes <- lengths(rows)
  starts <- 1L + c(0L, cumsum(head(sizes, -1L)))
  ends   <- cumsum(head(sizes))

  new_grouped_df(
    vec_slice(.tbl, flatten_int(rows)),
    vec_cbind(group_keys(.tbl), tibble(.rows := map2(starts, ends, seq2))),
    class = "dance_grouped_df"
  )
}

#' @export
chacha.dance_grouped_df <- function(.tbl) {
  .tbl
}

#' samba
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .env TODO
#'
#' @export
samba <- function(.tbl, ..., .env = caller_env()) {
  vec_cbind(chacha(.tbl), salsa(.tbl, ..., .env = .env))
}

#' madison
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .name TODO
#' @param .env TODO
#'
#' @export
madison <- function(.tbl, ..., .name = "data", .env = caller_env()) {
  vec_cbind(chacha(.tbl), tibble(!!.name := salsa(.tbl, ..., .env = .env)))
}


