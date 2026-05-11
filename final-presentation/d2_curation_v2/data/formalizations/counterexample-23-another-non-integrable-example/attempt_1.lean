import Mathlib

open MeasureTheory
open scoped ENNReal

noncomputable section

def f (x y : ℝ) : ℝ :=
  if 0 < x ∧ x < y ∧ y < 1 then
    1 / y ^ 2
  else if 0 < y ∧ y < x ∧ x < 1 then
    -(1 / x ^ 2)
  else
    0

def I : Set ℝ := Set.Icc 0 1

theorem mainTheorem :
    (∫⁻ x in I, ∫⁻ y in I, ENNReal.ofReal (|f x y|) ∂volume ∂volume) = ∞ ∧
    ¬ Integrable (fun p : ℝ × ℝ => f p.1 p.2) ∧
    (∫ x in I, ∫ y in I, f x y ∂volume ∂volume) ≠
      (∫ y in I, ∫ x in I, f x y ∂volume ∂volume) := by
  sorry