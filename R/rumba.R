
#' Apply several functions to the same column
#'
#' @param .var A variable specified as in [dplyr::pull()]
#' @param ... list of functions or formulas using `.` to refer to the column
#' @param .tbl,.env data frame to get columns from and caller environment. Most of the
#'   time, you don't need to set these
#' @param .name [glue::glue()] model to name the created columns. The model can use :
#' - `{fun}` to refer to the function name
#' - `{idx}` to refer to the index of the function with the given list
#' - `{var}` to refer to the selected name
#' The default uses `"{fun}"` is the `...` list is named, and `"fn{idx}"` otherwise
#'
#' @return
#'
#' - `rumba()` returns a spliced list of formulas suitable for the `...` of a
#'   [choreography()] based dance, e.g. [tango()], [samba()], [jive()]
#'
#' - `zumba()` returns a single formula that packs the results
#'
#' @examples
#' g <- group_by(iris, Species)
#'
#' # ---- tango()
#' g %>%
#'   tango(rumba(Sepal.Length, mean = mean, median = median))
#'
#' # select the first column, control the result names
#' # with the glue() model
#' g %>%
#'   tango(rumba(1, mean = mean, median = median, .name = "{var}_{fun}"))
#'
#' g %>%
#'   tango(Sepal.Width = zumba(Sepal.Width, mean = mean, median = median))
#'
#' # ---- jive()
#' g %>%
#'   jive(
#'     rumba(Sepal.Width, five = fivenum, quantile = quantile)
#'   )
#'
#' @export
rumba <- function(.var, ..., .tbl = get_tbl(), .name = NULL, .env = caller_env()) {
  .var <- vars_pull(names(.tbl), !!enquo(.var))
  .funs <- list2(...)
  names(.funs) <- glue(
    .name %||% if(is.null(names(.funs))) "fn{idx}" else "{fun}",
    fun = names(.funs) %||% rep("", length(.funs)),
    idx = seq_along(.funs),
    var = .var
  )

  splice(map(.funs, ~{
    c(.ptype, .fun) %<-% promote_formula(.x, .env)
    new_formula(.ptype, expr((!!.fun)(!!sym(.var))))
  }))
}

#' @rdname rumba
#' @export
zumba <- function(.var, ..., .tbl = get_tbl(), .name = NULL, .env = caller_env()) {
  formulas <- rumba(!!enquo(.var), ..., .tbl = .tbl, .name = .name, .env = .env)
  rhs <- expr(
    tibble(!!!map(formulas, f_rhs))
  )
  new_formula(NULL, rhs, env = .env)
}
