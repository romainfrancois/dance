#' Apply same predicate to multiple variables, and reduce
#'
#' @param .fun A function or a formula that uses `.`
#' @param ... Tidy selection, see [tidyselect::vars_select()]
#' @param .op binary operator to [purrr::reduce()]
#' @param .tbl,.env Data frame to select columns from, and parent environment,
#'   you most likely don't need to supply those arguments
#'
#' @return a single formula
#'
#' @examples
#' iris %>%
#'   bolero(mambo(~. > 4, starts_with("Sepal")))
#'
#' @export
mambo <- function(.fun, ..., .tbl = get_tbl(), .op = and, .env = caller_env()) {
  predicate <- swing(.fun, ..., .tbl = .tbl, .env = .env) %>%
    map(f_rhs) %>%
    reduce(~expr((!!.op)(!!.x, !!.y)))

  new_formula(NULL, predicate, env = .env)
}

#' Filtering rows
#'
#' @param .tbl data frame, most likely grouped
#' @param ...,.env formulas and caller environment
#' @param .op binary operator to [reduce()] results when there are multiple `...`
#'
#' @return A tibble with matching rows
#'
#' @examples
#' iris %>%
#'   bolero(~ Sepal.Length > 5.5, ~Sepal.Width >= 4)
#'
#' @export
bolero <- function(.tbl, ..., .op = and, .env = caller_env()) {
  c(ptypes, steps) %<-% ballet(.tbl, ..., .env = .env)
  rows <- group_rows(.tbl)

  bolero_check_results(steps, rows, length(ptypes))

  # the indices for each group
  c(indices, new_rows) %<-% bolero_lgl_steps_to_indices(steps, length(ptypes), rows)
  tbl_slice <- vec_slice(.tbl, flatten_int(indices))

  if (is_grouped_df(.tbl)) {
    tbl_slice <- new_grouped_df(
      tbl_slice,
      vec_cbind(group_keys(.tbl), tibble(.rows := new_rows)),
      class = "dance_grouped_df"
    )
  }

  tbl_slice
}
