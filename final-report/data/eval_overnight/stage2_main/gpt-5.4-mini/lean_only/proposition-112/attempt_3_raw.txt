import Mathlib

open scoped BigOperators

theorem sum_reciprocal_n_mul_pred_lt_one (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) < 1 := by
  rcases Nat.exists_eq_add_of_le hN with ⟨k, rfl⟩
  have htel : ∀ k : ℕ,
      Finset.sum (Finset.Icc 2 (k + 2)) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) =
        1 - 1 / ((k + 2 : ℕ) : ℚ) := by
    intro k
    induction k with
    | zero =>
        have hsing : Finset.Icc 2 2 = ({2} : Finset ℕ) := by
          ext n
          simp [Finset.mem_Icc]
        rw [hsing]
        norm_num
    | succ k ih =>
        have hI :
            Finset.Icc 2 (k + 3) = insert (k + 3) (Finset.Icc 2 (k + 2)) := by
          ext n
          simp [Finset.mem_Icc]
          constructor
          · intro hn
            by_cases hEq : n = k + 3
            · exact Or.inl hEq
            · right
              constructor
              · exact hn.1
              · have hlt : n < k + 3 := by omega
                omega
          · intro hn
            rcases hn with rfl | hn
            · constructor <;> omega
            · exact ⟨hn.1, le_trans hn.2 (by omega)⟩
        have hnot : (k + 3) ∉ Finset.Icc 2 (k + 2) := by
          intro hn
          have hn' := Finset.mem_Icc.mp hn
          omega
        have hcalc :
            (1 : ℚ) / (((k + 3 : ℕ) : ℚ) * ((k + 2 : ℕ) : ℚ)) +
              (1 - 1 / ((k + 2 : ℕ) : ℚ)) =
            1 - 1 / ((k + 3 : ℕ) : ℚ) := by
          have hk2 : ((k + 2 : ℕ) : ℚ) ≠ 0 := by
            exact_mod_cast Nat.succ_ne_zero (k + 1)
          have hk3 : ((k + 3 : ℕ) : ℚ) ≠ 0 := by
            exact_mod_cast Nat.succ_ne_zero (k + 2)
          field_simp [hk2, hk3]
          ring
        calc
          Finset.sum (Finset.Icc 2 (k + 3)) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ)))
              = (1 : ℚ) / (((k + 3 : ℕ) : ℚ) * ((k + 2 : ℕ) : ℚ)) +
                  Finset.sum (Finset.Icc 2 (k + 2)) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) := by
                  rw [hI, Finset.sum_insert hnot]
          _ = (1 : ℚ) / (((k + 3 : ℕ) : ℚ) * ((k + 2 : ℕ) : ℚ)) +
                  (1 - 1 / ((k + 2 : ℕ) : ℚ)) := by rw [ih]
          _ = 1 - 1 / ((k + 3 : ℕ) : ℚ) := hcalc
  have hsum :
      Finset.sum (Finset.Icc 2 (2 + k)) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) =
        1 - 1 / ((k + 2 : ℕ) : ℚ) := by
    simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using htel k
  have hlt : 1 - 1 / ((k + 2 : ℕ) : ℚ) < 1 := by
    have hden : (0 : ℚ) < ((k + 2 : ℕ) : ℚ) := by
      exact_mod_cast Nat.succ_pos (k + 1)
    have hpos : 0 < 1 / ((k + 2 : ℕ) : ℚ) := by
      exact one_div_pos.mpr hden
    linarith
  exact lt_of_eq_of_lt hsum hlt