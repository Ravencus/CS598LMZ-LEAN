import Mathlib

theorem matrix_trace_invariant_under_similarity
    {n : Type*} [Fintype n] [DecidableEq n]
    {R : Type*} [CommRing R]
    (A : Matrix n n R) (P : (Matrix n n R)ˣ) :
    Matrix.trace (((P : Matrix n n R) * A) * ((P⁻¹ : (Matrix n n R)ˣ) : Matrix n n R)) = Matrix.trace A := by
  sorry