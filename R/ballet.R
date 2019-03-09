#' ballet
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .env TODO
#'
#' @export
ballet <- function(.tbl, ..., .env = caller_env()) {
  set_tbl(.tbl)
  formulas <- list2(...)

  assert_that(
    all(map_lgl(formulas, is_formula)),
    msg = "`...` should be a list of formulas"
  )

  rows <- group_rows(.tbl)
  n_groups <- length(rows)

  # the right hand side of the formula give the type
  # empty gives NULL whih means guessing the type
  ptypes <- map(formulas, ~eval_bare(f_lhs(.x), f_env(.x)))

  # for each group, apply the choreography derived from the formulas
  moves <- choreography(.tbl, ..., .env = .env)
  steps <- map(rows, moves)

  list(ptypes = ptypes, steps = steps, rows = rows)
}
