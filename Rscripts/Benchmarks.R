library(Matrix)
library(bench)
library(SPMV)

sparse_matvec_pure_r <- function(A, v) {
  nrow <- nrow(A)
  ncol <- ncol(A)
  result <- numeric(nrow)

  for (col in 1:ncol) {
    start <- A@p[col] + 1
    end <- A@p[col + 1]

    if (start <= end) {
      v_col <- v[col]
      for (k in start:end) {
        row <- A@i[k] + 1
        result[row] <- result[row] + A@x[k] * v_col
      }
    }
  }

  result
}

# Create test matrix (dgCMatrix)
n <- 20000
density <- 0.001
A <- rsparsematrix(n, n, density = density)
A <- as(A, "dgCMatrix")
v <- runif(n)


rust_direct <- sparse_matvec_direct(A@i, A@p, A@x, nrow(A), ncol(A), v)
rust_faer <- sparse_matvec(A@i, A@p, A@x, nrow(A), ncol(A), v)
R_sparse = sparse_matvec_pure_r(A, v)

# Verify correctness before running benchmarks
stopifnot(max(abs(R_sparse - rust_direct)) < 1e-10)
stopifnot(max(abs(R_sparse - rust_direct)) < 1e-10)

# Benchmarks
results <- bench::mark(
  R_sparse = sparse_matvec_pure_r(A, v),
  Rust_direct_from_CSC = sparse_matvec_direct(A@i, A@p, A@x, nrow(A), ncol(A), v),
  Rust_faer = sparse_matvec(A@i, A@p, A@x, nrow(A), ncol(A), v),
  iterations = 100,
  check = FALSE
)

print(results)
