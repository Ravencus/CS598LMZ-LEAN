import Mathlib

open MeasureTheory Filter Topology
open scoped FourierTransform

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
  have hle : (-Real.pi : ℝ) ≤ Real.pi := by
    linarith [Real.pi_pos]
  have hnatabs : Tendsto (fun n : ℤ => (n.natAbs : ℝ)) (Filter.comap Int.natAbs Filter.atTop) atTop :=
    (tendsto_natCast_atTop_atTop (R := ℝ)).comp <| by
      simpa using (tendsto_comap : Tendsto Int.natAbs (Filter.comap Int.natAbs Filter.atTop) atTop)
  have habs : Tendsto (fun n : ℤ => ‖(n : ℝ)‖) (Filter.comap Int.natAbs Filter.atTop) atTop := by
    simpa [Int.natCast_natAbs] using hnatabs
  have hfreq :
      Tendsto (fun n : ℤ => (n : ℝ) / (2 * Real.pi))
        (Filter.comap Int.natAbs Filter.atTop) (cocompact ℝ) := by
    rw [cocompact_eq_atBot_atTop, ← comap_abs_atTop, tendsto_comap_iff]
    simpa [abs_div, abs_of_pos (by positivity), div_eq_mul_inv, mul_comm, mul_left_comm,
      mul_assoc] using
      habs.const_mul_atTop (show 0 < (1 / (2 * Real.pi) : ℝ) by positivity)
  have hraw :
      Tendsto
        (fun n : ℤ =>
          ∫ x : ℝ, 𝐞 (-(x * ((n : ℝ) / (2 * Real.pi)))) •
            (Set.Icc (-Real.pi) Real.pi).indicator f x)
        (Filter.comap Int.natAbs Filter.atTop) (nhds 0) := by
    exact (Real.tendsto_integral_exp_smul_cocompact
      ((Set.Icc (-Real.pi) Real.pi).indicator f)).comp hfreq
  have hfun :
      (fun x : ℝ => 𝐞 (-(x * ((0 : ℝ) / (2 * Real.pi)))) •
          (Set.Icc (-Real.pi) Real.pi).indicator f x) =
        (Set.Icc (-Real.pi) Real.pi).indicator
          (fun x : ℝ => 𝐞 (-(x * ((0 : ℝ) / (2 * Real.pi)))) • f x) := by
    funext x
    by_cases hx : x ∈ Set.Icc (-Real.pi) Real.pi <;> simp [Set.indicator, hx]
  have hscaled :
      Tendsto
        (fun n : ℤ =>
          (1 / (2 * Real.pi : ℂ)) *
            ∫ x : ℝ, 𝐞 (-(x * ((n : ℝ) / (2 * Real.pi)))) •
              (Set.Icc (-Real.pi) Real.pi).indicator f x)
        (Filter.comap Int.natAbs Filter.atTop) (nhds 0) := by
    exact hraw.const_mul _
  have hrewrite :
      (fun n : ℤ =>
          (1 / (2 * Real.pi : ℂ)) *
            ∫ x : ℝ, 𝐞 (-(x * ((n : ℝ) / (2 * Real.pi)))) •
              (Set.Icc (-Real.pi) Real.pi).indicator f x)
        =
      fun n : ℤ =>
          (1 / (2 * Real.pi : ℂ)) *
            ∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I)) := by
    funext n
    rw [integral_indicator measurableSet_Icc, intervalIntegral.integral_of_le hle]
    simp [Real.fourierChar_apply', Circle.smul_def, Circle.coe_exp, mul_comm, mul_left_comm,
      mul_assoc]
    congr 1
    apply congrArg Complex.exp
    ring_nf
  simpa [hrewrite] using hscaled.norm