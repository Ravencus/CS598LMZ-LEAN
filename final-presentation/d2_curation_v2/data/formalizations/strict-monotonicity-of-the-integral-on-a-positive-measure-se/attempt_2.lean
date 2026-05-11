import Mathlib

theorem integral_pos_of_ae_pos_on_measurableSet
    {α : Type*} [MeasurableSpace α] {μ : MeasureTheory.Measure α} {E : Set α} {h : α → ℝ}
    (hE : MeasurableSet E) (hμE : 0 < μ E) (hint : MeasureTheory.IntegrableOn h E μ)
    (hpos : ∀ᵐ x ∂(μ.restrict E), 0 < h x) :
    0 < ∫ x in E, h x ∂μ := by
  sorry