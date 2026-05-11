import Mathlib

theorem matrix_trace_linear
    {n : Type*} [Fintype n] [DecidableEq n]
    {R : Type*} [CommSemiring R]
    (a b : R) (A B : Matrix n n R) :
    Matrix.trace (a • A + b • B) = a * Matrix.trace A + b * Matrix.trace B := by
  sorry