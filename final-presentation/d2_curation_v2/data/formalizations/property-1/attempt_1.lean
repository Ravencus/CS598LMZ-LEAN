import Mathlib

theorem matrix_trace_mul_comm
    {n : Type*} [Fintype n] [DecidableEq n]
    {R : Type*} [CommSemiring R]
    (A B : Matrix n n R) :
    Matrix.trace (A * B) = Matrix.trace (B * A) := by
  sorry