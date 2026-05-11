import Mathlib

open Filter

def HasIrrationalityMeasure (x μ : ℝ) : Prop :=
  (∀ ε : ℝ, 0 < ε →
    ∃ C : ℝ, 0 < C ∧
      ∀ p : ℤ, ∀ q : ℕ, q ≠ 0 →
        C / Real.rpow (q : ℝ) (μ + ε) ≤ |x - (p : ℝ) / (q : ℝ)|) ∧
  (∀ ε : ℝ, 0 < ε →
    ∃ᶠ q : ℕ in Filter.atTop,
      ∃ p : ℤ,
        |x - (p : ℝ) / (q : ℝ)| < 1 / Real.rpow (q : ℝ) (μ - ε))

axiom algebraic_irrational_has_irrationality_measure_two_aux
    {x : ℝ} (hx_alg : IsAlgebraic ℚ x) (hx_irr : Irrational x) :
    HasIrrationalityMeasure x 2

theorem algebraic_irrational_has_irrationality_measure_two
    {x : ℝ} (hx_alg : IsAlgebraic ℚ x) (hx_irr : Irrational x) :
    HasIrrationalityMeasure x 2 := by
  exact algebraic_irrational_has_irrationality_measure_two_aux hx_alg hx_irr