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

theorem algebraic_irrational_has_irrationality_measure_two
    {x : ℝ} (hx_alg : IsAlgebraic ℚ x) (hx_irr : Irrational x) :
    HasIrrationalityMeasure x 2 := by
  constructor
  · intro ε hε
    simpa using hx_alg.exists_pos_forall_le_rat_sub_of_irrational hx_irr ε hε
  · intro ε hε
    simpa using hx_irr.frequently_exists_int_sub_div_lt ε hε