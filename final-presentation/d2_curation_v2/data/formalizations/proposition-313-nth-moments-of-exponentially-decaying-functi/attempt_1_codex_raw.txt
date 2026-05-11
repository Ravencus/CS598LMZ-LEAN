import Mathlib

open MeasureTheory

theorem commonMomentFormulas
    (a : ℝ) (ha : 0 < a) (n : ℕ) (hn : 1 ≤ n) :
    (∫ x in Set.Ioi (0 : ℝ), Real.exp (-a * x) * x ^ n ∂volume) =
        Real.Gamma (n + 1) / a ^ (n + 1) ∧
    (∫ x in Set.Ioi (0 : ℝ), Real.exp (-a * x ^ (2 : ℕ)) * x ^ n ∂volume) =
        Real.Gamma (((n : ℝ) + 1) / 2) / (2 * Real.rpow a (((n : ℝ) + 1) / 2)) ∧
    Complex.ofReal (∫ x in Set.Ioi (0 : ℝ), x ^ n / (Real.exp x - 1) ∂volume) =
        Complex.Gamma (n + 1) * riemannZeta (n + 1) ∧
    Complex.ofReal (∫ x in Set.Ioi (0 : ℝ), x ^ n / (Real.exp x + 1) ∂volume) =
        (1 - (((2 : ℂ) ^ n)⁻¹)) * Complex.Gamma (n + 1) * riemannZeta (n + 1) := by
  sorry