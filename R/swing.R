#' @export
swing <- function(.fun, ..., .tbl = get_tbl(), .name = "{var}") {
  vars <- vars_select(tbl_vars(.tbl), ...)
  names(vars) <- glue(.name, var = names(vars))

  if (is_function(.fun)) {
    env <- caller_env()
    .ptype <- NULL
    map(vars, ~new_formula(NULL, expr((!!.fun)(!!sym(.)))))
  } else if(is_formula(.fun)){
    env <- f_env(.fun)
    .ptype <- eval_bare(f_lhs(.fun), env)
    .fun <- as_function(new_formula(NULL, f_rhs(.fun), env = env), env = env)
  }

  structure(
    map(vars, ~new_formula(.ptype, expr((!!.fun)(!!sym(.))))),
    class = "spliced"
  )
}
