
#' @export
waltz <- function(.tbl, ..., .rows = group_rows(.tbl)) {
  set_tbl(.tbl)
  formulas <- list2(...)

  if(is.null(formulas)) {
    names(formulas) <- rep("", length(formulas))
  }
  assert_that(
    all(map_lgl(formulas, is_formula)),
    msg = "`...` should be a named list of formulas"
  )

  parts <- map(formulas, ~{
    eval_grouped(.tbl, new_quosure(f_rhs(.x), f_env(.x)), .rows = .rows, .ptype = eval_bare(f_lhs(.x), f_env(.x)))
  })

  tibble(!!!group_keys(.tbl), !!!parts)
}

