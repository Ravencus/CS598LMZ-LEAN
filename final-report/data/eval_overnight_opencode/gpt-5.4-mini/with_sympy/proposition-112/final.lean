import Mathlib

open scoped BigOperators

theorem sum_reciprocal_n_mul_pred_lt_one (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) < 1 := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le hN
  clear hN
  have hEq :
      Finset.sum (Finset.Icc 2 (k + 2))
        (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) = 1 - 1 / (k + 2) := by
    induction k with
    | zero =>
        have hIcc : Finset.Icc 2 2 = ({2} : Finset ℕ) := by
          ext n
          simp
        rw [hIcc]
        norm_num
    | succ k ih =>
        rw [Finset.sum_Icc_succ_top]
        · rw [ih]
          norm_num
          have hk2 : (0 : ℚ) ≠ (k + 2 : ℚ) := by positivity
          have hk3 : (0 : ℚ) ≠ (k + 3 : ℚ) := by positivity
          field_simp [hk2, hk3]
          ring
        · omega
  have hEq' :
      Finset.sum (Finset.Icc 2 (2 + k))
        (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) = 1 - 1 / (k + 2) := by
    simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using hEq
  rw [hEq']
  have hpos : 0 < (1 / (k + 2) : ℚ) := by positivity
  linarith