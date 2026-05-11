import Mathlib

theorem irrational_approximation_by_positive_integer
    {α ε : ℝ} (hα : Irrational α) (hε : 0 < ε) :
    ∃ q : ℕ, 0 < q ∧ ∃ p : ℤ, |(q : ℝ) * α - p| < ε := by
  rcases hα.exists_nat_abs_sub_lt hε with ⟨q, hq, p, hp⟩
  exact ⟨q, hq, p, hp⟩