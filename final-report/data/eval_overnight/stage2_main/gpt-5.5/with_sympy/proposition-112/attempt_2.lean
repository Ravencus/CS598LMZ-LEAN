import Mathlib

open scoped BigOperators

theorem sum_reciprocal_n_mul_pred_lt_one (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) < 1 := by
  have hsum :
      Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ)))
        = 1 - (1 : ℚ) / (N : ℚ) := by
    induction N with
    | zero =>
        omega
    | succ N ih =>
        by_cases hN2 : 2 ≤ N
        · have hsucc : 2 ≤ N + 1 := by omega
          rw [Finset.sum_Icc_succ_top hsucc]
          rw [ih hN2]
          have hNpos : (N : ℚ) ≠ 0 := by
            norm_num
            omega
          have hN1pos : ((N + 1 : ℕ) : ℚ) ≠ 0 := by
            norm_num
          have hpred : ((N + 1 - 1 : ℕ) : ℚ) = (N : ℚ) := by
            rw [Nat.succ_sub_one]
          rw [hpred]
          field_simp [hNpos, hN1pos]
          ring_nf
        · have hNle : N ≤ 1 := by omega
          have hNeq : N = 1 := by omega
          subst N
          norm_num
  rw [hsum]
  have hNposNat : 0 < N := by omega
  have hNpos : (0 : ℚ) < (N : ℚ) := by
    exact_mod_cast hNposNat
  have hrecpos : (0 : ℚ) < 1 / (N : ℚ) := by
    positivity
  linarith