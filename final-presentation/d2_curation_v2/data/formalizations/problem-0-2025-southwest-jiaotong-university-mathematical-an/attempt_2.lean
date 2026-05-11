import Mathlib

theorem sin_nat_limit_does_not_exist :
    ¬ ∃ l : ℝ, Filter.Tendsto (fun n : ℕ => Real.sin (n : ℝ)) Filter.atTop (𝓝 l) := by
  sorry