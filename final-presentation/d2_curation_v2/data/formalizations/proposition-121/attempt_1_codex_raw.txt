import Mathlib

theorem series_converges_exists_limit :
    let a : ℕ → ℝ := fun n => 1 / (((n + 1 : ℝ) * (n + 2)) * ((n + 2)! : ℝ))
    let T : ℕ → ℝ := fun N => ∑ n in Finset.range (N + 1), a n
    ∃ l : ℝ, Filter.Tendsto T Filter.atTop (nhds l) := by
  sorry