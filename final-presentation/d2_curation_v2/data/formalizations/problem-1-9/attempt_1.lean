import Mathlib

open MeasureTheory

structure ComplexTrigPoly where
  coeffs : ℤ → ℂ
  support : Finset ℤ

def ComplexTrigPoly.eval (P : ComplexTrigPoly) (x : ℝ) : ℂ :=
  ∑ n in P.support, P.coeffs n * Complex.exp (((n : ℂ) * (x : ℂ)) * Complex.I)

abbrev intervalMeasure (a b : ℝ) : Measure ℝ :=
  Measure.restrict volume (Set.Icc a b)

theorem complexTrigonometricPolynomials_dense_Lp_interval
    {a b : ℝ} {p : ℝ≥0∞}
    (hp1 : (1 : ℝ≥0∞) ≤ p) (hp_top : p < ⊤) :
    ∃ T : ComplexTrigPoly → MeasureTheory.Lp ℂ p (intervalMeasure a b), DenseRange T := by
  sorry