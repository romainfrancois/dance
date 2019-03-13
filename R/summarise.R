
#' Summarise one row per group
#'
#' Applies the [ballet()] and makes sure each results is of size 1,
#' according to [vctrs::vec_size()]
#'
#' @param .tbl A data frame, most likely a grouped data frame
#' @param ...,.env formulas for each column to create, and parent environment, see [ballet()]
#' @param .name Name of the packed column made by `charleston()`
#'
#' The four functions play a separate role around the idea of
#' [dplyr::summarise()]:
#'
#' - `polka()` peels off one level of grouping from the grouping variable,
#'    i.e. if `.tbl` was grouped by `x` and `y` the result of `polka()`
#'    contains columns `x` and `y` and is only grouped by `x`
#'
#' - `waltz()` runs the [ballet()] defined `...` and makes
#'    sure each result is of [vec_size()] 1. The result tibble of `waltz()`
#'    does not contain the grouping variables.
#'
#' - `tango()` is the closest to [dplyr::summarise()], it column binds
#'   the result of `polka()` and `waltz()` with [vctrs::vec_cbind()].
#'
#' - `charleston()` is similar to `tango()` but the results are packed
#'   instead of being bind. The name of the created package column is
#'   controled by the `.name` argument.
#'
#' @examples
#' g <- group_by(iris, Species)
#'
#' polka(g)
#'
#' g %>%
#'   waltz(Sepal = ~mean(Sepal.Length * Sepal.Width))
#'
#' g %>%
#'   tango(Sepal = ~mean(Sepal.Length * Sepal.Width))
#'
#' g %>%
#'   charleston(Sepal = ~mean(Sepal.Length * Sepal.Width))
#'
#' @export
tango <- function(.tbl, ..., .env = caller_env()) {
  vec_cbind(polka(.tbl), waltz(.tbl, ..., .env = .env))
}

#' @rdname tango
#' @export
waltz <- function(.tbl, ..., .env = caller_env()) {
  # evaluate all the formulas in each group
  c(ptypes, steps, .) %<-% ballet(.tbl, ..., .env = .env)

  # check all results are length 1
  walk(steps, ~walk(.x, ~assert_that(vec_size(.x) == 1L)))

  # transpose, combine
  results <- map2(transpose(steps), ptypes, ~vec_c(!!!.x, .ptype = .y))

  as_tibble_splice(results)
}

#' @rdname tango
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

#' @rdname tango
#' @export
charleston <- function(.tbl, ..., .name = "data", .env = caller_env()) {
  vec_cbind(polka(.tbl), tibble(!!.name := waltz(.tbl, ..., .env = .env)))
}
