import Mathlib

theorem cosine_square_average_limit :
    Filter.Tendsto
      (fun N : ℕ =>
        ((1 : ℝ) / (N : ℝ)) *
          Finset.sum (Finset.Icc 1 N) (fun n => |Real.cos ((n : ℝ) ^ (2 : ℕ))|))
      Filter.atTop
      (Filter.nhds ((2 : ℝ) / Real.pi)) := by
  sorry