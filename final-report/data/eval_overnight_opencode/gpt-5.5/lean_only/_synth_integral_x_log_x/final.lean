import Mathlib

lemma integral_x_log_x :
    ∫ x in (0:ℝ)..1, x * Real.log x = -1/4 := by
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt_of_tendsto
    (f := fun x : ℝ => x ^ 2 / 2 * Real.log x - x ^ 2 / 4)
    (fa := 0) (fb := -1/4) (by norm_num)]
  · ring
  · intro x hx
    have hx0 : x ≠ 0 := ne_of_gt hx.1
    have h1 : HasDerivAt (fun y : ℝ => y ^ 2 / 2) x x := by
      convert (((hasDerivAt_id x).pow 2).const_mul (1 / 2 : ℝ)) using 1
      · ext y; simp; ring
      · simp
    have h2 : HasDerivAt (fun y : ℝ => y ^ 2 / 4) (x / 2) x := by
      convert (((hasDerivAt_id x).pow 2).const_mul (1 / 4 : ℝ)) using 1
      · ext y; simp; ring
      · simp; ring
    have hlog : HasDerivAt Real.log x⁻¹ x := Real.hasDerivAt_log hx0
    have h := (h1.mul hlog).sub h2
    convert h using 1
    field_simp [hx0]
    ring
  · simpa [mul_comm] using
      ((intervalIntegral.intervalIntegrable_log' (a := (0 : ℝ)) (b := 1)).continuousOn_mul
        continuousOn_id)
  · have hlog2 :
        Filter.Tendsto (fun x : ℝ => Real.log x * x ^ (2 : ℕ))
          (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
      simpa [Real.rpow_natCast] using
        (tendsto_log_mul_rpow_nhdsGT_zero (by norm_num : (0 : ℝ) < 2))
    have hsq : Filter.Tendsto (fun x : ℝ => x ^ 2 / 4)
        (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
      simpa using
        (tendsto_nhdsWithin_of_tendsto_nhds
          (ContinuousAt.tendsto
            (by fun_prop : ContinuousAt (fun x : ℝ => x ^ 2 / 4) 0)))
    have hmain : Filter.Tendsto (fun x : ℝ => x ^ 2 / 2 * Real.log x)
        (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
      have hhalf :
          Filter.Tendsto (fun x : ℝ => (1 / 2) * (Real.log x * x ^ (2 : ℕ)))
            (nhdsWithin 0 (Set.Ioi 0)) (nhds (0 : ℝ)) := by
        simpa using hlog2.const_mul (1 / 2 : ℝ)
      refine hhalf.congr' ?_
      filter_upwards [self_mem_nhdsWithin] with x hx
      ring
    simpa using hmain.sub hsq
  · have hcont : Filter.Tendsto
        (fun x : ℝ => x ^ 2 / 2 * Real.log x - x ^ 2 / 4)
        (nhds 1) (nhds (-1 / 4)) := by
      convert
        (ContinuousAt.tendsto
          (by
            fun_prop (disch := norm_num) :
            ContinuousAt (fun x : ℝ => x ^ 2 / 2 * Real.log x - x ^ 2 / 4) 1))
        using 1
      norm_num
    exact hcont.mono_left nhdsWithin_le_nhds