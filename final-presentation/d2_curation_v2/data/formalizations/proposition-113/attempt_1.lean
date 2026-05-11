import Mathlib

theorem matrix_charpoly_mul_eq_charpoly_mul (n : ℕ) (A B : Matrix (Fin n) (Fin n) ℂ) :
    Matrix.charpoly (A * B) = Matrix.charpoly (B * A) := by
  sorry