
#' @export
waltz <- function(.tbl, ...) {
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
  parts <- map(formulas, ~{
    eval_grouped(
      .tbl,
      new_quosure(f_rhs(.x), f_env(.x)),
      .rows = .rows,
      .ptype = eval_bare(f_lhs(.x), f_env(.x))
    )
  })

  as_tibble(parts)
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
  bind_cols(waltz(.tbl, ...), polka(.tbl))
}

