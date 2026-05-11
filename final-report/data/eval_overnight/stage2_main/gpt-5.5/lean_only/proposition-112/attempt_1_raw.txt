import Mathlib

open scoped BigOperators

theorem sum_reciprocal_n_mul_pred_lt_one (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) < 1 := by
  have hsum :
      Finset.sum (Finset.Icc 2 N)
          (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) =
        1 - (1 : ℚ) / (N : ℚ) := by
    refine Nat.le_induction ?base ?step N hN
    · norm_num
    · intro n hn ih
      rw [Finset.sum_Icc_succ_top hn, ih]
      have hnq : (n : ℚ) ≠ 0 := by
        exact_mod_cast (ne_of_gt (lt_of_lt_of_le (by norm_num : 0 < 2) hn))
      have hsnq : ((n + 1 : ℕ) : ℚ) ≠ 0 := by
        exact_mod_cast (Nat.succ_ne_zero n)
      have hn1q : (((n + 1 - 1 : ℕ) : ℚ)) = (n : ℚ) := by
        rw [Nat.add_sub_cancel]
      rw [hn1q]
      field_simp [hnq, hsnq]
      ring
  rw [hsum]
  have hNqpos : (0 : ℚ) < (N : ℚ) := by
    exact_mod_cast (lt_of_lt_of_le (by norm_num : 0 < 2) hN)
  have hrecpos : (0 : ℚ) < (1 : ℚ) / (N : ℚ) := by
    positivity
  linarith