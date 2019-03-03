
#' @export
waltz <- function(.tbl, ..., .env = caller_env()) {
  # evaluate all the formulas in each group
  c(ptypes, steps, .) %<-% ballet(.tbl, ..., .env = .env)

  mappers <- map(ptypes, map_for_type)

  # transpose and combine
  results <- map2(mappers, seq_along(mappers), ~.x(steps, .y))

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
tango <- function(.tbl, ...) {
  vec_cbind(polka(.tbl), waltz(.tbl, ...))
}

