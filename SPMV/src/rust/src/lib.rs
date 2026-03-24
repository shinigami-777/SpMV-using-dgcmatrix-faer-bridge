use dgcmatrix_faer_bridge::{dgcmatrix_to_faer, DgCMatrixView};
use extendr_api::prelude::*;

#[extendr]
// Sparse matrix–vector multiplication
// First reconstruct the perform sparse matrix–vector multiplication (SpMV) using CSC format
fn sparse_matvec(i: &[i32], p: &[i32], x: &[f64], nrow: i32, ncol: i32, vec: &[f64]) -> Vec<f64> {
    let view = DgCMatrixView::new(nrow as usize, ncol as usize, &p, &i, &x);

    let mat = dgcmatrix_to_faer(&view).expect("Failed to convert matrix");
    let mut result = vec![0.0; nrow as usize];

    for col in 0..mat.ncols() {
        let rows = mat.row_indices_of_col(col);
        let vals = mat.values_of_col(col);

        for (row, val) in rows.zip(vals) {
            result[row] += val * vec[col];
        }
    }

    result
}

#[extendr]
// Direct SpMV using dgCMatrix slots (without using dgcmatrix_to_faer)
// This func is faster as no validation or reconstruction present
fn sparse_matvec_direct(
    i: &[i32],
    p: &[i32],
    x: &[f64],
    nrow: i32,
    ncol: i32,
    vec: &[f64],
) -> Vec<f64> {
    let nrow = nrow as usize;
    let ncol = ncol as usize;

    let mut result = vec![0.0; nrow];
    for col in 0..ncol {
        let start = p[col] as usize;
        let end = p[col + 1] as usize;
        let vj = vec[col];

        for k in start..end {
            let row = i[k] as usize;
            result[row] += x[k] * vj;
        }
    }

    result
}

extendr_module! {
    mod SPMV;
    fn sparse_matvec;
    fn sparse_matvec_direct;
}
