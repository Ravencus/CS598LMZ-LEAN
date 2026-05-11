import Mathlib

theorem log_nat_fractional_parts_dense
    (h_inf : Filter.Tendsto (fun n : ℕ => Real.log (n + 1)) Filter.atTop Filter.atTop)
    (h_gap : Filter.Tendsto (fun n : ℕ => Real.log (n + 2) - Real.log (n + 1)) Filter.atTop (nhds (0 : ℝ))) :
    Set.Ico (0 : ℝ) 1 ⊆ Set.closure (Set.range fun n : ℕ => Int.fract (Real.log (n + 1))) := by
  sorry