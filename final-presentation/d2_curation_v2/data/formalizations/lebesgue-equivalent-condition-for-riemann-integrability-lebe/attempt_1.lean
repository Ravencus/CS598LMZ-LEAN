import Mathlib

theorem bounded_riemann_integrable_iff_ae_continuousWithinAt
    {a b : ℝ} {f : ℝ → ℝ}
    (hbounded : ∃ C : ℝ, ∀ x ∈ Set.Icc a b, ‖f x‖ ≤ C) :
    IntervalIntegrable f volume a b ↔
      ∀ᵐ x ∂(volume.restrict (Set.Icc a b)), ContinuousWithinAt f (Set.Icc a b) x := by
  sorry