import Mathlib

theorem irrational_approximation_by_positive_integer
    {α ε : ℝ} (hα : Irrational α) (hε : 0 < ε) :
    ∃ q : ℕ, 0 < q ∧ ∃ p : ℤ, |(q : ℝ) * α - p| < ε := by
  have _ : Irrational α := hα
  obtain ⟨n, hn_gt⟩ := exists_nat_gt (1 / ε)
  have hn_pos : 0 < n := by
    have hpos : (0 : ℝ) < (n : ℝ) := lt_trans (one_div_pos.mpr hε) hn_gt
    exact Nat.cast_pos.mp hpos
  have hden_pos : (0 : ℝ) < (n : ℝ) + 1 := by positivity
  have hbound : (1 : ℝ) / ((n : ℝ) + 1) < ε := by
    have hlt : 1 / ε < (n : ℝ) + 1 := lt_trans hn_gt (lt_add_one _)
    have hmul : (1 : ℝ) < ε * ((n : ℝ) + 1) := by
      calc
        (1 : ℝ) = ε * (1 / ε) := by field_simp [hε.ne']
        _ < ε * ((n : ℝ) + 1) := mul_lt_mul_of_pos_left hlt hε
    exact (div_lt_iff₀ hden_pos).mpr hmul
  obtain ⟨j, k, hk0, hk_le, habs⟩ := Real.exists_int_int_abs_mul_sub_le α hn_pos
  have hk_nat_int : (k.toNat : ℤ) = k := Int.toNat_of_nonneg hk0.le
  have hq_pos_int : (0 : ℤ) < (k.toNat : ℤ) := by simpa [hk_nat_int] using hk0
  have hq_pos : 0 < k.toNat := by exact_mod_cast hq_pos_int
  refine ⟨k.toNat, hq_pos, ⟨j, ?_⟩⟩
  have hk_real : ((k.toNat : ℕ) : ℝ) = (k : ℝ) := by exact_mod_cast hk_nat_int
  calc
    |(k.toNat : ℝ) * α - j| = |(k : ℝ) * α - j| := by rw [hk_real]
    _ ≤ (1 : ℝ) / ((n : ℝ) + 1) := habs
    _ < ε := hbound