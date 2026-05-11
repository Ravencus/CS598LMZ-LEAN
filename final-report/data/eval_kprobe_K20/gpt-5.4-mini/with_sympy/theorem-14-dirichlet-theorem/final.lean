import Mathlib

theorem irrational_approximation_by_positive_integer
    {α ε : ℝ} (hα : Irrational α) (hε : 0 < ε) :
    ∃ q : ℕ, 0 < q ∧ ∃ p : ℤ, |(q : ℝ) * α - p| < ε := by
  rcases exists_nat_gt (1 / ε) with ⟨n, hn⟩
  have hnpos : 0 < n := by
    have hpos : (0 : ℝ) < (n : ℝ) := lt_trans (one_div_pos.mpr hε) hn
    exact_mod_cast hpos
  have h1 : 1 / ε < (n : ℝ) + 1 := by
    have hn1 : (n : ℝ) < (n : ℝ) + 1 := by linarith
    exact lt_trans hn hn1
  have hbound' : 1 / ((n : ℝ) + 1) < 1 / (1 / ε) :=
    one_div_lt_one_div_of_lt (one_div_pos.mpr hε) h1
  have hεeq : (1 / (1 / ε) : ℝ) = ε := by
    field_simp [hε.ne']
  have hbound : 1 / ((n : ℝ) + 1) < ε := by
    simpa [hεeq] using hbound'
  rcases Real.exists_nat_abs_mul_sub_round_le α hnpos with ⟨q, hqpos, _hqle, hqerr⟩
  refine ⟨q, hqpos, round ((q : ℝ) * α), lt_of_le_of_lt hqerr hbound⟩