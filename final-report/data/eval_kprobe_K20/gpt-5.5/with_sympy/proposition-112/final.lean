import Mathlib

open scoped BigOperators

theorem sum_reciprocal_n_mul_pred_lt_one (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) < 1 := by
  have hsum : Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) = 1 - (1 : ℚ) / N := by
    induction N, hN using Nat.le_induction with
    | base =>
        norm_num
    | succ N hN ih =>
        rw [Finset.sum_Icc_succ_top (by omega : 2 ≤ N + 1)]
        rw [ih]
        have hNq : (N : ℚ) ≠ 0 := by exact_mod_cast (ne_of_gt (lt_of_lt_of_le (by norm_num : 0 < 2) hN))
        have hN1q : ((N + 1 : ℕ) : ℚ) ≠ 0 := by exact_mod_cast (Nat.succ_ne_zero N)
        have hNm1q : (((N + 1 - 1 : ℕ) : ℚ)) = (N : ℚ) := by
          rw [Nat.add_sub_cancel]
        rw [hNm1q]
        field_simp [hNq, hN1q]
        push_cast
        ring
  rw [hsum]
  have hNqpos : (0 : ℚ) < N := by exact_mod_cast (lt_of_lt_of_le (by norm_num : 0 < 2) hN)
  have hdivpos : (0 : ℚ) < (1 : ℚ) / N := by positivity
  linarith