import Mathlib

noncomputable section

open Real MeasureTheory IntervalIntegral

def I (a : ℝ) : ℝ :=
  ∫ x in (0 : ℝ)..1, Real.cos (a * x) / Real.sqrt (1 - x ^ 2)

theorem compute_parameter_dependent_integral (a : ℝ) :
    I a = ∫ x in (0 : ℝ)..1, Real.cos (a * x) / Real.sqrt (1 - x ^ 2) := by
  sorry