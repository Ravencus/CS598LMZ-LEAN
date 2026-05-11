import Mathlib
open Set
open Filter
open Real
open IntervalIntegral

lemma integral_x_log_x :
    ∫ x in (0:ℝ)..1, x * Real.log x = -1/4 := by
  have h01 : (0 : ℝ) ≤ 1 := by norm_num
  have h01_lt : (0 : ℝ) < 1 := by norm_num
  have hcont_ci : ContinuousOn (fun x : ℝ => x * Real.log x) (Ici (0 : ℝ)) := by
    intro x hx
    have hx0 : 0 ≤ x := hx
    by_cases hx0' : x = 0
    · subst x
      have hlim : Filter.Tendsto (fun t : ℝ => t * Real.log t) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
        simpa [mul_comm, Real.rpow_one] using tendsto_log_mul_rpow_nhdsGT_zero (by norm_num : (0 : ℝ) < 1)
      have hfilter : 𝓝[Ici (0 : ℝ)] (0 : ℝ) ≤ 𝓝[Ioi (0 : ℝ)] (0 : ℝ) :=
        nhdsWithin_mono 0 (fun y hy => hy)
      exact (hlim.mono_left hfilter).continuousWithinAt
    · have hxpos : 0 < x := hx0.lt_of_ne hx0'.symm
      have h_cont_x : ContinuousAt (fun t : ℝ => t) x := continuous_id.continuousAt
      have h_cont_log : ContinuousAt Real.log x := Real.continuousAt_log hxpos.ne.symm
      exact (h_cont_x.mul h_cont_log).continuousWithinAt
  have hcont : ContinuousOn (fun x : ℝ => x * Real.log x) (Icc (0 : ℝ) 1) :=
    hcont_ci.mono (Set.Icc_subset_Ici_self)
  have hint : IntervalIntegrable (fun x : ℝ => x * Real.log x) MeasureTheory.volume (0:ℝ) 1 :=
    hcont.intervalIntegrable_of_Icc h01
  have hderiv : ∀ x ∈ Ioo (0 : ℝ) 1, HasDerivAt (fun t : ℝ => (t^2/2) * Real.log t - t^2/4) (x * Real.log x) x := by
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
        ring
      simpa [hsimp] using htemp
    have h_sq_div4 : HasDerivAt (fun t : ℝ => t^2/4) (x/2) x := by
      simpa using (h_sq.div_const 4)
    have h_total : HasDerivAt (fun t : ℝ => (t^2/2) * Real.log t - t^2/4) ((x * Real.log x + x/2) - x/2) x :=
      HasDerivAt.sub h_prod h_sq_div4
    simpa [add_sub_cancel_right] using h_total
  have ha : Filter.Tendsto (fun x : ℝ => (x^2/2) * Real.log x - x^2/4) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
    have hlogx : Filter.Tendsto (fun x : ℝ => x * Real.log x) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
      simpa [mul_comm, Real.rpow_one] using tendsto_log_mul_rpow_nhdsGT_zero (by norm_num : (0 : ℝ) < 1)
    have hx : Filter.Tendsto (fun x : ℝ => x) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) :=
      continuous_id.continuousAt.tendsto_nhdsWithin (by norm_num)
    have hx_mul_log : Filter.Tendsto (fun x : ℝ => (x^2/2) * Real.log x) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
      have eq_func : (fun x : ℝ => (x^2/2) * Real.log x) = (fun x : ℝ => (x/2) * (x * Real.log x)) := by
        ext x; ring
      rw [eq_func]
      exact (hx.div_const 2).mul hlogx
    have hx2_div4 : Filter.Tendsto (fun x : ℝ => x^2/4) (𝓝[>] (0 : ℝ)) (𝓝 (0 : ℝ)) := by
      simpa using ((continuous_id.pow 2).div_const 4).continuousAt.tendsto_nhdsWithin (by norm_num)
    exact hx_mul_log.sub hx2_div4
  have hb : Filter.Tendsto (fun x : ℝ => (x^2/2) * Real.log x - x^2/4) (𝓝[<] (1 : ℝ)) (𝓝 (-1/4 : ℝ)) := by
    have h_cont_at : ContinuousAt (fun x : ℝ => (x^2/2) * Real.log x - x^2/4) (1 : ℝ) := by
      refine (((continuous_id.pow 2).div_const 2).mul
        (Real.continuousAt_log (by norm_num : (1 : ℝ) ≠ 0))).sub ((continuous_id.pow 2).div_const 4)
    exact h_cont_at.tendsto.mono_left (nhdsWithin_le_nhds _)
  calc
    ∫ x in (0 : ℝ)..1, x * Real.log x = ((-1/4) - 0) := by
      refine intervalIntegral.integral_eq_sub_of_hasDerivAt_of_tendsto h01_lt hderiv hint ha hb
    _ = -1/4 := by ring