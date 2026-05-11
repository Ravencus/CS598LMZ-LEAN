import Mathlib

theorem cosine_square_average_limit :
    Filter.Tendsto
      (fun N : ℕ =>
        ((1 : ℝ) / (N : ℝ)) *
          (∑ n in Finset.Icc 1 N, |Real.cos ((n : ℝ) ^ (2 : ℕ))|))
      Filter.atTop
      (Filter.nhds (2 / Real.pi)) := by
  sorry