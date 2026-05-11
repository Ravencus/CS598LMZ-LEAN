import Mathlib

open MeasureTheory

theorem lintegral_ofReal_eq_volume_subgraph
    {k : ℕ} (f : (Fin k → ℝ) → ℝ)
    (hf_meas : AEMeasurable f volume)
    (hf_nonneg : ∀ x, 0 ≤ f x) :
    ∫⁻ x, ENNReal.ofReal (f x) ∂volume
      = volume {p : (Fin k → ℝ) × ℝ | 0 ≤ p.2 ∧ p.2 ≤ f p.1} := by
  sorry