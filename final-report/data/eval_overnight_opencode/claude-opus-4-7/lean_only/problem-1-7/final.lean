import Mathlib

open Filter Real

theorem sum_sin_div_nsq_tendsto_half :
    Filter.Tendsto
      (fun n : ℕ => Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2)))
      Filter.atTop
      (nhds ((1 : ℝ) / 2)) := by
  set f : ℕ → ℝ := fun n => ∑ k ∈ Finset.range (n + 1), Real.sin ((k : ℝ) / (n : ℝ) ^ 2) with hf_def
  set U : ℕ → ℝ := fun n => ∑ k ∈ Finset.range (n + 1), (k : ℝ) / (n : ℝ) ^ 2 with hU_def
  set E : ℕ → ℝ := fun n => ∑ k ∈ Finset.range (n + 1), ((k : ℝ) / (n : ℝ) ^ 2)^3 / 4 with hE_def
  have sum_id : ∀ n : ℕ, (∑ k ∈ Finset.range (n+1), (k : ℝ)) = (n : ℝ) * (n + 1) / 2 := by
    intro n
    induction n with
    | zero => simp
    | succ m ih => rw [Finset.sum_range_succ, ih]; push_cast; ring
  have hn_le_nsq : ∀ n : ℕ, 1 ≤ n → (n : ℝ) ≤ (n : ℝ)^2 := by
    intro n hn
    have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
    nlinarith [sq_nonneg ((n:ℝ) - 1)]
  have hU_eq : ∀ n : ℕ, 1 ≤ n → U n = ((n : ℝ) + 1) / (2 * n) := by
    intro n hn
    have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
    show (∑ k ∈ Finset.range (n + 1), (k : ℝ) / (n : ℝ) ^ 2) = ((n : ℝ) + 1) / (2 * n)
    rw [← Finset.sum_div, sum_id n]
    field_simp
  have hU_tendsto : Tendsto U atTop (nhds (1/2 : ℝ)) := by
    have h0 : Tendsto (fun n : ℕ => (1 : ℝ) / (n : ℝ)) atTop (nhds 0) := tendsto_one_div_atTop_nhds_zero_nat
    have h1 : Tendsto (fun n : ℕ => (1/2 : ℝ) + (1/2) * (1/(n:ℝ))) atTop (nhds (1/2)) := by
      have hh : Tendsto (fun n : ℕ => (1/2 : ℝ) + (1/2) * (1/(n:ℝ))) atTop (nhds ((1/2 : ℝ) + (1/2) * 0)) :=
        (h0.const_mul (1/2)).const_add (1/2)
      have heq : (1/2 : ℝ) + (1/2) * 0 = 1/2 := by ring
      rw [heq] at hh; exact hh
    apply Tendsto.congr' _ h1
    filter_upwards [Filter.eventually_ge_atTop 1] with n hn
    rw [hU_eq n hn]
    have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
    field_simp
  have hE_bound : ∀ n : ℕ, 1 ≤ n → E n ≤ ((n : ℝ) + 1) / (4 * (n : ℝ)^3) := by
    intro n hn
    have hnpos : (0 : ℝ) < n := Nat.cast_pos.mpr (by omega)
    have hn' : (n : ℝ) ≠ 0 := ne_of_gt hnpos
    have hnsq_pos : (0 : ℝ) < (n:ℝ)^2 := by positivity
    have hn_le_nsq' : (n : ℝ) ≤ (n : ℝ)^2 := hn_le_nsq n hn
    have hbound : ∀ k ∈ Finset.range (n + 1), ((k : ℝ) / (n : ℝ) ^ 2)^3 / 4 ≤ 1 / (4 * (n : ℝ)^3) := by
      intro k hk
      rw [Finset.mem_range] at hk
      have hk_le_n : (k : ℝ) ≤ n := by exact_mod_cast Nat.lt_succ_iff.mp hk
      have hk_nn : (0 : ℝ) ≤ k := Nat.cast_nonneg _
      have hratio : (k : ℝ) / (n:ℝ)^2 ≤ 1 / (n:ℝ) := by
        rw [div_le_div_iff₀ hnsq_pos hnpos]
        have : (k : ℝ) * n ≤ n * n := by nlinarith
        nlinarith [sq (n : ℝ), this]
      have hratio_nn : 0 ≤ (k : ℝ) / (n:ℝ)^2 := by positivity
      have hcube : ((k : ℝ) / (n:ℝ)^2)^3 ≤ (1/(n:ℝ))^3 := pow_le_pow_left₀ hratio_nn hratio 3
      have heq : ((1:ℝ)/(n:ℝ))^3 = 1 / (n:ℝ)^3 := by rw [div_pow, one_pow]
      have h4pos : (0:ℝ) < 4 := by norm_num
      calc ((k : ℝ) / (n:ℝ)^2)^3 / 4 ≤ ((1:ℝ)/(n:ℝ))^3 / 4 := by linarith
        _ = (1 / (n:ℝ)^3) / 4 := by rw [heq]
        _ = 1 / (4 * (n:ℝ)^3) := by field_simp
    calc E n = ∑ k ∈ Finset.range (n + 1), ((k : ℝ) / (n : ℝ) ^ 2)^3 / 4 := rfl
      _ ≤ ∑ _k ∈ Finset.range (n + 1), 1 / (4 * (n : ℝ)^3) := Finset.sum_le_sum hbound
      _ = ((n : ℝ) + 1) * (1 / (4 * (n : ℝ)^3)) := by
            rw [Finset.sum_const, Finset.card_range]; push_cast; ring
      _ = ((n : ℝ) + 1) / (4 * (n : ℝ)^3) := by ring
  have hE_nn : ∀ n : ℕ, 0 ≤ E n := by
    intro n
    apply Finset.sum_nonneg; intro k _; positivity
  have hUB_tendsto : Tendsto (fun n : ℕ => ((n : ℝ) + 1) / (4 * (n : ℝ)^3)) atTop (nhds 0) := by
    have h0 : Tendsto (fun n : ℕ => (1 : ℝ) / (n : ℝ)) atTop (nhds 0) := tendsto_one_div_atTop_nhds_zero_nat
    have h0' : Tendsto (fun n : ℕ => (1/(2:ℝ)) * (1/(n:ℝ))) atTop (nhds 0) := by
      have hh : Tendsto (fun n : ℕ => (1/(2:ℝ)) * (1/(n:ℝ))) atTop (nhds ((1/2 : ℝ) * 0)) := h0.const_mul (1/2)
      have heq : (1/2 : ℝ) * 0 = 0 := by ring
      rw [heq] at hh; exact hh
    have h_zero : Tendsto (fun _ : ℕ => (0:ℝ)) atTop (nhds 0) := tendsto_const_nhds
    apply tendsto_of_tendsto_of_tendsto_of_le_of_le' h_zero h0'
    · filter_upwards [Filter.eventually_ge_atTop 1] with n hn
      have hnpos : (0 : ℝ) < n := Nat.cast_pos.mpr (by omega)
      have : (0:ℝ) < (n:ℝ)^3 := by positivity
      positivity
    · filter_upwards [Filter.eventually_ge_atTop 1] with n hn
      have hnpos : (0 : ℝ) < (n:ℝ) := Nat.cast_pos.mpr (by omega)
      have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
      have hn3_pos : (0 : ℝ) < (n:ℝ)^3 := by positivity
      have h4n3 : (0:ℝ) < 4 * (n:ℝ)^3 := by positivity
      have h2n : (0:ℝ) < 2 * (n:ℝ) := by positivity
      have : ((n : ℝ) + 1) / (4 * (n : ℝ)^3) ≤ 1 / (2 * (n : ℝ)) := by
        rw [div_le_div_iff₀ h4n3 h2n]
        nlinarith [hn1, sq_nonneg ((n:ℝ) - 1), sq_nonneg (n:ℝ), mul_nonneg (by linarith : (0:ℝ) ≤ (n:ℝ)) (by linarith : (0:ℝ) ≤ (n:ℝ) - 1)]
      have heq2 : (1:ℝ) / (2 * (n:ℝ)) = (1/(2:ℝ)) * (1/(n:ℝ)) := by field_simp
      linarith [heq2.le, heq2.ge]
  have hE_tendsto : Tendsto E atTop (nhds (0 : ℝ)) := by
    apply tendsto_of_tendsto_of_tendsto_of_le_of_le' (g := fun _ => (0:ℝ))
      tendsto_const_nhds hUB_tendsto
    · exact Filter.Eventually.of_forall hE_nn
    · filter_upwards [Filter.eventually_ge_atTop 1] with n hn
      exact hE_bound n hn
  have hsq_upper : ∀ n : ℕ, f n ≤ U n := by
    intro n
    show ∑ k ∈ Finset.range (n + 1), Real.sin ((k:ℝ) / (n:ℝ)^2) ≤ ∑ k ∈ Finset.range (n + 1), (k:ℝ)/(n:ℝ)^2
    apply Finset.sum_le_sum
    intro k _
    by_cases hn0 : n = 0
    · subst hn0; simp
    have hnpos : (0 : ℝ) < n := Nat.cast_pos.mpr (Nat.pos_of_ne_zero hn0)
    have hx_nn : 0 ≤ (k : ℝ) / (n : ℝ)^2 := by positivity
    exact Real.sin_le hx_nn
  have hsq_lower : ∀ n : ℕ, 1 ≤ n → U n - E n ≤ f n := by
    intro n hn
    have hnpos : (0 : ℝ) < n := Nat.cast_pos.mpr (by omega)
    have hnsq_pos : (0 : ℝ) < (n:ℝ)^2 := by positivity
    have hn_le_nsq' : (n : ℝ) ≤ (n:ℝ)^2 := hn_le_nsq n hn
    show (∑ k ∈ Finset.range (n + 1), (k:ℝ)/(n:ℝ)^2) - ∑ k ∈ Finset.range (n + 1), ((k:ℝ)/(n:ℝ)^2)^3 / 4
         ≤ ∑ k ∈ Finset.range (n + 1), Real.sin ((k:ℝ)/(n:ℝ)^2)
    rw [← Finset.sum_sub_distrib]
    apply Finset.sum_le_sum
    intro k hk
    rw [Finset.mem_range] at hk
    have hk_le : (k : ℝ) ≤ n := by exact_mod_cast Nat.lt_succ_iff.mp hk
    have hk_nn : (0 : ℝ) ≤ k := Nat.cast_nonneg _
    have hk_le_nsq : (k : ℝ) ≤ (n:ℝ)^2 := le_trans hk_le hn_le_nsq'
    have hx_nn : 0 ≤ (k : ℝ) / (n : ℝ)^2 := by positivity
    have hx_le : (k : ℝ) / (n : ℝ)^2 ≤ 1 := by
      rw [div_le_one hnsq_pos]; exact hk_le_nsq
    by_cases hk0 : k = 0
    · subst hk0
      have hzero : ((0 : ℕ) : ℝ) / (n:ℝ)^2 = 0 := by simp
      rw [hzero]
      have : Real.sin 0 = 0 := Real.sin_zero
      rw [this]
      have : (0:ℝ)^3 / 4 = 0 := by ring
      linarith
    have hkpos : 0 < (k : ℝ) := by exact_mod_cast Nat.pos_of_ne_zero hk0
    have hx_pos : 0 < (k : ℝ) / (n : ℝ)^2 := by positivity
    have hsg := Real.sin_gt_sub_cube hx_pos hx_le
    linarith
  have hUE : Tendsto (fun n => U n - E n) atTop (nhds (1/2 : ℝ)) := by
    have h := hU_tendsto.sub hE_tendsto
    have : (1/2 : ℝ) - 0 = 1/2 := by ring
    rw [this] at h; exact h
  exact tendsto_of_tendsto_of_tendsto_of_le_of_le' hUE hU_tendsto
    (by filter_upwards [Filter.eventually_ge_atTop 1] with n hn; exact hsq_lower n hn)
    (Filter.Eventually.of_forall hsq_upper)