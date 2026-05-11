import Mathlib

noncomputable def irrationalityMeasure (x : ℝ) : ℝ :=
  sInf {μ : ℝ |
    ∀ ε > 0, ∃ C > 0, ∀ p : ℤ, ∀ q : ℕ, q > 0 →
      C / (q : ℝ) ^ (μ + ε) ≤ |x - (p : ℝ) / (q : ℝ)|}

theorem rational_irrationalityMeasure_eq_one (q : ℚ) :
    irrationalityMeasure (q : ℝ) = 1 := by
  sorry