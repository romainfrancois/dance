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

  # how to vec_slice() the data to get the result
  indices <- flatten_int(steps)

  if (is_grouped_df(.tbl)) {
    # TODO: that's almost exactly the same as chacha()
    sizes <- lengths(steps)
    starts <- 1L + c(0L, cumsum(head(sizes, -1L)))
    ends   <- cumsum(head(sizes))

    new_grouped_df(
      vec_slice(.tbl, indices),
      vec_cbind(group_keys(.tbl), tibble(.rows := map2(starts, ends, seq2))),
      class = "dance_grouped_data"
    )
  } else {
    vec_slice(.tbl, indices)
  }
}
