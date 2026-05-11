import Mathlib

theorem monotone_bounded_continuous_ae_on_Icc
    {a b : ℝ} {f : ℝ → ℝ}
    (hmono : MonotoneOn f (Set.Icc a b))
    (hbounded : ∃ C : ℝ, ∀ x ∈ Set.Icc a b, ‖f x‖ ≤ C) :
    ∀ᵐ x ∂(Measure.restrict volume (Set.Icc a b)), ContinuousWithinAt f (Set.Icc a b) x := by
  sorry