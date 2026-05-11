import Mathlib
open scoped Topology
open Set
open Filter
open Real

lemma integral_x_log_x :
    ∫ x in (0:ℝ)..1, x * Real.log x = -1/4 := by
  have h01 : (0 : ℝ) ≤ 1 := by norm_num
  have h01_lt : (0 : ℝ) < 1 := by norm_num
  have hderiv : ∀ x ∈ Ioo (0 : ℝ) 1,
      HasDerivAt (fun t : ℝ => (t^2/2) * Real.log t - t^2/4) (x * Real.log x) x := by
    intro x hx
    have hxpos : x ≠ 0 := hx.1.ne'
    have h_sq : HasDerivAt (fun t : ℝ => t^2) (2*x) x := by
      simpa using hasDerivAt_pow 2 x
    have h_sq_div2 : HasDerivAt (fun t : ℝ => t^2/2) x x := by
      simpa [div_eq_inv_mul] using (h_sq.div_const 2)
    have h_log : HasDerivAt Real.log (x⁻¹) x := hasDerivAt_log hxpos
    have h_prod : HasDerivAt (fun t : ℝ => (t^2/2) * Real.log t) (x * Real.log x + x/2) x := by
      have htemp := HasDerivAt.mul h_sq_div2 h_log
      have hsimp : (x ^ 2 / 2) * x⁻¹ = x/2 := by
        field_simp [hxpos]
      simpa [hsimp] using htemp
    have h_sq_div4 : HasDerivAt (fun t : ℝ => t^2/4) (2 * x / 4) x := by
      simpa using (h_sq.div_const 4)
    have h_total : HasDerivAt (fun t : ℝ => (t^2/2) * Real.log t - t^2/4)
        ((x * Real.log x + x/2) - (2 * x / 4)) x :=
      HasDerivAt.sub h_prod h_sq_div4
    have hsimp : ((x * Real.log x + x / 2) - (2 * x / 4)) = x * Real.log x := by ring
    simpa [hsimp] using h_total
  have hint : IntervalIntegrable (fun x : ℝ => x * Real.log x) MeasureTheory.volume 0 1 := by
    simpa using (continuous_mul_log.intervalIntegrable (0 : ℝ) 1)
  have ha : Tendsto (fun x : ℝ => (x^2/2) * Real.log x - x^2/4) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
    have hlogx : Tendsto (fun x : ℝ => x * Real.log x) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
      simpa [mul_comm, Real.rpow_one] using
        tendsto_log_mul_rpow_nhdsGT_zero (by norm_num : (0 : ℝ) < 1)
    have hx : Tendsto (fun x : ℝ => x) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
      exact tendsto_nhdsWithin_of_tendsto_nhds
        (a := (0 : ℝ)) (s := Set.Ioi (0 : ℝ)) continuous_id.continuousAt.tendsto
    have hx_mul_log : Tendsto (fun x : ℝ => (x^2/2) * Real.log x) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
      have eq_func : (fun x : ℝ => (x^2/2) * Real.log x) =
          (fun x : ℝ => (x/2) * (x * Real.log x)) := by
        ext x; ring
      rw [eq_func]
      simpa using (hx.div_const 2).mul hlogx
    have hx2_div4 : Tendsto (fun x : ℝ => x^2/4) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
      have hcont : Continuous (fun x : ℝ => (x^2/4)) := by
        fun_prop
      simpa using tendsto_nhdsWithin_of_tendsto_nhds
        (a := (0 : ℝ)) (s := Set.Ioi (0 : ℝ)) hcont.continuousAt.tendsto
    simpa [sub_eq_add_neg] using hx_mul_log.sub hx2_div4
  have hb : Tendsto (fun x : ℝ => (x^2/2) * Real.log x - x^2/4) (𝓝[<] (1 : ℝ)) (𝓝 (-1/4 : ℝ)) := by
    have hcont : ContinuousAt (fun x : ℝ => (x^2/2) * Real.log x - x^2/4) 1 := by
      have h1 : ContinuousAt (fun x : ℝ => (x^2/2) * Real.log x) 1 := by
        have hA : ContinuousAt (fun x : ℝ => x^2/2) 1 := by fun_prop
        have hB : ContinuousAt Real.log 1 := continuousAt_log (by norm_num : (1 : ℝ) ≠ 0)
        exact hA.mul hB
      have h2 : ContinuousAt (fun x : ℝ => x^2/4) 1 := by fun_prop
      simpa [sub_eq_add_neg] using h1.sub h2
    have htmp := tendsto_nhdsWithin_of_tendsto_nhds
      (a := (1 : ℝ)) (s := Set.Iio (1 : ℝ)) hcont.tendsto
    have hscalar : (-4⁻¹ : ℝ) = (-1 / 4 : ℝ) := by norm_num
    simpa [hscalar] using htmp
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt_of_tendsto h01_lt hderiv hint ha hb]
  norm_num