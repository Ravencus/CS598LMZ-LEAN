import Mathlib

open scoped BigOperators

theorem sum_reciprocal_n_mul_pred_lt_one (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) < 1 := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_le hN
  have hsum :
      ∀ m : ℕ,
        Finset.sum (Finset.Icc 2 (m + 2)) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) =
          1 - 1 / ((m + 2 : ℕ) : ℚ) := by
    intro m
    induction m with
    | zero =>
        norm_num
    | succ m ih =>
        have hrec :
            Finset.sum (Finset.Icc 2 (m + 3)) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) =
              Finset.sum (Finset.Icc 2 (m + 2)) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) +
                (1 : ℚ) / (((m + 3 : ℕ) : ℚ) * ((m + 2 : ℕ) : ℚ)) := by
          rw [show (m + 3 : ℕ) = (m + 2) + 1 by omega]
          rw [Finset.sum_Icc_succ_top (by omega)]
          simp
        have hstep :
            (1 : ℚ) / (((m + 3 : ℕ) : ℚ) * ((m + 2 : ℕ) : ℚ)) =
              1 / ((m + 2 : ℕ) : ℚ) - 1 / ((m + 3 : ℕ) : ℚ) := by
          have hm2 : (0 : ℚ) < (m + 2 : ℚ) := by positivity
          have hm3 : (0 : ℚ) < (m + 3 : ℚ) := by positivity
          field_simp [hm2.ne', hm3.ne']
          norm_num
        rw [hrec, ih, hstep]
        ring
  have hsumm :
      Finset.sum (Finset.Icc 2 (2 + m)) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) =
        1 - 1 / ((2 + m : ℕ) : ℚ) := by
    simpa [Nat.add_comm] using hsum m
  rw [hsumm]
  have hpos : (0 : ℚ) < 1 / ((2 + m : ℕ) : ℚ) := by positivity
  linarith