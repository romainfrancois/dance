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
  c(., steps) %<-% ballet(.tbl, ..., .env = .env)

  check <- function(result, group_size) {
    assert_that(vec_size(result) == group_size, is.logical(result))
  }
  rows <- group_rows(.tbl)
  walk2(steps, rows, ~walk(.x, check, group_size = length(.y)))

  # the indices for each group
  steps <- map(steps, ~which(reduce(.x, .op)))

  if (is_grouped_df(.tbl)) {
    .chacha_grouped_df(.tbl, steps)
  } else {
    vec_slice(.tbl, flatten_int(steps))
  }
}
