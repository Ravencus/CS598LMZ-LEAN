import Mathlib

theorem matrix_trace_invariant_under_similarity
    {n : Type*} [Fintype n] [DecidableEq n]
    {R : Type*} [CommRing R]
    (A : Matrix n n R) (P : (Matrix n n R)ˣ) :
    Matrix.trace (↑P * A * ↑(P⁻¹)) = Matrix.trace A := by
  sorry