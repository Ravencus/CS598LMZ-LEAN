import Mathlib

theorem sum_sin_div_nsq_tendsto_half :
    Filter.Tendsto
      (fun n : ℕ => ∑ k in Finset.range (n + 1), Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
      Filter.atTop
      (nhds ((1 : ℝ) / 2)) := by
  sorry