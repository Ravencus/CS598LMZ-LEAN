import Mathlib

theorem alpha_int_add_beta_int_dense {α β : ℝ}
    (h : Irrational (β / α)) :
    Dense ({x : ℝ | ∃ m n : ℤ, x = α * (m : ℝ) + β * (n : ℝ)} : Set ℝ) := by
  sorry