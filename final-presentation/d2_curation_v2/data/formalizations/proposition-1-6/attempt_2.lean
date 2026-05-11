import Mathlib

theorem ae_zero_of_forall_set_integral_eq_zero
    {X : Type*} [MeasurableSpace X] {μ : MeasureTheory.Measure X} {f : X → ℝ}
    (hf : Measurable f)
    (hzero : ∀ E : Set X, MeasurableSet E → ∫ x in E, f x ∂μ = 0) :
    f =ᵐ[μ] fun _ => 0 := by
  sorry