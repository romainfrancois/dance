
#' @export
waltz <- function(.tbl, ..., .env = caller_env()) {
  # evaluate all the formulas in each group
  c(ptypes, steps, .) %<-% ballet(.tbl, ..., .env = .env)

  # check all results are length 1
  walk(steps, ~walk(.x, ~assert_that(vec_size(.x) == 1L)))

  # transpose and combine
  results <- map2(ptypes, seq_along(ptypes), ~vec_c(!!!map(steps, .y), .ptype = .x))

  # structure results as a tibble
  as_tibble(results)
}

#' @export
polka <- function(.tbl) {
  groups <- head(groups(.tbl), -1L)

  .tbl %>%
    group_keys() %>%
    group_by(!!!groups)
}

#' @export
tango <- function(.tbl, ...) {
  vec_cbind(polka(.tbl), waltz(.tbl, ...))
}

