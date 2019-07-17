#pragma once
#include <Rcpp.h>

namespace dance {

inline R_xlen_t convert_R_xlen(SEXP x) {
  switch(TYPEOF(x)){
  case INTSXP: return (R_xlen_t) INTEGER_ELT(x, 0);
  case REALSXP: return (R_xlen_t) REAL_ELT(x, 0);
  default:
    return 0;
  }
}

}
