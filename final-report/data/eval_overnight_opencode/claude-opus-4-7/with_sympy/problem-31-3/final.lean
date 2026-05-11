import Mathlib

open Real Filter

set_option maxHeartbeats 1000000 in
theorem harmonic_log_series_diverges :
    ¬ Summable (fun n : ℕ => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2))) := by
  intro h
  -- Define f and prove it is nonneg and antitone
  set f : ℕ → ℝ := fun n => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2)) with hf_def
  have hf_nonneg : ∀ n, 0 ≤ f n := by
    intro n
    refine div_nonneg (by norm_num) ?_
    refine mul_nonneg (by positivity) ?_
    apply Real.log_nonneg
    have : (0:ℝ) ≤ (n:ℝ) := Nat.cast_nonneg n
    linarith
  have hf_anti : ∀ ⦃m n : ℕ⦄, 0 < m → m ≤ n → f n ≤ f m := by
    intro m n hm hmn
    simp only [hf_def]
    have hm1 : (1:ℝ) ≤ (m:ℝ) := by exact_mod_cast hm
    have hmn' : (m:ℝ) ≤ (n:ℝ) := by exact_mod_cast hmn
    have hmpos : (0:ℝ) < (m:ℝ) + 2 := by linarith
    have hnpos : (0:ℝ) < (n:ℝ) + 2 := by linarith
    have hlogmpos : 0 < Real.log ((m:ℝ) + 2) := Real.log_pos (by linarith)
    have hlogn_le : Real.log ((m:ℝ) + 2) ≤ Real.log ((n:ℝ) + 2) :=
      Real.log_le_log hmpos (by linarith)
    have hprod_le : ((m:ℝ) + 2) * Real.log ((m:ℝ) + 2) ≤ ((n:ℝ) + 2) * Real.log ((n:ℝ) + 2) := by
      apply mul_le_mul (by linarith) hlogn_le (le_of_lt hlogmpos) (by linarith)
    apply one_div_le_one_div_of_le (mul_pos hmpos hlogmpos) hprod_le
  -- Apply Cauchy condensation
  have hcond_iff := summable_condensed_iff_of_nonneg hf_nonneg hf_anti
  have hcond : Summable (fun n : ℕ => (2:ℕ)^n * f (2^n)) := hcond_iff.mpr h
  -- Show this condensed series cannot be summable by lower bound 1/(4(n+2) log 2)
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  set c : ℝ := 1 / (4 * Real.log 2) with hc_def
  have hc_pos : 0 < c := by rw [hc_def]; positivity
  have hbound : ∀ n : ℕ, c * (1 / ((n:ℝ) + 2)) ≤ ((2:ℕ)^n : ℝ) * f (2^n) := by
    intro n
    have h2npos : (0:ℝ) < (2:ℝ)^n := by positivity
    have h1 : (1:ℝ) ≤ (2:ℝ)^n := one_le_pow_of_one_le' (by norm_num : (1:ℝ) ≤ 2) n
    have h2 : (2:ℝ)^n + 2 ≤ 4 * (2:ℝ)^n := by nlinarith
    have hsumpos : 0 < (2:ℝ)^n + 2 := by linarith
    have hlognpos : 0 < Real.log ((2:ℝ)^n + 2) := Real.log_pos (by linarith)
    have h4log : Real.log (4 * (2:ℝ)^n) = 2 * Real.log 2 + n * Real.log 2 := by
      rw [Real.log_mul (by norm_num) (ne_of_gt h2npos), Real.log_pow]
      have h4eq : Real.log 4 = 2 * Real.log 2 := by
        have : (4:ℝ) = 2^2 := by norm_num
        rw [this, Real.log_pow]; push_cast; ring
      rw [h4eq]; push_cast; ring
    have h5 : Real.log ((2:ℝ)^n + 2) ≤ (n + 2) * Real.log 2 := by
      have := Real.log_le_log hsumpos h2
      rw [h4log] at this
      linarith
    have hn2nonneg : (0:ℝ) ≤ (n:ℝ) + 2 := by
      have : (0:ℝ) ≤ (n:ℝ) := Nat.cast_nonneg n; linarith
    have h_n2_pos : (0:ℝ) < (n:ℝ) + 2 := by
      have : (0:ℝ) ≤ (n:ℝ) := Nat.cast_nonneg n; linarith
    -- f (2^n) = 1 / (((2^n : ℕ) : ℝ) + 2) * log((2^n) + 2))
    show c * (1 / ((n:ℝ) + 2)) ≤ ((2:ℕ)^n : ℝ) * (1 / ((((2:ℕ)^n : ℝ) + 2) * Real.log (((2:ℕ)^n : ℝ) + 2)))
    have hcast : (((2:ℕ)^n : ℕ) : ℝ) = (2:ℝ)^n := by push_cast; ring
    rw [show (((2:ℕ)^n : ℕ) : ℝ) = (2:ℝ)^n from by push_cast; ring]
    rw [mul_one_div]
    rw [le_div_iff (mul_pos hsumpos hlognpos)]
    have hcalc :
        c * (1 / ((n:ℝ) + 2)) * (((2:ℝ)^n + 2) * Real.log ((2:ℝ)^n + 2)) ≤
        c * (1 / ((n:ℝ) + 2)) * ((4 * (2:ℝ)^n) * ((n + 2) * Real.log 2)) := by
      apply mul_le_mul_of_nonneg_left
      · exact mul_le_mul h2 h5 (le_of_lt hlognpos) (by linarith)
      · apply mul_nonneg (le_of_lt hc_pos)
        apply div_nonneg (by norm_num) hn2nonneg
    have hsimp :
        c * (1 / ((n:ℝ) + 2)) * ((4 * (2:ℝ)^n) * ((n + 2) * Real.log 2)) = (2:ℝ)^n := by
      rw [hc_def]
      have hlog2ne : Real.log 2 ≠ 0 := ne_of_gt hlog2
      have hn2ne : ((n:ℝ) + 2) ≠ 0 := ne_of_gt h_n2_pos
      field_simp
      ring
    linarith [hcalc, hsimp.le, hsimp.ge]
  -- Comparison: condensed series ≥ c/(n+2), but c * Σ 1/(n+2) diverges
  have hcomp : Summable (fun n : ℕ => c * (1 / ((n:ℝ) + 2))) := by
    apply Summable.of_nonneg_of_le (fun n => ?_) hbound hcond
    apply mul_nonneg (le_of_lt hc_pos)
    apply div_nonneg (by norm_num)
    have : (0:ℝ) ≤ (n:ℝ) := Nat.cast_nonneg n; linarith
  have hharm : Summable (fun n : ℕ => 1 / ((n:ℝ) + 2)) := by
    have hcne : c ≠ 0 := ne_of_gt hc_pos
    have := hcomp.mul_left (1 / c)
    simp only [← mul_assoc, one_div_mul_cancel hcne, one_mul] at this
    exact this
  -- But Σ 1/(n+2) diverges (harmonic-like). Use that Σ 1/(n+1) diverges.
  have hshift : Summable (fun n : ℕ => 1 / ((n:ℝ) + 1)) := by
    have hkey : Summable (fun n : ℕ => 1 / (((n+1 : ℕ) : ℝ) + 1)) := by
      have := (summable_nat_add_iff 1).mpr hharm
      convert this using 2
      push_cast; ring
    exact (summable_nat_add_iff 1).mp hkey
  -- Σ 1/(n+1) is not summable
  have hnot : ¬ Summable (fun n : ℕ => 1 / ((n:ℝ) + 1)) := by
    rw [show (fun n : ℕ => 1 / ((n:ℝ) + 1)) = (fun n : ℕ => ((n:ℝ) + 1)⁻¹) from by
      funext n; rw [one_div]]
    exact_mod_cast Real.not_summable_one_div_natCast_add_one
  exact hnot hshift