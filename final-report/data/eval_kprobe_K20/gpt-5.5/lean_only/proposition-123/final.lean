import Mathlib

theorem factorial_sum_identity (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.range (N + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
        (1 : ℚ) / (((N * N.factorial : ℕ) : ℕ) : ℚ) =
      (3 : ℚ) -
        Finset.sum (Finset.Icc 1 (N - 1))
          (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) := by
  refine Nat.le_induction ?base ?step N hN
  · norm_num [Finset.sum_range_succ, Nat.factorial]
  · intro n hn ih
    have hnpos : 0 < n := by omega
    have hn1 : 1 ≤ n := by omega
    have htop : n + 1 - 1 = n := by omega
    rw [htop]
    rw [Finset.sum_range_succ]
    have hIcc :
        Finset.sum (Finset.Icc 1 n)
          (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) =
        Finset.sum (Finset.Icc 1 (n - 1))
          (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) +
        (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ) := by
      conv_lhs => rw [← Nat.sub_add_cancel hn1]
      rw [Finset.sum_Icc_succ_top]
      · simp [Nat.sub_add_cancel hn1]
      · omega
    rw [hIcc]
    have hcorr :
        (1 : ℚ) / ((n + 1).factorial : ℚ) +
          (1 : ℚ) / (((n + 1) * (n + 1).factorial : ℕ) : ℚ) =
        (1 : ℚ) / (((n * n.factorial : ℕ) : ℕ) : ℚ) -
          (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ) := by
      rw [Nat.factorial_succ]
      push_cast
      field_simp [hnpos]
      ring
    calc
      Finset.sum (Finset.range (n + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
            (1 : ℚ) / (((n + 1).factorial : ℕ) : ℚ) +
          (1 : ℚ) / (((n + 1) * (n + 1).factorial : ℕ) : ℚ) =
          Finset.sum (Finset.range (n + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
            ((1 : ℚ) / (((n * n.factorial : ℕ) : ℕ) : ℚ) -
          (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ)) := by
            rw [← hcorr]
            ring
      _ = (Finset.sum (Finset.range (n + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
            (1 : ℚ) / (((n * n.factorial : ℕ) : ℕ) : ℚ)) -
          (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ) := by ring
      _ = ((3 : ℚ) - Finset.sum (Finset.Icc 1 (n - 1))
          (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ))) -
          (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ) := by rw [ih]
      _ = (3 : ℚ) -
          (Finset.sum (Finset.Icc 1 (n - 1))
          (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) +
          (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ)) := by ring