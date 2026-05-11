import Mathlib

noncomputable section

open scoped BigOperators
open MeasureTheory

def HasAbsolutelyConvergentFourierSeries (F : Real.Angle → ℂ) : Prop :=
  ∃ c : ℤ → ℂ, Summable (fun n => ‖c n‖)

def polynomialOrbitSum (P : Polynomial ℝ) (F : Real.Angle → ℂ) (N : ℕ) : ℂ :=
  Finset.sum (Finset.Icc 1 N) (fun n => F (Real.Angle.ofReal (P.eval (n : ℝ))))

theorem polynomial_orbit_sums_unbounded
    [MeasurableSpace Real.Angle]
    (P : Polynomial ℝ) (F : Real.Angle → ℂ) (μ : Measure Real.Angle)
    (hdeg : 2 ≤ P.natDegree)
    (hirr : ∃ k : ℕ, 2 ≤ k ∧ k ≤ P.natDegree ∧ Irrational (P.coeff k))
    (hF : HasAbsolutelyConvergentFourierSeries F)
    (h_int : ∫ x, F x ∂μ = 0) :
    ∀ C : ℝ, ∃ N : ℕ, C < ‖polynomialOrbitSum P F N‖ := by
  sorry