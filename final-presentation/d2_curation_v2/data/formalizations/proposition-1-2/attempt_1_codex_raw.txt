import Mathlib

theorem matrix_mul_spectrum_eq_matrix_mul_swap
    (n : Type) [Fintype n] [DecidableEq n] (A B : Matrix n n ℂ) :
    spectrum ℂ (A ⬝ B) = spectrum ℂ (B ⬝ A) := by
  sorry