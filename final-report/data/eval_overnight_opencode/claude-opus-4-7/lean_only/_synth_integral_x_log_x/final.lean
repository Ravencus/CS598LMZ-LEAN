import Mathlib

open Real intervalIntegral Filter Topology Set

lemma integral_x_log_x :
    ∫ x in (0:ℝ)..1, x * Real.log x = -1/4 := by
  have hab : (0:ℝ) < 1 := by norm_num
  rw [integral_eq_sub_of_hasDerivAt_of_tendsto (f := fun x => x^2/2 * Real.log x - x^2/4)
      (fa := 0) (fb := -1/4) hab]
  · ring
  · -- HasDerivAt for x ∈ Ioo 0 1
    intro s ⟨hs, _⟩
    have hl : HasDerivAt Real.log s⁻¹ s := Real.hasDerivAt_log hs.ne'
    have hsq : HasDerivAt (fun x : ℝ => x^2/2) s s := by
      have := (hasDerivAt_pow 2 s).div_const 2
      simpa [pow_one, mul_comm] using this
    have hp : HasDerivAt (fun x : ℝ => x^2/2 * Real.log x) (s * Real.log s + s^2/2 * s⁻¹) s :=
      hsq.mul hl
    have hsq4 : HasDerivAt (fun x : ℝ => x^2/4) (s/2) s := by
      have h0 := (hasDerivAt_pow 2 s).div_const 4
      convert h0 using 1
      push_cast
      ring
    have := hp.sub hsq4
    convert this using 1
    have hsne : s ≠ 0 := hs.ne'
    field_simp
    ring
  · -- IntervalIntegrable: log integrable * continuous x
    have hlog : IntervalIntegrable Real.log MeasureTheory.volume 0 1 := intervalIntegrable_log'
    have hcont : ContinuousOn (fun x : ℝ => x) (uIcc 0 1) := continuous_id.continuousOn
    exact hlog.continuousOn_mul hcont
  · -- Tendsto at 0+
    have h1 : Tendsto (fun x : ℝ => x^2/2 * Real.log x) (𝓝[>] (0:ℝ)) (𝓝 0) := by
      have hbase : Tendsto (fun x : ℝ => Real.log x * x ^ (2:ℝ)) (𝓝[>] (0:ℝ)) (𝓝 0) :=
        tendsto_log_mul_rpow_nhdsGT_zero (by norm_num : (0:ℝ) < 2)
      have heq : ∀ᶠ x in 𝓝[>] (0:ℝ), Real.log x * x ^ (2:ℝ) = x^2/2 * Real.log x * 2 := by
        filter_upwards [self_mem_nhdsWithin] with x _
        rw [Real.rpow_two]; ring
      have hcong := hbase.congr' heq
      have hh : Tendsto (fun x : ℝ => x^2/2 * Real.log x * 2 / 2) (𝓝[>] (0:ℝ)) (𝓝 (0/2)) :=
        hcong.div_const 2
      have heq2 : (fun x : ℝ => x^2/2 * Real.log x * 2 / 2) = (fun x => x^2/2 * Real.log x) := by
        funext x; ring
      rw [heq2] at hh
      simpa using hh
    have h2 : Tendsto (fun x : ℝ => x^2/4) (𝓝[>] (0:ℝ)) (𝓝 0) := by
      have hcont : Continuous (fun x : ℝ => x^2/4) := by fun_prop
      have h3 : Tendsto (fun x : ℝ => x^2/4) (𝓝 (0:ℝ)) (𝓝 (0^2/4)) := hcont.continuousAt.tendsto
      simpa using tendsto_nhdsWithin_of_tendsto_nhds h3
    have := h1.sub h2
    simpa using this
  · -- Tendsto at 1-
    have hca : ContinuousAt (fun x : ℝ => x^2/2 * Real.log x - x^2/4) 1 := by
      have h1 : ContinuousAt (fun x : ℝ => x^2/2) (1:ℝ) := by fun_prop
      have h2 : ContinuousAt Real.log (1:ℝ) :=
        Real.continuousAt_log (by norm_num : (1:ℝ) ≠ 0)
      have h3 : ContinuousAt (fun x : ℝ => x^2/4) (1:ℝ) := by fun_prop
      exact (h1.mul h2).sub h3
    have h := hca.tendsto
    have heq : (1:ℝ)^2/2 * Real.log 1 - 1^2/4 = -1/4 := by
      rw [Real.log_one]; ring
    rw [heq] at h
    exact tendsto_nhdsWithin_of_tendsto_nhds h