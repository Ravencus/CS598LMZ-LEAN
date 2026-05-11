import Mathlib

theorem irrational_approximation_by_positive_integer
    {α ε : ℝ} (hα : Irrational α) (hε : 0 < ε) :
    ∃ q : ℕ, 0 < q ∧ ∃ p : ℤ, |(q : ℝ) * α - p| < ε := by
  obtain ⟨n, hn⟩ := exists_nat_gt (1 / ε)
  have n_pos : 0 < n := by
    have h1 : (0 : ℝ) < n := lt_of_le_of_lt (by positivity) hn
    exact_mod_cast h1
  obtain ⟨j, k, hk_pos, _, hk_bd⟩ := Real.exists_int_int_abs_mul_sub_le α n_pos
  have hnp1 : (0 : ℝ) < n + 1 := by positivity
  have hinv : 1 / ((n : ℝ) + 1) < ε := by
    rw [div_lt_iff₀ hnp1]
    rw [div_lt_iff₀ hε] at hn
    linarith
  refine ⟨k.toNat, ?_, j, ?_⟩
  · have : k.toNat = k := Int.toNat_of_nonneg hk_pos.le
    omega
  · have hk_cast : ((k.toNat : ℤ) : ℝ) = (k : ℝ) := by
      rw [Int.toNat_of_nonneg hk_pos.le]
    have : ((k.toNat : ℕ) : ℝ) = (k : ℝ) := by
      have h := Int.toNat_of_nonneg hk_pos.le
      exact_mod_cast h
    rw [this]
    exact lt_of_le_of_lt hk_bd hinv