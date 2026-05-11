import Mathlib

open scoped BigOperators

theorem sum_reciprocal_n_mul_pred_lt_one (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) < 1 := by
  have htel :
      ∀ m : ℕ,
        Finset.sum (Finset.range m)
          (fun k : ℕ => (1 : ℚ) / ((k + 1 : ℕ) : ℚ) - 1 / ((k + 2 : ℕ) : ℚ))
          = 1 - 1 / ((m + 1 : ℕ) : ℚ) := by
    intro m
    induction m with
    | zero =>
        simp
    | succ m ih =>
        rw [Finset.sum_range_succ, ih]
        have hm1 : ((m + 1 : ℕ) : ℚ) ≠ 0 := by norm_num
        have hm2 : ((m + 2 : ℕ) : ℚ) ≠ 0 := by norm_num
        field_simp [hm1, hm2]
        ring
  have hterm :
      ∀ k : ℕ,
        (1 : ℚ) / (((k + 2 : ℕ) : ℚ) * ((k + 1 : ℕ) : ℚ))
          = (1 : ℚ) / ((k + 1 : ℕ) : ℚ) - 1 / ((k + 2 : ℕ) : ℚ) := by
    intro k
    have hk1 : ((k + 1 : ℕ) : ℚ) ≠ 0 := by norm_num
    have hk2 : ((k + 2 : ℕ) : ℚ) ≠ 0 := by norm_num
    field_simp [hk1, hk2]
    ring
  have hsum :
      Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ)))
        = 1 - 1 / (N : ℚ) := by
    calc
      Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ)))
          = ∑ k in Finset.range (N - 1),
              (1 : ℚ) / (((2 + k : ℕ) : ℚ) * ((2 + k - 1 : ℕ) : ℚ)) := by
              rw [Finset.sum_Icc_eq_sum_range]
              have hlen : N + 1 - 2 = N - 1 := by omega
              rw [hlen]
      _ = ∑ k in Finset.range (N - 1),
              (1 : ℚ) / (((k + 2 : ℕ) : ℚ) * ((k + 1 : ℕ) : ℚ)) := by
            refine Finset.sum_congr rfl ?_
            intro k hk
            have hk1 : 2 + k - 1 = k + 1 := by omega
            simp [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc, hk1]
      _ = ∑ k in Finset.range (N - 1),
              ((1 : ℚ) / ((k + 1 : ℕ) : ℚ) - 1 / ((k + 2 : ℕ) : ℚ)) := by
            refine Finset.sum_congr rfl ?_
            intro k hk
            exact hterm k
      _ = 1 - 1 / (N : ℚ) := by
            have hN1 : (N - 1 + 1 : ℕ) = N := by omega
            simpa [hN1] using htel (N - 1)
  have hNpos : (0 : ℚ) < (N : ℚ) := by
    have hNposNat : 0 < N := by omega
    exact_mod_cast hNposNat
  have hfrac : 0 < (1 : ℚ) / (N : ℚ) := by
    exact one_div_pos.mpr hNpos
  have hlt : 1 - 1 / (N : ℚ) < 1 := by
    nlinarith
  simpa [hsum] using hlt