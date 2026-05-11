import Mathlib

open Real Filter

theorem harmonic_log_series_diverges :
    ¬ Summable (fun n : ℕ => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2))) := by
  intro hsum
  set f : ℕ → ℝ := fun n => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2)) with hf_def
  have h_nonneg : ∀ᶠ k in atTop, 0 ≤ f k := by
    filter_upwards with k
    simp only [hf_def]
    have h1 : (0 : ℝ) < (k : ℝ) + 2 := by positivity
    have h2 : (1 : ℝ) ≤ (k : ℝ) + 2 := by
      have : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
      linarith
    have h3 : 0 ≤ Real.log ((k : ℝ) + 2) := Real.log_nonneg h2
    positivity
  have h_mono : ∀ᶠ k in atTop, f (k + 1) ≤ f k := by
    filter_upwards [eventually_ge_atTop 0] with k _
    simp only [hf_def]
    have h0 : (0 : ℝ) < (k : ℝ) + 2 := by positivity
    have h0' : (0 : ℝ) < ((k : ℝ) + 1) + 2 := by positivity
    have h2 : (1 : ℝ) < (k : ℝ) + 2 := by
      have : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
      linarith
    have hlog : (0 : ℝ) < Real.log ((k : ℝ) + 2) := Real.log_pos h2
    have hlog' : (0 : ℝ) < Real.log (((k : ℝ) + 1) + 2) := Real.log_pos (by linarith)
    have hp : (0 : ℝ) < ((k : ℝ) + 2) * Real.log ((k : ℝ) + 2) := mul_pos h0 hlog
    have hp' : (0 : ℝ) < (((k : ℝ) + 1) + 2) * Real.log (((k : ℝ) + 1) + 2) := mul_pos h0' hlog'
    have hcast : ((↑(k+1) : ℝ) + 2) = ((k : ℝ) + 1) + 2 := by push_cast; ring
    rw [hcast, div_le_div_iff₀ hp' hp, one_mul, one_mul]
    have hle1 : ((k : ℝ) + 2) ≤ ((k : ℝ) + 1) + 2 := by linarith
    have hle2 : Real.log ((k : ℝ) + 2) ≤ Real.log (((k : ℝ) + 1) + 2) :=
      Real.log_le_log h0 (by linarith)
    exact mul_le_mul hle1 hle2 hlog.le h0'.le
  have hcond : Summable (fun k : ℕ => (2 : ℝ) ^ k * f (2 ^ k)) :=
    (summable_condensed_iff_of_eventually_nonneg h_nonneg h_mono).mpr hsum
  set h : ℕ → ℝ := fun k => 1 / (4 * ((k:ℝ) + 2) * Real.log 2) with hh_def
  have hlog2_pos : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hh_nonneg : ∀ k, 0 ≤ h k := by
    intro k
    simp only [hh_def]
    have : (0:ℝ) ≤ (k:ℝ) := Nat.cast_nonneg k
    positivity
  have hh_le : ∀ k, h k ≤ (2 : ℝ) ^ k * f (2 ^ k) := by
    intro k
    simp only [hh_def, hf_def]
    have h2k_pos : (0 : ℝ) < (2 : ℝ) ^ k := by positivity
    have h2k_ge1 : (1 : ℝ) ≤ (2 : ℝ) ^ k := one_le_pow₀ (by norm_num : (1:ℝ) ≤ 2)
    have hN : ((((2:ℕ) ^ k : ℕ) : ℝ) + 2) = (2 : ℝ)^k + 2 := by push_cast; ring
    rw [hN]
    have hbase_pos : (0 : ℝ) < (2:ℝ)^k + 2 := by linarith
    have hbase_ge1 : (1 : ℝ) < (2:ℝ)^k + 2 := by linarith
    have hlog_pos : (0 : ℝ) < Real.log ((2:ℝ)^k + 2) := Real.log_pos hbase_ge1
    have hdenom_pos : (0 : ℝ) < ((2:ℝ)^k + 2) * Real.log ((2:ℝ)^k + 2) := mul_pos hbase_pos hlog_pos
    have hineq1 : (2:ℝ)^k + 2 ≤ 4 * (2:ℝ)^k := by nlinarith
    have hineq2 : Real.log ((2:ℝ)^k + 2) ≤ ((k : ℝ) + 2) * Real.log 2 := by
      have step1 : Real.log ((2:ℝ)^k + 2) ≤ Real.log (4 * (2:ℝ)^k) :=
        Real.log_le_log hbase_pos hineq1
      have step2 : Real.log (4 * (2:ℝ)^k) = Real.log 4 + Real.log ((2:ℝ)^k) :=
        Real.log_mul (by norm_num) (by positivity)
      have step3 : Real.log ((2:ℝ)^k) = (k : ℝ) * Real.log 2 := Real.log_pow 2 k
      have step4 : Real.log 4 = 2 * Real.log 2 := by
        have hh : (4:ℝ) = 2^2 := by norm_num
        rw [hh, Real.log_pow]; push_cast; ring
      calc Real.log ((2:ℝ)^k + 2)
          ≤ Real.log (4 * (2:ℝ)^k) := step1
        _ = Real.log 4 + (k:ℝ) * Real.log 2 := by rw [step2, step3]
        _ = 2 * Real.log 2 + (k:ℝ) * Real.log 2 := by rw [step4]
        _ = ((k : ℝ) + 2) * Real.log 2 := by ring
    have key : (2:ℝ)^k * (1 / (((2:ℝ)^k + 2) * Real.log ((2:ℝ)^k + 2)))
        = (2:ℝ)^k / (((2:ℝ)^k + 2) * Real.log ((2:ℝ)^k + 2)) := by rw [mul_one_div]
    rw [key]
    have lhs_denom_pos : (0:ℝ) < 4 * ((k:ℝ) + 2) * Real.log 2 := by
      have : (0:ℝ) ≤ (k:ℝ) := Nat.cast_nonneg k
      positivity
    rw [div_le_div_iff₀ lhs_denom_pos hdenom_pos, one_mul]
    have prod_le : ((2:ℝ)^k + 2) * Real.log ((2:ℝ)^k + 2)
        ≤ (4 * (2:ℝ)^k) * (((k:ℝ) + 2) * Real.log 2) :=
      mul_le_mul hineq1 hineq2 hlog_pos.le (by positivity)
    calc ((2:ℝ)^k + 2) * Real.log ((2:ℝ)^k + 2)
        ≤ (4 * (2:ℝ)^k) * (((k:ℝ) + 2) * Real.log 2) := prod_le
      _ = (2:ℝ)^k * (4 * ((k:ℝ) + 2) * Real.log 2) := by ring
  have hh_summable : Summable h := Summable.of_nonneg_of_le hh_nonneg hh_le hcond
  have hsum_inv : Summable (fun k : ℕ => 1 / ((k:ℝ) + 2)) := by
    have heq : ∀ k, (4 * Real.log 2) * h k = 1 / ((k:ℝ) + 2) := by
      intro k
      simp only [hh_def]
      have : (0:ℝ) ≤ (k:ℝ) := Nat.cast_nonneg k
      have hk2pos : (0:ℝ) < (k:ℝ) + 2 := by linarith
      field_simp
    have := hh_summable.mul_left (4 * Real.log 2)
    exact this.congr heq
  apply Real.not_summable_one_div_natCast
  have hcast_eq : (fun k : ℕ => 1 / ((k:ℝ) + 2)) = (fun n : ℕ => 1 / (n:ℝ)) ∘ (· + 2) := by
    funext k
    simp only [Function.comp_apply]
    push_cast
    ring
  rw [hcast_eq] at hsum_inv
  exact (summable_nat_add_iff 2).mp hsum_inv