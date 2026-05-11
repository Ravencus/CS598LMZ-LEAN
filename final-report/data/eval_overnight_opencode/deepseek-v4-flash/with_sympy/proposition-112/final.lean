import Mathlib

open scoped BigOperators

theorem sum_reciprocal_n_mul_pred_lt_one (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) < 1 := by
  have h_eq : Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) = (1 : ℚ) - (1 : ℚ) / (N : ℚ) := by
    refine Nat.le_induction (by norm_num) (fun k hk h_ih => ?_) N hN
    have hk0 : (k : ℚ) ≠ 0 := by
      have : 0 < k := by omega
      exact_mod_cast this.ne'
    have hk1_0 : ((k+1 : ℕ) : ℚ) ≠ 0 := by
      have : 0 < k+1 := by omega
      exact_mod_cast this.ne'
    have h_sub : ((k+1 : ℕ) - 1 : ℕ) = k := by omega
    have h_tele : (1 : ℚ) / (((k+1 : ℕ) : ℚ) * (k : ℚ)) = (1 : ℚ) / (k : ℚ) - (1 : ℚ) / ((k+1 : ℕ) : ℚ) := by
      field_simp [hk0, hk1_0]
      push_cast
      ring
    have h_insert : Finset.Icc 2 (k+1) = insert (k+1) (Finset.Icc 2 k) := by
      ext x
      constructor
      · intro hx
        rcases Finset.mem_Icc.mp hx with ⟨hx1, hx2⟩
        by_cases h : x ≤ k
        · apply Finset.mem_insert_of_mem; exact Finset.mem_Icc.mpr ⟨hx1, h⟩
        · apply Finset.mem_insert.mpr; left; omega
      · intro hx
        rcases Finset.mem_insert.mp hx with (hx' | hx')
        · subst hx'; exact Finset.mem_Icc.mpr ⟨by omega, by omega⟩
        · rcases Finset.mem_Icc.mp hx' with ⟨hx1, hx2⟩
          exact Finset.mem_Icc.mpr ⟨hx1, Nat.le_trans hx2 (by omega)⟩
    have h_not_mem : (k+1 : ℕ) ∉ Finset.Icc 2 k := by
      intro hm; rcases Finset.mem_Icc.mp hm with ⟨hm1, hm2⟩; omega
    rw [h_insert, Finset.sum_insert h_not_mem, h_ih]
    rw [show (((k+1 : ℕ) : ℚ) * (((k+1 : ℕ)-1 : ℕ) : ℚ)) = ((k+1 : ℕ) : ℚ) * (k : ℚ) by
      simp [h_sub]]
    rw [h_tele]
    push_cast
    ring
  have hNpos : (0 : ℚ) < (N : ℚ) := by
    have hNpos' : 0 < N := by omega
    exact_mod_cast hNpos'
  have h_pos : (0 : ℚ) < (1 : ℚ) / (N : ℚ) := div_pos (by norm_num) hNpos
  nlinarith