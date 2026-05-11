import Mathlib

theorem irrational_approximation_by_positive_integer
    {α ε : ℝ} (hα : Irrational α) (hε : 0 < ε) :
    ∃ q : ℕ, 0 < q ∧ ∃ p : ℤ, |(q : ℝ) * α - p| < ε := by
  obtain ⟨q, hqpos, p, hp⟩ :=
    exists_nat_pos_mul_sub_int_lt hα hε
  exact ⟨q, hqpos, p, by simpa [mul_comm] using hp⟩