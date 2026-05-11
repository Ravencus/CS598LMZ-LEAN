import Mathlib

theorem sin_pow_two_does_not_have_limit :
    ¬ ∃ l : ℝ, Filter.Tendsto (fun n : ℕ => Real.sin ((2 : ℝ) ^ n)) Filter.atTop (nhds l) := by
  sorry