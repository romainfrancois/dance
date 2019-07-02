#include <Rcpp.h>
using namespace Rcpp;

R_xlen_t convert_R_xlen(SEXP x) {
  switch(TYPEOF(x)){
  case INTSXP: return (R_xlen_t) INTEGER_ELT(x, 0);
  case REALSXP: return (R_xlen_t) REAL_ELT(x, 0);
  default:
    return 0;
  }
}


// [[Rcpp::export]]
void bolero_check_results(SEXP steps, SEXP rows, SEXP nsteps_) {
  R_xlen_t n = XLENGTH(steps);
  R_xlen_t n_steps = convert_R_xlen(nsteps_);

  for (R_xlen_t i=0; i<n; i++) {
    // the number of rows in the i'th group
    R_xlen_t n_i = XLENGTH(VECTOR_ELT(rows, i));

    SEXP steps_i = VECTOR_ELT(steps, i);
    for (R_xlen_t j=0; j<n_steps; j++) {
      SEXP steps_i_j = VECTOR_ELT(steps_i, j);
      if (TYPEOF(steps_i_j) != LGLSXP || XLENGTH(steps_i_j) != n_i) {
        Rcpp::stop("incompatible results");
      }
    }
  }
}

// [[Rcpp::export]]
SEXP bolero_lgl_steps_to_indices(SEXP steps, SEXP n_steps_, SEXP original_rows) {
  R_xlen_t n = XLENGTH(steps);
  R_xlen_t n_steps = convert_R_xlen(n_steps_);

  // the indices relative to the original data
  SEXP indices = PROTECT(Rf_allocVector(VECSXP, n));

  // the indices relative to the new data
  SEXP rows = PROTECT(Rf_allocVector(VECSXP, n));

  R_xlen_t idx_rows = 0;
  for (R_xlen_t i=0; i<n; i++) {
    SEXP steps_i = VECTOR_ELT(steps, i);
    SEXP original_rows_i = VECTOR_ELT(original_rows, i);

    // first pass, count
    R_xlen_t n = XLENGTH(VECTOR_ELT(steps_i, 0));
    R_xlen_t n_true = 0;

    std::vector<int*> starts(n_steps);
    for (R_xlen_t k=0; k<n_steps; k++) {
      starts[k] = LOGICAL(VECTOR_ELT(steps_i, k));
    }

    for (R_xlen_t j=0; j<n; j++) {
      bool ok = true;
      for (R_xlen_t k=0; k < n_steps; k++) {
        ok = ok && starts[k][j] == TRUE;
      }
      n_true += ok;
    }

    // second pass, fill
    SEXP indices_i = Rf_allocVector(INTSXP, n_true);
    SET_VECTOR_ELT(indices, i, indices_i);

    SEXP rows_i = Rf_allocVector(INTSXP, n_true);
    SET_VECTOR_ELT(rows, i, rows_i);

    int* p_original_rows_i = INTEGER(original_rows_i);
    int* p_indices_i = INTEGER(indices_i);
    int* p_rows_i = INTEGER(rows_i);

    for (R_xlen_t j=0, idx = 0; idx < n_true; j++) {
      bool ok = true;
      for (R_xlen_t k=0; k < n_steps; k++) {
        ok = ok && starts[k][j] == TRUE;
      }
      if (ok) {
        p_indices_i[idx] = p_original_rows_i[j];
        p_rows_i[idx++] = ++idx_rows;
      }
    }

  }
  SEXP out = PROTECT(Rf_allocVector(VECSXP, 2));
  SET_VECTOR_ELT(out, 0, indices);
  SET_VECTOR_ELT(out, 1, rows);

  UNPROTECT(3);
  return out;
}
