import Mathlib

theorem gl_dense_in_matrix_complex
    {n : Type*} [Fintype n] [DecidableEq n] :
    Dense ({A : Matrix n n ℂ | IsUnit A} : Set (Matrix n n ℂ)) := by
  sorry