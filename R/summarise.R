
#' @export
waltz <- function(.tbl, ..., .env = caller_env()) {
  set_tbl(.tbl)
  formulas <- list2(...)

  if(is.null(formulas)) {
    names(formulas) <- rep("", length(formulas))
  }
  assert_that(
    all(map_lgl(formulas, is_formula)),
    msg = "`...` should be a named list of formulas"
  )

  .rows <- group_rows(.tbl)
  n_groups <- length(.rows)

  # the right hand side of the formula give the type
  # empty gives NULL whih means guessing the type
  .ptypes <- map(formulas, ~eval_bare(f_lhs(.x), f_env(.x)))

  # for each group, apply the choreography derived from the formulas
  moves <- choreography(.tbl, .formulas = formulas, .env = .env)
  steps <- map(.rows, moves)

  # transpose and combine
  results <- map2(.ptypes, seq_along(.ptypes), ~vec_c(!!!map(steps, .y), .ptype = .x))

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

