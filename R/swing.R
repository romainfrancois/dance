promote_formula <- function(.fun, .env) {
  if (is_function(.fun)) {
    .ptype <- NULL
  } else if(is_formula(.fun)){
    .ptype <- eval_bare(f_lhs(.fun), .env)
    .fun <- as_function(new_formula(NULL, f_rhs(.fun), env = .env), env = .env)
  }

  list(.ptype, .fun)
}

#' @export
swing <- function(.fun, ..., .tbl = get_tbl(), .name = "{var}", .env = caller_env()) {
  vars <- vars_select(tbl_vars(.tbl), ...)
  names(vars) <- glue(.name, var = names(vars), idx = seq_along(vars))

  c(.ptype, .fun) %<-% promote_formula(.fun, .env)

  splice(
    map(vars, ~new_formula(.ptype, expr((!!.fun)(!!sym(.)))))
  )
}

#' @export
twist <- function(.fun, ..., .tbl = get_tbl(), .name = "data", .env = caller_env()) {
  vars <- vars_select(tbl_vars(.tbl), ...)

  c(.ptype, .fun) %<-% promote_formula(.fun, .env)

  expressions <- map(vars, ~ expr((!!.fun)((!!sym(.)))))
  rhs <- expr(tibble(!!!expressions))
  splice(list2(!!.name := new_formula(NULL, rhs, env = .env)))
}

