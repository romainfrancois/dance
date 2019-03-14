#' Mutate new columns
#'
#' Applies the [ballet()] and makes sure each result have the same [vctrs::vec_size()]
#' as the number of elements in each group.
#'
#' @param .tbl A data frame, most likely a grouped data frame
#' @param ...,.env formulas for each column to create, and parent environment, see [ballet()]
#' @param .name Name of the packed column made by `charleston()`
#'
#' The four functions play a separate role around the idea of
#' [dplyr::mutate()]:
#'
#' - `chacha()` reorganizes the rows of a grouped data frame so that data for each
#'    group is contiguous in each column.
#'
#' - `salsa()` runs the [ballet()] defined by `...` and makes
#'    sure the [vctrs::vec_size()] of each result is equal to the number
#'    of elements in that group. The result tibble of `salsa()`
#'    does not contain the grouping variables, just those columns specified
#'    by the `...`.
#'
#'  - `samba()` is the closest to [dplyr::mutate()], it column binds
#'   the result of `chacha()` and `salsa()` with [vctrs::vec_cbind()].
#'
#'  - `madison()` is similar to `sambda()` but the results are packed
#'   instead of being `[vctrs::vec_cbind()]`. The name of the created packed column is
#'   controled by the `.name` argument.
#'
#' @examples
#' g <- group_by(iris, Species)
#'
#' # Creates a `dance_grouped_df` tibble,
#' # which is the same as `g` but guarantees that the data for each column
#' # is contiguous within groups
#' chacha(g)
#'
#' # returns a tibble of two columns
#' g %>%
#'   salsa(
#'     Sepal = ~Sepal.Length * Sepal.Width,
#'     Petal = ~Petal.Length * Petal.Width
#'   )
#'
#' # returns a dance_grouped_df with the two
#' # additional columns `Sepal` and `Petal`
#' g %>%
#'   samba(
#'     Sepal = ~Sepal.Length * Sepal.Width,
#'     Petal = ~Petal.Length * Petal.Width
#'   )
#'
#' # returns a dance_grouped_df with the one
#' # additional data frame column
#' g %>%
#'   madison(
#'     Sepal = ~Sepal.Length * Sepal.Width,
#'     Petal = ~Petal.Length * Petal.Width
#'   )
#'
#' @rdname samba
#' @export
salsa <- function(.tbl, ..., .env = caller_env()) {
  # evaluate all the formulas in each group
  c(ptypes, steps) %<-% ballet(.tbl, ..., .env = .env)

  # check all results are length 1
  check_size <- function(result, group_size) {
    assert_that(vec_size(result) == group_size)
  }
  rows <- group_rows(.tbl)
  walk2(steps, rows, ~walk(.x, check_size, group_size = length(.y)))

  # transpose and combine
  results <- map2(ptypes, seq_along(ptypes), ~vec_c(!!!map(steps, .y), .ptype = .x))

  # structure results as a tibble
  as_tibble_splice(results)
}

#' @rdname samba
#' @export
chacha <- function(.tbl) {
  UseMethod("chacha")
}

#' @export
chacha.data.frame <- function(.tbl) {
  .tbl
}

#' @export
chacha.grouped_df <- function(.tbl) {
  rows <- group_rows(.tbl)

  sizes <- lengths(rows)
  starts <- 1L + c(0L, cumsum(head(sizes, -1L)))
  ends   <- cumsum(head(sizes))

  new_grouped_df(
    vec_slice(.tbl, flatten_int(rows)),
    vec_cbind(group_keys(.tbl), tibble(.rows := map2(starts, ends, seq2))),
    class = "dance_grouped_df"
  )
}

#' @export
chacha.dance_grouped_df <- function(.tbl) {
  .tbl
}

#' @rdname samba
#' @export
samba <- function(.tbl, ..., .env = caller_env()) {
  vec_cbind(chacha(.tbl), salsa(.tbl, ..., .env = .env))
}

#' @rdname samba
#' @export
madison <- function(.tbl, ..., .name = "data", .env = caller_env()) {
  vec_cbind(chacha(.tbl), tibble(!!.name := salsa(.tbl, ..., .env = .env)))
}


