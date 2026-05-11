import Mathlib

theorem mainTheorem (T : ℕ → ℝ) :
    Filter.limsup T Filter.atTop = 1 ∧ Filter.liminf T Filter.atTop = 0 := by
  sorry