import Mathlib

noncomputable def I (J0 : ℝ → ℝ) (a b : ℝ) : ℝ :=
  ∫ x in Set.Ici (0 : ℝ), Real.exp (-a * x) * J0 (b * x) ∂volume

theorem besselJ0_parameter_dependent_integral
    (J0 : ℝ → ℝ) (a b : ℝ) (ha : 0 < a) (hab : |b| < a) :
    I J0 a b = 1 / Real.sqrt (a ^ 2 + b ^ 2) := by
  sorry