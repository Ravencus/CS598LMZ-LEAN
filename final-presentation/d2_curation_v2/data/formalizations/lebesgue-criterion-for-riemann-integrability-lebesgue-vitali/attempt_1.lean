import Mathlib

theorem riemannIntegrable_iff_continuous_ae_on_Icc
    {a b : ℝ} {f : ℝ → ℝ}
    (h_bounded : ∃ C : ℝ, ∀ x ∈ Set.Icc a b, ‖f x‖ ≤ C) :
    IntervalIntegrable f volume a b ↔
      ∀ᵐ x ∂(volume.restrict (Set.Icc a b)), ContinuousAt f x := by
  sorry