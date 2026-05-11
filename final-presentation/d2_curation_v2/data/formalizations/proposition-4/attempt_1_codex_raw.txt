import Mathlib

theorem cosine_square_average_tends_to_two_div_pi :
    Filter.Tendsto
      (fun N : ℕ =>
        ((∑ n in Finset.Icc 1 N, |Real.cos ((n : ℝ) ^ 2)|) : ℝ) / N)
      Filter.atTop
      (nhds (2 / Real.pi)) ∧
    2 / Real.pi =
      (1 / (2 * Real.pi)) * ∫ x in (0 : ℝ)..(2 * Real.pi), |Real.cos x| := by
  sorry