import Mathlib

theorem cosine_square_average_tends_to_two_div_pi :
    Filter.Tendsto
      (fun N : ℕ =>
        Finset.sum (Finset.Icc 1 N) (fun n => |Real.cos ((n : ℝ) ^ (2 : ℕ))|) / (N : ℝ))
      Filter.atTop
      (𝓝 (2 / Real.pi)) ∧
    2 / Real.pi =
      (1 / (2 * Real.pi)) * (∫ x in (0 : ℝ)..(2 * Real.pi), |Real.cos x|) := by
  sorry