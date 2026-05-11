import Mathlib

theorem sin_sqrt_nat_dense_in_open_interval :
    Set.Ioo (-1 : ℝ) 1 ⊆
      Set.closure ({x : ℝ | ∃ n : ℕ, x = Real.sin (Real.sqrt (n : ℝ))} : Set ℝ) := by
  sorry