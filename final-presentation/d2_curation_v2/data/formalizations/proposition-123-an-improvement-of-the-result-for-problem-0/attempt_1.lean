import Mathlib

theorem limsup_sin_square_partial_sums_div_sqrt_pos :
    let S : ℕ → ℝ := fun N => ∑ n in Finset.Icc 0 N, Real.sin ((n : ℝ) ^ 2)
    ∃ c : ℝ, 0 < c ∧ ∃ᶠ N : ℕ in Filter.atTop, c < |S N| / Real.sqrt (N : ℝ) := by
  sorry