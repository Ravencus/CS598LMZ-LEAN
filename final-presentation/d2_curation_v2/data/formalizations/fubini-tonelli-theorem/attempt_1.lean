import Mathlib

open MeasureTheory

theorem fubini_tonelli_real
    {α β : Type*} [MeasurableSpace α] [MeasurableSpace β]
    (μ : Measure α) (ν : Measure β) (f : α × β → ℝ) :
    (((Integrable f (μ := μ.prod ν)) →
        (∫ z, f z ∂ (μ.prod ν)) = ∫ x, ∫ y, f (x, y) ∂ν ∂μ
          ∧
        (∫ z, f z ∂ (μ.prod ν)) = ∫ y, ∫ x, f (x, y) ∂μ ∂ν)
      ∧
      (((Measurable f) ∧ ∀ z, 0 ≤ f z) →
        (∫⁻ z, ENNReal.ofReal (f z) ∂ (μ.prod ν)) = ∫⁻ x, ∫⁻ y, ENNReal.ofReal (f (x, y)) ∂ν ∂μ
          ∧
        (∫⁻ z, ENNReal.ofReal (f z) ∂ (μ.prod ν)) = ∫⁻ y, ∫⁻ x, ENNReal.ofReal (f (x, y)) ∂μ ∂ν)) := by
  sorry