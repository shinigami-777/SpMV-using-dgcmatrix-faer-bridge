library(SPMV)
library(Matrix)

A <- sparseMatrix(
  i = c(1, 2, 3, 1, 2, 4, 1, 3, 4, 2, 3, 4),
  j = c(1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4),
  x = c(2, -1, -1, -1, 2, -1, -1, 2, -1, -1, -1, 2),
  dims = c(4, 4),
  symmetric = FALSE
)

v <- c(1, 2, 3, 4)

# multiply A*v
result <- sparse_matvec(A@i, A@p, A@x, nrow(A), ncol(A), v)
print(result)
# verify the result with A*v
as.vector(A%*% v)
