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

is_bare_vector <- function(x) {
  is_vector(x) && !is.object(x) && is.null(attr(x, "class"))
}

slicer <- function(.) {
  if (is_bare_vector(.)) {
    .subset
  } else {
    vec_slice
  }
}

tbl_slicer_args <- function(.tbl) {
  args <- map(.tbl, ~expr((!!slicer(.x))((!!.x), `.::index::.`)))
  list2(`.::index::.` = missing_arg(), !!!args)
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

as_tibble_splice <- function(x, ...) {
  if (is.null(names(x))) {
    names(x) <- rep("", length(x))
  }
  needs_splice <- names(x) == "" & map_lgl(x, is.data.frame)

  n <- sum(map2_int(x, needs_splice, ~ {
    if(.y) length(.x) else 1L
  }))

  out_names <- flatten_chr(map2(x, names(x), ~{
    if(.y == "") names(.x) else .y
  }))

  out <- rep(list(NULL), n)
  k <- 1L
  for(i in seq_along(x)) {
    if (needs_splice[i]) {
      tbl <- x[[i]]
      for(j in seq_len(ncol(tbl))) {
        out[[k]] <- tbl[[j]]
        k <- k + 1
      }
    } else {
      out[[k]] <- x[[i]]
      k <- k + 1
    }
  }
  as_tibble(set_names(out, out_names), ...)
}
