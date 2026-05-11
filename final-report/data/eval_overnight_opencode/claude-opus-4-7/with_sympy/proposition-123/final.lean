import Mathlib

theorem factorial_sum_identity (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.range (N + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
        (1 : ℚ) / (((N * N.factorial : ℕ) : ℕ) : ℚ) =
      (3 : ℚ) -
        Finset.sum (Finset.Icc 1 (N - 1))
          (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) := by
  induction N, hN using Nat.le_induction with
  | base =>
    rw [show (2 : ℕ) - 1 = 1 from rfl]
    rw [show Finset.Icc 1 1 = {1} from rfl]
    simp [Finset.sum_range_succ, Nat.factorial]
    norm_num
  | succ N hN ih =>
    have hN1 : N + 1 - 1 = N := by omega
    have hN_pos : 1 ≤ N := by omega
    rw [Finset.sum_range_succ]
    rw [show N + 1 - 1 = N from hN1]
    have hsplit : Finset.Icc 1 N = Finset.Icc 1 (N-1) ∪ {N} := by
      ext k
      simp [Finset.mem_Icc]
      omega
    rw [hsplit]
    rw [Finset.sum_union (by rw [Finset.disjoint_singleton_right]; simp [Finset.mem_Icc]; omega)]
    rw [Finset.sum_singleton]
    have key : (1 : ℚ) / ((N+1).factorial : ℚ) + 1 / (((N+1) * (N+1).factorial : ℕ) : ℚ)
               - 1 / ((N * N.factorial : ℕ) : ℚ)
               = - 1 / ((N * (N+1) * (N+1).factorial : ℕ) : ℚ) := by
      have hN0 : (N : ℚ) ≠ 0 := by exact_mod_cast (by omega : N ≠ 0)
      have hN1q : (N : ℚ) + 1 ≠ 0 := by positivity
      have hfact : (N.factorial : ℚ) ≠ 0 := by
        exact_mod_cast Nat.factorial_pos N |>.ne'
      have hfact1 : ((N+1).factorial : ℚ) ≠ 0 := by
        exact_mod_cast Nat.factorial_pos (N+1) |>.ne'
      push_cast [Nat.factorial_succ]
      field_simp
      ring
    linear_combination ih + key