
#' swing
#'
#' @param .fun TODO
#' @param ... TODO
#' @param .tbl TODO
#' @param .name TODO
#' @param .env TODO
#'
#' @export
swing <- function(.fun, ..., .tbl = get_tbl(), .name = "{var}", .env = caller_env()) {
  vars <- vars_select(tbl_vars(.tbl), ...)
  names(vars) <- glue(.name, var = names(vars), idx = seq_along(vars))

  c(.ptype, .fun) %<-% promote_formula(.fun, .env)

  splice(map(vars, ~new_formula(.ptype, expr((!!.fun)(!!sym(.))))))
}

#' twist
#'
#' @param .fun TODO
#' @param ... TODO
#' @param .tbl TODO
#' @param .name TODO
#' @param .env TODO
#'
#' @export
twist <- function(.fun, ..., .tbl = get_tbl(), .name = "data", .env = caller_env()) {
  vars <- vars_select(tbl_vars(.tbl), ...)

  c(.ptype, .fun) %<-% promote_formula(.fun, .env)

  expressions <- map(vars, ~ expr((!!.fun)((!!sym(.)))))
  rhs <- expr(tibble(!!!expressions))
  splice(list2(!!.name := new_formula(NULL, rhs, env = .env)))
}
