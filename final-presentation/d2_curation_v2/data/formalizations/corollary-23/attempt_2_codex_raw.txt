import Mathlib

open MeasureTheory

abbrev UnitCirclePoint := {z : ℂ // ‖z‖ = 1}

noncomputable def fourierCoeffOnUnitCircle
    (μ : Measure UnitCirclePoint) (f : UnitCirclePoint → ℂ) (n : ℤ) : ℂ :=
  ∫ z, f z * ((z : ℂ) ^ n) ∂μ

theorem continuous_point_value_eq_zero_of_all_fourierCoeff_vanish
    (μ : Measure UnitCirclePoint) (f : UnitCirclePoint → ℂ)
    (hf : Integrable f μ)
    (hcoeff : ∀ n : ℤ, fourierCoeffOnUnitCircle μ f n = 0) :
    ∀ z : UnitCirclePoint, ContinuousAt f z → f z = 0 := by
  sorry