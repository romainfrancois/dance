#' rumba
#'
#' @param .var TODO
#' @param ... TODO
#' @param .tbl TODO
#' @param .name TODO
#' @param .env TODO
#'
#' @export
#' @export
rumba <- function(.var, ..., .tbl = get_tbl(), .name = "{fun}", .env = caller_env()) {
  .var <- quo_name(enquo(.var))
  .funs <- list2(...)
  assert_that(!is.null(names(.funs)))
  names(.funs) <- glue(.name, fun = names(.funs), idx = seq_along(.funs))

  splice(map(.funs, ~{
    c(.ptype, .fun) %<-% promote_formula(.x, .env)
    new_formula(.ptype, expr((!!.fun)(!!sym(.var))))
  }))
}

#' zumba
#'
#' @param .var TODO
#' @param ... TODO
#' @param .tbl TODO
#' @param .name TODO
#' @param .env TODO
#'
#' @export
zumba <- function(.var, ..., .tbl = get_tbl(), .name = "data", .env = caller_env()) {
  .var <- quo_name(enquo(.var))
  .funs <- list2(...)
  assert_that(!is.null(names(.funs)))

  expressions <- map(.funs, ~ {
    c(.ptype, .fun) %<-% promote_formula(.x, .env)
    expr((!!.fun)((!!sym(.var))))
  })

  rhs <- expr(tibble(!!!expressions))
  splice(list2(!!.name := new_formula(NULL, rhs, env = .env)))
}
