#'waltz() takes a grouped tibble and a list of formulas and returns a tibble with: as many columns as supplied formulas,
#'one row per group. It does not prepend the grouping variables (see tango for that).
#' @param .tbl a grouped tibble
#' @param ... a list of formulas
#' @param .env ?? to do
#' @return a tibble with: as many columns as supplied formulas,
#'one row per group
#' @export
#'
#' @examples
#' g <- iris %>% group_by(Species)
#' g %>%
#' waltz(
#'  Sepal.Length = ~mean(Sepal.Length),
#'  Sepal.Width  = ~mean(Sepal.Width)
#')
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
