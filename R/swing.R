
#' Apply a single function to multiple columns
#'
#' - `swing()` : returns a spliced list of formulas, suitable for the
#'   `...` argument of [choreography()], as well as all the dances that
#'   use a [choreography()]
#'
#' - `twist()` : returns a single formula that makes a tibble column
#'
#' These functions are generally used within other dances, such as
#' [tango()], [samba()] or [jive()]
#'
#' @param .fun A function or a formula that uses `.` or
#'    `.x` to refer to each of the selected column
#' @param ... tidy selection of columns, see [tidyselect::vars_select()] for details
#' @param .tbl,.env data frame `...` selects columns from, this is
#'   automatically set by the [choreography()], you should rarely need to use these arguments
#' @param .name [glue::glue()] model to name the outputs. The model may use :
#'   - `{var}` to refer to the name of the current selected variable
#'   - `{idx}` to refer to the index of the current variable
#' The default value "{var}" for `.name` simply uses the name of the selected variable
#'
#' @seealso [rumba()] and [zumba()] to apply several functions to the same column
#'
#' @examples
#' g <- iris %>% group_by(Species)
#'
#' ##------- tango()
#'
#' # Apply mean to all columns that start with Sepal
#' # and choose how the result columns are called
#' g %>%
#'   tango(
#'     swing(mean, starts_with("Sepal"), .name = "mean_{var}")
#'   )
#'
#' # if you want to use extra arguments of `.fun` you can embed
#' # them with the lambda syntax
#' g %>%
#'   tango(
#'     swing(~mean(., trim = .2), starts_with("Sepal"), .name = "mean_{var}")
#'   )
#'
#' # use twist() to instead create a single packed column
#' g %>%
#'   tango(
#'     mean = twist(mean, starts_with("Sepal"))
#'   )
#' # but in fact, if you don't name the formula made by twist()
#' # the columns are auto spliced
#' g %>%
#'   tango(
#'     twist(mean, starts_with("Sepal"))
#'   )
#'
#' ##------- samba()
#'
#' g %>%
#'   samba(
#'     swing(~. - mean(.), starts_with("Sepal"), .name = "centered_{var}")
#'   )
#'
#' g %>%
#'   samba(
#'     centered = twist(~. - mean(.), starts_with("Sepal"), .name = "centered_{var}")
#'   )
#'
#' ##------- jive()
#'
#' g %>%
#'   jive(
#'     q = ~ c("25%", "50%", "75%"),
#'     swing(~quantile(., c(0.25, 0.5, 0.75)), contains("."))
#'   )
#'
#' @export
swing <- function(.fun, ..., .tbl = get_tbl(), .name = "{var}", .env = caller_env()) {
  vars <- vars_select(tbl_vars(.tbl), ...)
  names(vars) <- glue(.name, var = names(vars), idx = seq_along(vars))
  c(.ptype, .fun) %<-% promote_formula(.fun, .env)

  splice(
    map(vars, ~new_formula(.ptype, expr((!!.fun)(!!sym(.)))))
  )
}

#' @rdname swing
#' @export
twist <- function(.fun, ..., .tbl = get_tbl(), .name = "{var}", .env = caller_env()) {
  vars <- vars_select(tbl_vars(.tbl), ...)
  names(vars) <- glue(.name, var = names(vars), idx = seq_along(vars))
  c(.ptype, .fun) %<-% promote_formula(.fun, .env)

  expressions <- map(vars, ~ expr((!!.fun)((!!sym(.)))))

  rhs <- expr(tibble(!!!expressions))
  new_formula(NULL, rhs, env = .env)
}
