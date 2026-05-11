import Mathlib

theorem irrational_exists_infinitely_many_good_denominators
    (α : ℝ) (hα : Irrational α) :
    Set.Infinite {q : ℕ | 0 < q ∧ ∃ p : ℤ, (q : ℝ) * |(q : ℝ) * α - (p : ℝ)| < 1} := by
  sorry