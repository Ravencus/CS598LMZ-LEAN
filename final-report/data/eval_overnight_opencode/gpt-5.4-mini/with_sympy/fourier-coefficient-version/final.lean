import Mathlib

open MeasureTheory Filter Topology

noncomputable section

theorem riemannLebesgue_fourierCoefficients_tendsto_zero
    {f : ℝ → ℂ}
    (hf : IntervalIntegrable f volume (-Real.pi) Real.pi) :
    Tendsto
      (fun n : ℤ =>
        ‖((1 / (2 * Real.pi : ℂ)) *
          ∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I)))‖)
      (Filter.comap Int.natAbs Filter.atTop)
      (nhds 0) := by
  have hnatAbs : Tendsto Int.natAbs (Filter.comap Int.natAbs Filter.atTop) Filter.atTop := by
    exact map_comap_le
  have hdist_eq : (fun n : ℤ => dist ((n : ℝ)) 0) = fun n : ℤ => ((Int.natAbs n : ℕ) : ℝ) := by
    funext n
    norm_num [Int.dist_eq, Int.abs_eq_natAbs]
  have hnatAbsReal : Tendsto (fun n : ℤ => dist ((n : ℝ)) 0) (Filter.comap Int.natAbs Filter.atTop) Filter.atTop := by
    rw [hdist_eq]
    exact (tendsto_natCast_atTop_atTop).comp hnatAbs
  have hcoe : Tendsto (fun n : ℤ => (n : ℝ)) (Filter.comap Int.natAbs Filter.atTop) (Filter.cocompact ℝ) := by
    refine tendsto_cocompact_of_tendsto_dist_comp_atTop 0 ?_
    simpa using hnatAbsReal
  have hpi : (2 * Real.pi : ℝ) ≠ 0 := by positivity
  have hscale : Tendsto (fun n : ℤ => ((n : ℝ) * (2 * Real.pi)⁻¹))
      (Filter.comap Int.natAbs Filter.atTop) (Filter.cocompact ℝ) := by
    simpa [div_eq_mul_inv, mul_comm, mul_left_comm, mul_assoc] using
      ((Filter.tendsto_cocompact_mul_right₀ (a := (2 * Real.pi : ℝ)⁻¹) (inv_ne_zero hpi)).comp hcoe)
  have hRL0 := Real.tendsto_integral_exp_smul_cocompact ((Set.Icc (-Real.pi) Real.pi).indicator f)
  have hEq : ∀ w : ℝ,
      ∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((x : ℂ) * (w : ℂ) * Complex.I)) =
        ∫ x : ℝ, (Set.Icc (-Real.pi) Real.pi).indicator f x * Complex.exp (-((x : ℂ) * (w : ℂ) * Complex.I)) := by
    intro w
    rw [← integral_indicator measurableSet_Icc]
    simp [Set.indicator, smul_eq_mul]
  have hRL0' : Tendsto (fun w : ℝ =>
      ∫ x : ℝ, (Set.Icc (-Real.pi) Real.pi).indicator f x *
        Complex.exp (-((x : ℂ) * (w : ℂ) * Complex.I)))
      (Filter.cocompact ℝ) (nhds 0) := by
    simpa [Real.fourierChar_apply, smul_eq_mul, mul_comm, mul_left_comm, mul_assoc] using hRL0
  have hRL1 : Tendsto
      (fun n : ℤ => ∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I)))
      (Filter.comap Int.natAbs Filter.atTop)
      (nhds 0) := by
    have h := hRL0'.comp hscale
    simpa [Function.comp, hEq, mul_comm, mul_left_comm, mul_assoc, div_eq_mul_inv] using h
  have hmain : Tendsto
      (fun n : ℤ => (1 / (2 * Real.pi : ℂ)) *
        ∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I)))
      (Filter.comap Int.natAbs Filter.atTop)
      (nhds 0) := by
    simpa [mul_comm, mul_left_comm, mul_assoc] using hRL1.const_mul (1 / (2 * Real.pi : ℂ))
  exact hmain.norm