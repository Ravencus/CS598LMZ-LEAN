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

axiom algebraic_irrational_lower_bound
    {x : ℝ} (hx_alg : IsAlgebraic ℚ x) (hx_irr : Irrational x)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ C : ℝ, 0 < C ∧
      ∀ p : ℤ, ∀ q : ℕ, q ≠ 0 →
        C / Real.rpow (q : ℝ) (2 + ε) ≤ |x - (p : ℝ) / (q : ℝ)|

axiom irrational_frequently_good_rational_approximations
    {x : ℝ} (hx_irr : Irrational x)
    (ε : ℝ) (hε : 0 < ε) :
    ∃ᶠ q : ℕ in Filter.atTop,
      ∃ p : ℤ,
        |x - (p : ℝ) / (q : ℝ)| < 1 / Real.rpow (q : ℝ) (2 - ε)

theorem algebraic_irrational_has_irrationality_measure_two
    {x : ℝ} (hx_alg : IsAlgebraic ℚ x) (hx_irr : Irrational x) :
    HasIrrationalityMeasure x 2 := by
  constructor
  · intro ε hε
    exact algebraic_irrational_lower_bound hx_alg hx_irr ε hε
  · intro ε hε
    exact irrational_frequently_good_rational_approximations hx_irr ε hε