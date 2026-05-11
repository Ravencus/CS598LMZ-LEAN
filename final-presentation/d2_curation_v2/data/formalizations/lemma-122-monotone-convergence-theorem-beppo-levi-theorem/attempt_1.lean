import Mathlib

open scoped ENNReal BigOperators

open MeasureTheory

theorem monotone_convergence_measurable_lintegral
    {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (f : ℕ → α → ℝ≥0∞)
    (hf_meas : ∀ n, Measurable (f n))
    (hf_mono : Monotone f) :
    Measurable (fun x => ⨆ n, f n x) ∧
      (⨆ n, ∫⁻ x, f n x ∂μ) = ∫⁻ x, ⨆ n, f n x ∂μ := by
  sorry