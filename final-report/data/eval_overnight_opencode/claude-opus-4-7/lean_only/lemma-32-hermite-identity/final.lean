import Mathlib

theorem hermite_floor_sum (x : ℝ) (n : ℕ) :
    Finset.sum (Finset.range n) (fun k => Int.floor (x + (k : ℝ) / (n : ℝ))) = Int.floor ((n : ℝ) * x) := by
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn; simp
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  have hnne : (n : ℝ) ≠ 0 := ne_of_gt hnpos
  have hnZ : (0 : ℤ) < (n : ℤ) := by exact_mod_cast hn
  have hnZne : (n : ℤ) ≠ 0 := ne_of_gt hnZ
  set m : ℤ := Int.floor ((n : ℝ) * x) with hm_def
  have hm_lo : (m : ℝ) ≤ (n : ℝ) * x := Int.floor_le _
  have hm_hi : (n : ℝ) * x < m + 1 := Int.lt_floor_add_one _
  have step1 : ∀ k ∈ Finset.range n,
      Int.floor (x + (k : ℝ) / (n : ℝ)) = (m + (k : ℤ)) / (n : ℤ) := by
    intro k _
    have hxk : x + (k : ℝ) / (n : ℝ) = ((n : ℝ) * x + (k : ℝ)) / (n : ℝ) := by field_simp
    rw [hxk, Int.floor_eq_iff]
    set d : ℤ := (m + (k : ℤ)) / (n : ℤ) with hd_def
    have hd_lo_int : d * n ≤ m + k := Int.ediv_mul_le _ hnZne
    have hd_hi_int : m + (k : ℤ) < (d + 1) * n := by
      have := Int.lt_ediv_add_one_mul_self (m + (k : ℤ)) hnZ; linarith
    have hd_hi_int_le : m + (k : ℤ) + 1 ≤ (d + 1) * n := hd_hi_int
    have hd_loR : (d : ℝ) * (n : ℝ) ≤ (m : ℝ) + (k : ℝ) := by exact_mod_cast hd_lo_int
    have hd_hiR : (m : ℝ) + (k : ℝ) + 1 ≤ ((d : ℝ) + 1) * (n : ℝ) := by exact_mod_cast hd_hi_int_le
    refine ⟨?_, ?_⟩
    · rw [le_div_iff₀ hnpos]; linarith
    · rw [div_lt_iff₀ hnpos]; linarith
  rw [Finset.sum_congr rfl step1]
  have hmod : (m / (n : ℤ)) * n + m % (n : ℤ) = m := by
    have h := Int.ediv_add_emod m (n : ℤ); linarith
  set q : ℤ := m / (n : ℤ) with hq_def
  set r : ℤ := m % (n : ℤ) with hr_def
  have hr_lo : 0 ≤ r := Int.emod_nonneg _ hnZne
  have hr_hi : r < n := Int.emod_lt_of_pos _ hnZ
  have keyDiv : ∀ k : ℕ, (m + (k : ℤ)) / (n : ℤ) = q + (r + (k : ℤ)) / (n : ℤ) := by
    intro k
    have h1 : m + (k : ℤ) = (r + (k : ℤ)) + q * (n : ℤ) := by linarith
    rw [h1, Int.add_mul_ediv_right _ _ hnZne]; ring
  have sum_eq : ∑ k ∈ Finset.range n, (m + (k : ℤ)) / (n : ℤ)
              = ∑ k ∈ Finset.range n, (q + (r + (k : ℤ)) / (n : ℤ)) :=
    Finset.sum_congr rfl (fun k _ => keyDiv k)
  rw [sum_eq, Finset.sum_add_distrib]
  simp only [Finset.sum_const, Finset.card_range]
  obtain ⟨rN, hrN⟩ : ∃ rN : ℕ, (rN : ℤ) = r := ⟨r.toNat, Int.toNat_of_nonneg hr_lo⟩
  have hrN_lt : rN < n := by exact_mod_cast (hrN ▸ hr_hi)
  have hrN_le : rN ≤ n := le_of_lt hrN_lt
  have split_sum :
      ∑ k ∈ Finset.range n, ((r + (k : ℤ)) / (n : ℤ)) =
      (∑ k ∈ Finset.range (n - rN), ((r + (k : ℤ)) / (n : ℤ))) +
      (∑ k ∈ Finset.Ico (n - rN) n, ((r + (k : ℤ)) / (n : ℤ))) := by
    have h := Finset.sum_Ico_consecutive (fun k : ℕ => ((r + (k : ℤ)) / (n : ℤ)))
              (Nat.zero_le _) (Nat.sub_le n rN)
    simp only [Finset.range_eq_Ico] at *
    linarith [h]
  have part1 : ∀ k ∈ Finset.range (n - rN), ((r + (k : ℤ)) / (n : ℤ)) = 0 := by
    intro k hk
    rw [Finset.mem_range] at hk
    apply Int.ediv_eq_zero_of_lt (by linarith)
    have hkZ : (k : ℤ) < (n : ℤ) - (rN : ℤ) := by
      have h1 : (k : ℤ) < ((n - rN : ℕ) : ℤ) := by exact_mod_cast hk
      have h2 : ((n - rN : ℕ) : ℤ) = (n : ℤ) - rN := by push_cast; omega
      linarith
    have hrr : r = (rN : ℤ) := hrN.symm
    linarith
  have part2 : ∀ k ∈ Finset.Ico (n - rN) n, ((r + (k : ℤ)) / (n : ℤ)) = 1 := by
    intro k hk
    rw [Finset.mem_Ico] at hk
    obtain ⟨hk1, hk2⟩ := hk
    have hrr : r = (rN : ℤ) := hrN.symm
    have hk1Z : ((n : ℤ) - rN) ≤ (k : ℤ) := by
      have h1 : ((n - rN : ℕ) : ℤ) ≤ (k : ℤ) := by exact_mod_cast hk1
      have h2 : ((n - rN : ℕ) : ℤ) = (n : ℤ) - rN := by push_cast; omega
      linarith
    have hk2Z : (k : ℤ) < n := by exact_mod_cast hk2
    have h_lower : (n : ℤ) ≤ r + k := by linarith
    have h_upper : r + (k : ℤ) < 2 * n := by linarith
    have heq : r + (k : ℤ) = (r + (k : ℤ) - n) + 1 * n := by ring
    rw [heq, Int.add_mul_ediv_right _ _ hnZne]
    have hzero : (r + (k : ℤ) - n) / (n : ℤ) = 0 := by
      apply Int.ediv_eq_zero_of_lt <;> linarith
    rw [hzero]; ring
  rw [split_sum, Finset.sum_congr rfl part1, Finset.sum_congr rfl part2]
  simp only [Finset.sum_const_zero, Finset.sum_const, zero_add, Nat.card_Ico, nsmul_eq_mul]
  have hcard_eq : (n - (n - rN) : ℕ) = rN := by omega
  rw [hcard_eq]
  have hrr : r = (rN : ℤ) := hrN.symm
  push_cast
  linarith