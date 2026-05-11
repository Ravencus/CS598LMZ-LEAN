import Mathlib

theorem factorial_sum_identity (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.range (N + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
        (1 : ℚ) / (((N * N.factorial : ℕ) : ℕ) : ℚ) =
      (3 : ℚ) -
        Finset.sum (Finset.Icc 1 (N - 1))
          (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) := by
  let Q : ℕ → Prop := fun n =>
    Finset.sum (Finset.range (n + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
        (1 : ℚ) / (((n * n.factorial : ℕ) : ℕ) : ℚ) =
      (3 : ℚ) -
        Finset.sum (Finset.Icc 1 (n - 1))
          (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ))
  have hQ : ∀ n, 2 ≤ n → Q n := by
    refine Nat.le_induction (P := fun n _ => Q n) ?base ?step N hN
    · dsimp [Q]
      norm_num [Finset.sum_range_succ, Nat.factorial_succ]
    · intro n hn ih
      dsimp [Q] at ih ⊢
      have hsum :
          Finset.sum (Finset.range (n + 2)) (fun k => (1 : ℚ) / (k.factorial : ℚ))
            = Finset.sum (Finset.range (n + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
                (1 : ℚ) / ((n + 1).factorial : ℚ) := by
        rw [show n + 2 = (n + 1) + 1 by omega, Finset.sum_range_succ]
      have hIcc :
          Finset.sum (Finset.Icc 1 n)
              (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) =
            Finset.sum (Finset.Icc 1 (n - 1))
              (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) +
              (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ) := by
        rw [show n = (n - 1) + 1 by omega, Finset.sum_Icc_succ_top]
        simp
      have hcalc (a b : ℚ) (ha : a ≠ 0) (hb : b ≠ 0) (hb1 : b - 1 ≠ 0) :
          (1 : ℚ) / (b * a) + (1 : ℚ) / (b * b * a) - (1 : ℚ) / ((b - 1) * a) =
            - (1 : ℚ) / ((b - 1) * b * b * a) := by
        field_simp [ha, hb, hb1]
        ring
      have ha : (n.factorial : ℚ) ≠ 0 := by
        exact_mod_cast Nat.factorial_ne_zero n
      have hb : ((n + 1 : ℕ) : ℚ) ≠ 0 := by
        exact_mod_cast Nat.succ_ne_zero n
      have hb1 : (n : ℚ) ≠ 0 := by
        exact_mod_cast (Nat.ne_of_gt (by omega : 0 < n))
      have hdelta :
          (1 : ℚ) / ((n + 1).factorial : ℚ) +
            (1 : ℚ) / (((n + 1) * (n + 1).factorial : ℕ) : ℚ) -
            (1 : ℚ) / (((n * n.factorial : ℕ) : ℕ) : ℚ) =
            - (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ) := by
        rw [Nat.factorial_succ]
        simpa [mul_comm, mul_left_comm, mul_assoc, sub_eq_add_neg] using
          (hcalc (a := (n.factorial : ℚ)) (b := (n + 1 : ℚ)) ha hb hb1)
      have hcombine :
          (1 : ℚ) / ((n + 1).factorial : ℚ) +
            (1 : ℚ) / (((n + 1) * (n + 1).factorial : ℕ) : ℚ) =
            (1 : ℚ) / (((n * n.factorial : ℕ) : ℕ) : ℚ) -
              (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ) := by
        linarith [hdelta]
      calc
        Finset.sum (Finset.range (n + 2)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
            (1 : ℚ) / (((n + 1) * (n + 1).factorial : ℕ) : ℚ)
          = Finset.sum (Finset.range (n + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
              ((1 : ℚ) / ((n + 1).factorial : ℚ) +
                (1 : ℚ) / (((n + 1) * (n + 1).factorial : ℕ) : ℚ)) := by
              rw [hsum, add_assoc]
        _ = Finset.sum (Finset.range (n + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
              ((1 : ℚ) / (((n * n.factorial : ℕ) : ℕ) : ℚ) -
                (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ)) := by
              rw [hcombine]
        _ = (Finset.sum (Finset.range (n + 1)) (fun k => (1 : ℚ) / (k.factorial : ℚ)) +
              (1 : ℚ) / (((n * n.factorial : ℕ) : ℕ) : ℚ)) -
              (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ) := by
              ring
        _ = (3 : ℚ) -
              Finset.sum (Finset.Icc 1 (n - 1))
                (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) -
              (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℚ) : ℚ) := by
              rw [ih]
        _ = (3 : ℚ) -
              (Finset.sum (Finset.Icc 1 (n - 1))
                (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) +
                (1 : ℚ) / (((n * (n + 1) * (n + 1).factorial : ℕ) : ℕ) : ℚ)) := by
              ring
        _ = (3 : ℚ) -
              Finset.sum (Finset.Icc 1 n)
                (fun k => (1 : ℚ) / (((k * (k + 1) * (k + 1).factorial : ℕ) : ℕ) : ℚ)) := by
              rw [hIcc]
              ring
  exact hQ N hN