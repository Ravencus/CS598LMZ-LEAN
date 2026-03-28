import Mathlib

/-
Proof of the 1/6 bound via quadrant method (actually proves 1/4 ≥ 1/6).

Strategy: Decompose ∑‖zₖ‖ into four non-negative quantities by sign of Re and Im.
Their sum ≥ 1, so the max ≥ 1/4 ≥ 1/6. The corresponding half-plane subset works.
-/

-- Helper: splitting ∑|f i| into positive and negative parts
lemma sum_abs_eq_pos_neg_parts {n : ℕ} (f : Fin n → ℝ) :
    ∑ i ∈ Finset.univ.filter (fun i => 0 ≤ f i), f i
    + ∑ i ∈ Finset.univ.filter (fun i => f i < 0), (-f i)
    = ∑ i, |f i| := by
  have h1 : ∀ i ∈ Finset.univ.filter (fun i => 0 ≤ f i), f i = |f i| :=
    fun i hi => (abs_of_nonneg (Finset.mem_filter.mp hi).2).symm
  have h2 : ∀ i ∈ Finset.univ.filter (fun i => f i < 0), -f i = |f i| :=
    fun i hi => (abs_of_neg (Finset.mem_filter.mp hi).2).symm
  rw [Finset.sum_congr rfl h1, Finset.sum_congr rfl h2]
  rw [← Finset.sum_filter_add_sum_filter_not Finset.univ (fun i => 0 ≤ f i) (fun i => |f i|)]
  congr 1
  exact Finset.sum_congr (Finset.filter_congr (fun i _ => not_le.symm)) (fun _ _ => rfl)

-- Main theorem
theorem complex_subset_sum (n : ℕ) (z : Fin n → ℂ)
    (h : ∑ i, ‖z i‖ = 1) :
    ∃ S : Finset (Fin n), ‖∑ i ∈ S, z i‖ ≥ (1 : ℝ) / 6 := by
  -- Define the four subsets by sign of Re and Im
  set S_rp := Finset.univ.filter (fun i => 0 ≤ (z i).re) with hS_rp_def
  set S_rn := Finset.univ.filter (fun i => (z i).re < 0) with hS_rn_def
  set S_ip := Finset.univ.filter (fun i => 0 ≤ (z i).im) with hS_ip_def
  set S_in := Finset.univ.filter (fun i => (z i).im < 0) with hS_in_def
  -- The four sums
  set a := ∑ i ∈ S_rp, (z i).re
  set b := ∑ i ∈ S_rn, (-(z i).re)
  set c := ∑ i ∈ S_ip, (z i).im
  set d := ∑ i ∈ S_in, (-(z i).im)
  -- All four are non-negative
  have ha : a ≥ 0 := Finset.sum_nonneg (fun i hi => by
    have := (Finset.mem_filter.mp hi).2; linarith)
  have hb : b ≥ 0 := Finset.sum_nonneg (fun i hi => by
    have := (Finset.mem_filter.mp hi).2; linarith)
  have hc : c ≥ 0 := Finset.sum_nonneg (fun i hi => by
    have := (Finset.mem_filter.mp hi).2; linarith)
  have hd : d ≥ 0 := Finset.sum_nonneg (fun i hi => by
    have := (Finset.mem_filter.mp hi).2; linarith)
  -- Key: a + b + c + d ≥ 1
  have h_ab : a + b = ∑ i, |(z i).re| :=
    (sum_abs_eq_pos_neg_parts (fun i => (z i).re))
  have h_cd : c + d = ∑ i, |(z i).im| :=
    (sum_abs_eq_pos_neg_parts (fun i => (z i).im))
  have sum_ge : a + b + (c + d) ≥ 1 := by
    rw [h_ab, h_cd, ← Finset.sum_add_distrib]
    rw [← h]
    exact Finset.sum_le_sum (fun i _ => Complex.norm_le_abs_re_add_abs_im (z i))
  -- Case split: one of a, b, c, d ≥ 1/4
  by_cases ha4 : a ≥ 1 / 4
  · -- S_rp works: ‖∑ z‖ ≥ Re(∑ z) = a ≥ 1/4
    exact ⟨S_rp, by
      calc ‖∑ i ∈ S_rp, z i‖
          ≥ (∑ i ∈ S_rp, z i).re := Complex.re_le_norm _
        _ = ∑ i ∈ S_rp, (z i).re := Complex.re_sum S_rp z
        _ = a := rfl
        _ ≥ 1 / 4 := ha4
        _ ≥ 1 / 6 := by norm_num⟩
  · by_cases hb4 : b ≥ 1 / 4
    · -- S_rn works: ‖∑ z‖ ≥ |Re(∑ z)| ≥ -(Re(∑ z)) = b ≥ 1/4
      exact ⟨S_rn, by
        calc ‖∑ i ∈ S_rn, z i‖
            ≥ |(∑ i ∈ S_rn, z i).re| := Complex.abs_re_le_norm _
          _ = |∑ i ∈ S_rn, (z i).re| := by rw [Complex.re_sum]
          _ ≥ -(∑ i ∈ S_rn, (z i).re) := neg_le_abs _
          _ = ∑ i ∈ S_rn, (-(z i).re) :=
              (Finset.sum_neg_distrib (fun i => (z i).re)).symm
          _ = b := rfl
          _ ≥ 1 / 4 := hb4
          _ ≥ 1 / 6 := by norm_num⟩
    · by_cases hc4 : c ≥ 1 / 4
      · -- S_ip works: ‖∑ z‖ ≥ |Im(∑ z)| ≥ Im(∑ z) = c ≥ 1/4
        exact ⟨S_ip, by
          calc ‖∑ i ∈ S_ip, z i‖
              ≥ |(∑ i ∈ S_ip, z i).im| := Complex.abs_im_le_norm _
            _ = |∑ i ∈ S_ip, (z i).im| := by rw [Complex.im_sum]
            _ ≥ ∑ i ∈ S_ip, (z i).im := le_abs_self _
            _ = c := rfl
            _ ≥ 1 / 4 := hc4
            _ ≥ 1 / 6 := by norm_num⟩
      · -- Must have d ≥ 1/4
        have hd4 : d ≥ 1 / 4 := by push_neg at ha4 hb4 hc4; linarith
        exact ⟨S_in, by
          calc ‖∑ i ∈ S_in, z i‖
              ≥ |(∑ i ∈ S_in, z i).im| := Complex.abs_im_le_norm _
            _ = |∑ i ∈ S_in, (z i).im| := by rw [Complex.im_sum]
            _ ≥ -(∑ i ∈ S_in, (z i).im) := neg_le_abs _
            _ = ∑ i ∈ S_in, (-(z i).im) :=
                (Finset.sum_neg_distrib (fun i => (z i).im)).symm
            _ = d := rfl
            _ ≥ 1 / 4 := hd4
            _ ≥ 1 / 6 := by norm_num⟩
