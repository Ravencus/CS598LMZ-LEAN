import Mathlib

theorem factorial_sum_identity (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.range (N + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
        (1 : ℚ) / (((N * N.factorial : ℕ) : ℕ) : ℚ) =
      (3 : ℚ) -
        Finset.sum (Finset.Icc 1 (N - 1))
          (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) := by
  let P : ℕ → Prop := fun n =>
    Finset.sum (Finset.range (n + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
        (1 : ℚ) / (((n * n.factorial : ℕ) : ℕ) : ℚ) =
      (3 : ℚ) -
        Finset.sum (Finset.Icc 1 (n - 1))
          (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ))
  change P N
  refine Nat.le_induction ?base ?step N hN
  · norm_num [P]
  · intro n hn ih
    dsimp [P] at ih ⊢
    rw [Finset.sum_range_succ]
    have hn_top : n - 1 + 1 = n := by omega
    conv_rhs =>
      rw [← hn_top]
      rw [Finset.sum_Icc_succ_top (by omega)]
    simp only [hn_top]
    have h_alg :
        (1 : ℚ) / ((n + 1).factorial : ℚ) + (1 : ℚ) / (((n + 1) * (n + 1).factorial : ℕ) : ℚ) =
          (1 : ℚ) / ((n * n.factorial : ℕ) : ℚ) -
            (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ) := by
      rw [Nat.factorial_succ]
      norm_num [Nat.cast_add, Nat.cast_mul]
      field_simp [Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero n)]
      ring
    linarith