
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

  .tbl <- .tbl %>%
    group_keys() %>%
    group_by(!!!groups)

  if (is_grouped_df(.tbl) && !inherits(.tbl, "dance_grouped_df")) {
    class(.tbl) <- c("dance_grouped_df", class(.tbl))
  }
  .tbl
}

#' @export
tango <- function(.tbl, ..., .env = caller_env()) {
  vec_cbind(polka(.tbl), waltz(.tbl, ..., .env = .env))
}

#' @export
charleston <- function(.tbl, ..., .name = "data", .env = caller_env()) {
  vec_cbind(polka(.tbl), tibble(!!.name := waltz(.tbl, ..., .env = .env)))
}
