import Mathlib

open MeasureTheory

theorem boundedVariation_continuous_ae_on_Icc
    (a b : ℝ) (hab : a ≤ b) (f : ℝ → ℝ)
    (hf : BoundedVariationOn f (Set.Icc a b)) :
    ∀ᵐ x ∂(volume.restrict (Set.Icc a b)), ContinuousWithinAt f (Set.Icc a b) x := by
  sorry