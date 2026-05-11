import Mathlib

theorem irrational_approximation_by_positive_integer
    {α ε : ℝ} (hα : Irrational α) (hε : 0 < ε) :
    ∃ q : ℕ, 0 < q ∧ ∃ p : ℤ, |(q : ℝ) * α - p| < ε := by
  simpa using hα.irrational_approximation hε