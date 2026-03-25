# SpMV-using-dgcmatrix-faer-bridge
An example R package demonstrating sparse matrix-vector multiplication (SpMV) using Rust through the [`dgcmatrix-faer-bridge`](https://github.com/shinigami-777/dgcmatrix-faer-bridge) pattern crate.

## Overview
This package provides two implementations for sparse matrix-vector multiplication:

1. **`sparse_matvec()`** - Uses dgcmatrix-faer-bridge conversion to construct sparse matrix, then performs sparse matrix-vector multiplication using CSC format in faer SparseColMat.
2. **`sparse_matvec_direct()`** - Performs sparse matrix-vector multiplication directly on passed slots without conversion/validation. 

The `sparse_matvec_direct()` is faster since it has no conversion/validation overhead. However, it is more error-prone with bounds that can be easily messed with. We can directly work with the slots for this particular example package, but that won't be true for a lot of cases. The sparse matrix conversion is required for more complex tasks as it is safe and can be more easily extended.

We can compare the difference between `sparse_matvec_direct()` and `sparse_matvec()` to get a approx idea of the conversion/validation overhead used in `dgcmatrix-faer-bridge`.

