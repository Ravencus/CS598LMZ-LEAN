import Mathlib

theorem irrational_approximation_infinitely_many_multiples
    {α ε : ℝ} (hα : Irrational α) (hε : 0 < ε) :
    Set.Infinite {q : ℕ | 0 < q ∧ ∃ z : ℤ, |(q : ℝ) * α - (z : ℝ)| < ε} := by
  sorry