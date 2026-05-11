import Mathlib

theorem sin_over_x_eq_tprod_cos_halves {x : ℝ} (hx : x ≠ 0) :
    (∏' n : ℕ, Real.cos (x / (2 : ℝ) ^ (n + 1))) = Real.sin x / x := by
  sorry