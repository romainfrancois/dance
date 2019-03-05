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
    .f <- as_mapper(.f)
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

globalVariables(c(".::index::.", "mapper", "name", ".", ".ptype", ".rows", "ptypes", "rows", "steps"))

tbl_slicer_args <- function(.tbl) {
  args <- map(.tbl, ~expr((!!slicer(.x))((!!.x), `.::index::.`)))
  list2(`.::index::.` = missing_arg(), !!!args)
}

#' @export
choreography <- function(.tbl, ..., .formulas = list2(...), .env = caller_env()) {
  args <- tbl_slicer_args(.tbl)
  body <- expr(list(!!!map(.formulas, f_rhs)))
  structure(rlang::new_function(args, body, env = .env), class = "choreography")
}

#' @export
print.choreography <- function(x, ...) {
  expr_print(unclass(x))
  invisible(x)
}

promote_formula <- function(.fun, .env) {
  if (is_function(.fun)) {
    .ptype <- NULL
  } else if(is_formula(.fun)){
    .ptype <- eval_bare(f_lhs(.fun), .env)
    .fun <- as_function(new_formula(NULL, f_rhs(.fun), env = .env), env = .env)
  }

  list(.ptype, .fun)
}

