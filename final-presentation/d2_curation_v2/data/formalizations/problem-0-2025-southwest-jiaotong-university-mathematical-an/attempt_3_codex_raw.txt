import Mathlib

theorem sin_nat_limit_does_not_exist :
    ¬ ∃ l : ℝ, Filter.Tendsto (fun n : ℕ => Real.sin (n : ℝ)) Filter.atTop (Filter.nhds l) := by
  sorry