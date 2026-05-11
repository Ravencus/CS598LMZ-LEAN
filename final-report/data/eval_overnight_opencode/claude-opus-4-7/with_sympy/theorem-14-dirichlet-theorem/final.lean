import Mathlib

theorem irrational_approximation_by_positive_integer
    {α ε : ℝ} (hα : Irrational α) (hε : 0 < ε) :
    ∃ q : ℕ, 0 < q ∧ ∃ p : ℤ, |(q : ℝ) * α - p| < ε := by
  -- Choose n large enough so 1/(n+1) < ε
  obtain ⟨n, hn⟩ := exists_nat_gt (1 / ε)
  have hn_pos : 0 < n := by
    have : (0 : ℝ) < n := lt_of_le_of_lt (one_div_pos.mpr hε).le hn
    exact_mod_cast this
  -- Apply Dirichlet's approximation theorem
  obtain ⟨j, k, hk_pos, hk_le, h⟩ := Real.exists_int_int_abs_mul_sub_le α hn_pos
  refine ⟨k.toNat, ?_, j, ?_⟩
  · -- 0 < k.toNat since 0 < k
    rw [Int.lt_toNat] at *
    omega
  · have hkn : ((k.toNat : ℤ) : ℝ) = (k : ℝ) := by
      norm_cast
      exact Int.toNat_of_nonneg hk_pos.le
    have hcast : ((k.toNat : ℕ) : ℝ) = (k : ℝ) := by
      have := hkn
      push_cast at this
      exact this
    rw [hcast]
    have h1 : (1 : ℝ) / (n + 1) < ε := by
      have hn1 : (0 : ℝ) < (n : ℝ) + 1 := by positivity
      rw [div_lt_iff₀ hn1]
      have : 1 / ε < (n : ℝ) + 1 := by linarith
      rw [div_lt_iff₀ hε] at this
      linarith
    linarith [h]