import Mathlib

theorem factorial_sum_identity (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.range (N + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
        (1 : ℚ) / (((N * N.factorial : ℕ) : ℕ) : ℚ) =
      (3 : ℚ) -
        Finset.sum (Finset.Icc 1 (N - 1))
          (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) := by
  induction N, hN using Nat.le_induction with
  | base =>
    simp only [Finset.sum_range_succ, Finset.range_one, Finset.sum_singleton,
               show (2 : ℕ) - 1 = 1 from rfl, Finset.Icc_self, Finset.sum_singleton]
    norm_num [Nat.factorial]
  | succ N hN ih =>
    have hN1 : (N + 1) - 1 = N := by omega
    have hIcc : Finset.Icc 1 ((N+1) - 1) = insert N (Finset.Icc 1 (N - 1)) := by
      rw [hN1]
      ext x
      simp [Finset.mem_Icc, Finset.mem_insert]
      omega
    rw [hIcc]
    rw [Finset.sum_insert (by simp [Finset.mem_Icc]; omega)]
    rw [Finset.sum_range_succ]
    have hfac : (N+1).factorial = (N+1) * N.factorial := Nat.factorial_succ N
    push_cast [hfac] at ih ⊢
    have hNfac_pos : (N.factorial : ℚ) > 0 := by exact_mod_cast Nat.factorial_pos N
    have hN_pos : (N : ℚ) > 0 := by exact_mod_cast (by omega : 0 < N)
    have hN1_pos : ((N : ℚ) + 1) > 0 := by linarith
    have key : (1 : ℚ) / ((↑N + 1) * ↑N.factorial) + 1 / ((↑N + 1) * ((↑N + 1) * ↑N.factorial))
             - 1 / (↑N * ↑N.factorial) + 1 / (↑N * (↑N + 1) * ((↑N + 1) * ↑N.factorial)) = 0 := by
      field_simp
      ring
    linarith [ih, key]