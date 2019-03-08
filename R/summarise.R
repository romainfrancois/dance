
#' waltz
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .env TODO
#'
#' @export
waltz <- function(.tbl, ..., .env = caller_env()) {
  # evaluate all the formulas in each group
  c(ptypes, steps, .) %<-% ballet(.tbl, ..., .env = .env)

  # check all results are length 1
  walk(steps, ~walk(.x, ~assert_that(vec_size(.x) == 1L)))

  # transpose, combine
  results <- map2(ptypes, seq_along(ptypes), ~vec_c(!!!map(steps, .y), .ptype = .x))

  as_tibble_splice(results)
}

#' polka
#'
#' @param .tbl TODO
#' @export
polka <- function(.tbl) {
  groups <- head(groups(.tbl), -1L)

  .tbl <- .tbl %>%
    group_keys() %>%
    group_by(!!!groups)

  if (is_grouped_df(.tbl) && !inherits(.tbl, "dance_grouped_df")) {
    class(.tbl) <- c("dance_grouped_df", class(.tbl))
  }
  .tbl
}

#' tango
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .env TODO
#'
#' @export
tango <- function(.tbl, ..., .env = caller_env()) {
  vec_cbind(polka(.tbl), waltz(.tbl, ..., .env = .env))
}

#' charleston
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .name TODO
#' @param .env TODO
#' @export
charleston <- function(.tbl, ..., .name = "data", .env = caller_env()) {
  vec_cbind(polka(.tbl), tibble(!!.name := waltz(.tbl, ..., .env = .env)))
}
