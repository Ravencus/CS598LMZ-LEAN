import Mathlib

theorem hermite_floor_sum (x : ℝ) (n : ℕ) :
    Finset.sum (Finset.range n) (fun k => Int.floor (x + (k : ℝ) / (n : ℝ))) = Int.floor ((n : ℝ) * x) := by
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn; simp
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  set m : ℤ := Int.floor ((n : ℝ) * x) with hm_def
  have key : ∀ k ∈ Finset.range n,
      Int.floor (x + (k : ℝ) / (n : ℝ)) = (m + (k : ℤ)) / (n : ℤ) := by
    intro k _
    have hk1 : x + (k : ℝ) / (n : ℝ) = ((n : ℝ) * x + (k : ℝ)) / (n : ℝ) := by field_simp
    rw [hk1, Int.floor_div_natCast]
    congr 1
    rw [Int.floor_add_natCast]
  rw [Finset.sum_congr rfl key]
  set q : ℤ := m / (n : ℤ) with hq_def
  set r : ℤ := m % (n : ℤ) with hr_def
  have hnZpos : (0 : ℤ) < (n : ℤ) := by exact_mod_cast hn
  have hnne : (n : ℤ) ≠ 0 := hnZpos.ne'
  have hr_nn : 0 ≤ r := Int.emod_nonneg m hnne
  have hr_lt : r < (n : ℤ) := Int.emod_lt_of_pos m hnZpos
  have hm_eq : m = (n : ℤ) * q + r := by
    rw [hq_def, hr_def]; exact (Int.ediv_add_emod m _).symm
  set rN : ℕ := r.toNat with hrN_def
  have hrN_cast : (rN : ℤ) = r := Int.toNat_of_nonneg hr_nn
  have hrN_lt : rN < n := by
    have : (rN : ℤ) < (n : ℤ) := by rw [hrN_cast]; exact hr_lt
    exact_mod_cast this
  have hrN_le : rN ≤ n := le_of_lt hrN_lt
  have step : ∀ k ∈ Finset.range n,
      (m + (k : ℤ)) / (n : ℤ) = q + (if k < n - rN then 0 else 1) := by
    intro k hk
    rw [Finset.mem_range] at hk
    have hk' : (k : ℤ) < (n : ℤ) := by exact_mod_cast hk
    have hk0 : (0 : ℤ) ≤ (k : ℤ) := Int.natCast_nonneg k
    have hrw : m + (k : ℤ) = (r + (k : ℤ)) + q * (n : ℤ) := by rw [hm_eq]; ring
    rw [hrw, Int.add_mul_ediv_right _ _ hnne]
    have hequiv : (r + (k : ℤ) < (n : ℤ)) ↔ (k < n - rN) := by
      constructor
      · intro h
        have hh : (k : ℤ) < (n : ℤ) - r := by linarith
        have h2 : (k : ℤ) < (n : ℤ) - (rN : ℤ) := by rw [hrN_cast]; exact hh
        have h3 : ((n - rN : ℕ) : ℤ) = (n : ℤ) - (rN : ℤ) := by
          rw [Nat.cast_sub hrN_le]
        rw [← h3] at h2
        exact_mod_cast h2
      · intro h
        have h1 : (k : ℤ) < ((n - rN : ℕ) : ℤ) := by exact_mod_cast h
        rw [Nat.cast_sub hrN_le] at h1
        push_cast at h1
        rw [← hrN_cast]
        linarith
    by_cases hrk : k < n - rN
    · rw [if_pos hrk]
      have hrk' : r + (k : ℤ) < (n : ℤ) := hequiv.mpr hrk
      have h0 : (r + (k : ℤ)) / (n : ℤ) = 0 := Int.ediv_eq_zero_of_lt (by linarith) hrk'
      rw [h0]; ring
    · rw [if_neg hrk]
      have hrk' : ¬ (r + (k : ℤ) < (n : ℤ)) := fun h => hrk (hequiv.mp h)
      push_neg at hrk'
      have hsub : r + (k : ℤ) - (n : ℤ) < (n : ℤ) := by linarith
      have hsub_nn : 0 ≤ r + (k : ℤ) - (n : ℤ) := by linarith
      have h1 : (r + (k : ℤ)) / (n : ℤ) = 1 := by
        have heq : r + (k : ℤ) = (r + (k : ℤ) - (n : ℤ)) + 1 * (n : ℤ) := by ring
        calc (r + (k : ℤ)) / (n : ℤ)
            = ((r + (k : ℤ) - (n : ℤ)) + 1 * (n : ℤ)) / (n : ℤ) := by rw [← heq]
          _ = (r + (k : ℤ) - (n : ℤ)) / (n : ℤ) + 1 := Int.add_mul_ediv_right _ _ hnne
          _ = 0 + 1 := by rw [Int.ediv_eq_zero_of_lt hsub_nn hsub]
          _ = 1 := by ring
      rw [h1]; ring
  rw [Finset.sum_congr rfl step]
  rw [Finset.sum_add_distrib, Finset.sum_const, Finset.card_range]
  have count_eq : ∑ k ∈ Finset.range n, (if k < n - rN then (0 : ℤ) else 1) = (rN : ℤ) := by
    rw [Finset.sum_ite]
    simp only [Finset.sum_const, smul_zero, zero_add]
    have card_filter : ((Finset.range n).filter (fun k => ¬ k < n - rN)).card = rN := by
      have heq_filter : (Finset.range n).filter (fun k => ¬ k < n - rN)
                      = (Finset.range n).filter (fun k => n - rN ≤ k) := by
        apply Finset.filter_congr; intro k _; omega
      rw [heq_filter]
      rw [show (Finset.range n).filter (fun k => n - rN ≤ k) = Finset.Ico (n - rN) n from ?_]
      · rw [Nat.card_Ico]; omega
      · ext k
        simp [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico, and_comm]
    rw [card_filter]; simp
  rw [count_eq, hm_eq, ← hrN_cast]
  push_cast
  ring