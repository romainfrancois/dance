
dance_env <- new.env()

set_tbl <- function(.tbl) {
  old <- dance_env[["context"]]
  dance_env[["context"]] <- .tbl
  old
}

get_tbl <- function() {
  dance_env[["context"]]
}

map_for_type <- function(.ptype, combine = vec_c) {
  function(.x, .f, ...) {
    out <- map(.x, function(x){
      res <- .f(x, ...)
      stopifnot(vec_size(res) == 1L)
      res
    })
    combine(!!!out, .ptype = .ptype)
  }
}

map_for <- function(.ptype) {
  if (identical(.ptype, list())) {
    map
  } else if(identical(.ptype, integer())) {
    map_int
  } else if(identical(.ptype, double())) {
    map_dbl
  } else if(identical(.ptype, raw())) {
    map_raw
  } else if(identical(.ptype, character())) {
    map_chr
  } else if(identical(.ptype, logical())) {
    map_lgl
  } else if(is.data.frame(.ptype)) {
    if (ncol(.ptype) == 0L){
      map_for_type(NULL, vec_rbind)
    } else {
      map_for_type(.ptype, vec_rbind)
    }
  } else {
    map_for_type(.ptype, vec_c)
  }
}

is_bare_vector <- function(x) {
  is_vector(x) && !is.object(x) && is.null(attr(x, "class"))
}

#' @export
magrittr::`%>%`

globalVariables(c(".::index::.", ".::rhs::.", "lambda", "mapper", "name", "."))

slicer_bare <- function(.) {
  expr(.subset(!!., `.::index::.`))
}

slicer_generic <- function(.) {
  expr(vec_slice(!!., `.::index::.`))
}

slicer <- function(.) {
  if (is_bare_vector(.)) {
    slicer_bare(.)
  } else {
    slicer_generic(.)
  }
}

tbl_slicer_args <- function(.tbl) {
  args <- map(.tbl, slicer)
  list2(`.::index::.` = missing_arg(), !!!args)
}

dance_lambda <- function(.tbl, .expr) {
  env <- quo_get_env(.expr)
  lambda <- rlang::new_function(
    tbl_slicer_args(.tbl),
    quo_get_expr(.expr),
    env = env
  )
  attr(lambda, "class") <- "dance_lambda"
  lambda
}

#' @export
eval_grouped <- function(.tbl, .quo = quo(42L), .rows = group_rows(.tbl), .ptype = NULL) {
  # derive a function from the types of .tbl and the expression
  lambda <- dance_lambda(.tbl, .quo)

  # the appropriate mapper for the ptype
  mapper <- map_for(.ptype)

  # evaluate the expression for each group
  mapper(.rows, lambda)
}

#' @export
waltz <- function(.tbl, ..., .rows = group_rows(.tbl)) {
  set_tbl(.tbl)
  formulas <- list2(...)

  if(is.null(formulas)) {
    names(formulas) <- rep("", length(formulas))
  }
  assert_that(
    all(map_lgl(formulas, is_formula)),
    msg = "`...` should be a named list of formulas"
  )

  parts <- map(formulas, ~{
    eval_grouped(.tbl, new_quosure(f_rhs(.x), f_env(.x)), .rows = .rows, .ptype = eval_bare(f_lhs(.x), f_env(.x)))
  })

  tibble(!!!group_keys(.tbl), !!!parts)
}

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

#' @export
print.dance_lambda <- function(x, ...) {
  expr_print(unclass(x))
  invisible(x)
}

