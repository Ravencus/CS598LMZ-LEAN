import Mathlib

theorem limit_N_mul_tail_sum_inv_sq :
    Filter.Tendsto
      (fun N : ℕ =>
        (N : ℝ) * ∑' n : ℕ, if N < n then (1 : ℝ) / (n : ℝ)^2 else 0)
      Filter.atTop
      (nhds 1) := by
  sorry