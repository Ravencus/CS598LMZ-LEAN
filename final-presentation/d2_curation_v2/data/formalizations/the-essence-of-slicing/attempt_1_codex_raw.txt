import Mathlib

open MeasureTheory

theorem fubini_measurable_slices
    {d₁ d₂ : ℕ}
    {E : Set (EuclideanSpace ℝ (Fin d₁) × EuclideanSpace ℝ (Fin d₂))}
    (hE : MeasurableSet E) :
    (∀ᵐ y ∂(volume : Measure (EuclideanSpace ℝ (Fin d₂))),
        MeasurableSet {x : EuclideanSpace ℝ (Fin d₁) | (x, y) ∈ E}) ∧
    Measurable (fun y : EuclideanSpace ℝ (Fin d₂) =>
      (volume : Measure (EuclideanSpace ℝ (Fin d₁)))
        {x : EuclideanSpace ℝ (Fin d₁) | (x, y) ∈ E}) ∧
    (volume : Measure (EuclideanSpace ℝ (Fin d₁) × EuclideanSpace ℝ (Fin d₂))) E =
      ∫⁻ y : EuclideanSpace ℝ (Fin d₂),
        (volume : Measure (EuclideanSpace ℝ (Fin d₁)))
          {x : EuclideanSpace ℝ (Fin d₁) | (x, y) ∈ E}
          ∂(volume : Measure (EuclideanSpace ℝ (Fin d₂))) ∧
    (∀ᵐ x ∂(volume : Measure (EuclideanSpace ℝ (Fin d₁))),
        MeasurableSet {y : EuclideanSpace ℝ (Fin d₂) | (x, y) ∈ E}) ∧
    Measurable (fun x : EuclideanSpace ℝ (Fin d₁) =>
      (volume : Measure (EuclideanSpace ℝ (Fin d₂)))
        {y : EuclideanSpace ℝ (Fin d₂) | (x, y) ∈ E}) ∧
    (volume : Measure (EuclideanSpace ℝ (Fin d₁) × EuclideanSpace ℝ (Fin d₂))) E =
      ∫⁻ x : EuclideanSpace ℝ (Fin d₁),
        (volume : Measure (EuclideanSpace ℝ (Fin d₂)))
          {y : EuclideanSpace ℝ (Fin d₂) | (x, y) ∈ E}
          ∂(volume : Measure (EuclideanSpace ℝ (Fin d₁))) := by
  sorry