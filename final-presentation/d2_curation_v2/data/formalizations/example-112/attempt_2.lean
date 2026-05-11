import Mathlib

noncomputable def absCosTwoPi (t : ℝ) : ℝ := |Real.cos (2 * Real.pi * t)|

theorem cosineIntegerIntervalSum_linearBound_but_not_O_one :
    (∃ C : ℝ, 0 < C ∧ ∀ x y : ℕ,
      |(∑ n in Finset.Ioc y x, Real.cos (2 * Real.pi * (n : ℝ)))| ≤ C * ((x - y : ℕ) : ℝ))
    ∧
    ¬ (∃ C : ℝ, 0 < C ∧ ∀ x y : ℕ,
      |(∑ n in Finset.Ioc y x, Real.cos (2 * Real.pi * (n : ℝ)))| ≤ C) := by
  sorry