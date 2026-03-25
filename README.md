# SpMV-using-dgcmatrix-faer-bridge
An example R package demonstrating sparse matrix-vector multiplication (SpMV) using Rust through the [`dgcmatrix-faer-bridge`](https://github.com/shinigami-777/dgcmatrix-faer-bridge) pattern crate.

## Overview
This package provides two implementations for sparse matrix-vector multiplication:

1. **`sparse_matvec()`** - Uses dgcmatrix-faer-bridge conversion to construct sparse matrix, then performs sparse matrix-vector multiplication using CSC format in faer SparseColMat.
2. **`sparse_matvec_direct()`** - Performs sparse matrix-vector multiplication directly on passed slots without conversion/validation. 

The `sparse_matvec_direct()` is faster since it has no conversion/validation overhead. However, it is more error-prone with bounds that can be easily messed with. We can directly work with the slots for this particular example package, but that won't be true for a lot of cases. The sparse matrix conversion is required for more complex tasks as it is safe and can be easily extended.

We can compare the difference between `sparse_matvec_direct()` and `sparse_matvec()` to get an approx idea of the conversion/validation overhead used in `dgcmatrix-faer-bridge`.

### Installation
Clone the repo
```
git clone https://github.com/shinigami-777/SpMV-using-dgcmatrix-faer-bridge.git
cd SpMV-using-dgcmatrix-faer-bridge
```
In R
```
install.packages("rextendr")
library(rextendr)
setwd("SPMV")
rextendr::document()
```

Run the [example-usage](https://github.com/shinigami-777/SpMV-using-dgcmatrix-faer-bridge/blob/main/Rscripts/example-usage.R) to check if it works.

### Benchmarks

We compare performance between:
- `sparse_matvec_pure_r()` (sparse R implementation for SpMV)
- `sparse_matvec()` (with conversion using dgcmatrix-faer-bridge)
- `sparse_matvec_direct()` (without conversion; from direct slots)

All of the functions have a time complexity of `O(nnz)` yet they perform differently. The difference between R and Rust is significant. Between the rust ones, `sparse_matvec()` is slower due to the reconstruction and validation overhead. Even with all the overheads, `sparse_matvec()` is 2x faster that the pure R code (for n= 20000) and the speedup becomes even more for larger n. 

Run the [Benchmarks.R](https://github.com/shinigami-777/SpMV-using-dgcmatrix-faer-bridge/blob/main/Rscripts/Benchmarks.R) file.

**With n = 20000, density = 0.001 sparse matrix and 100 iterations**

| Expression           | Min      | Median   | itr/sec | mem_alloc | gc/sec | n_itr | n_gc | Total Time |
| -------------------- | -------- | -------- | ------: | --------- | -----: | ----: | ---: | ---------- |
| R_sparse             | 46.22 ms | 46.59 ms |    21.3 | 156 KB    |   1.60 |    93 |    7 | 4.36 s     |
| Rust_direct_from_CSC | 4.94 ms  | 4.97 ms  |     200 | 156 KB    |      0 |   100 |    0 | 500.59 ms  |
| Rust_faer            | 23.46 ms | 23.59 ms |    42.3 | 156 KB    |  0.427 |    99 |    1 | 2.34 s     |

Based on this we can say the conversion overhead(approx) using `dgcmatrix-faer-bridge` pattern is 23.59 − 4.97 = 18.62 ms (for n = 20000, density = 0.001).
