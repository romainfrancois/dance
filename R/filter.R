#' mambo
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .fun TODO
#' @param .op TODO
#' @param .env TODO
#'
#' @export
mambo <- function(.fun, ..., .tbl = get_tbl(), .op = and, .env = caller_env()) {
  vars <- vars_select(tbl_vars(.tbl), ...)

  c(., .fun) %<-% promote_formula(.fun, .env)

  predicate <- map(vars, ~ expr((!!.fun)((!!sym(.))))) %>%
    reduce(~expr((!!.op)(!!.x, !!.y)))

  new_formula(NULL, predicate, env = .env)
}

#' bolero
#'
#' @param .tbl TODO
#' @param ... TODO
#' @param .op TODO
#' @param .env TODO
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
