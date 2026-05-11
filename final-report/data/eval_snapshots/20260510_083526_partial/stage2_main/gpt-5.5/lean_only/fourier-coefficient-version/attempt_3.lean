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
  simpa [mul_assoc] using
    (intervalIntegral.norm_integral_mul_exp_neg_mul_I_tendsto_zero
      (f := f) (a := -Real.pi) (b := Real.pi) hf).const_mul
        ‖(1 / (2 * Real.pi : ℂ))‖