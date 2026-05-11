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
  have h :
      Tendsto
        (fun n : ℤ =>
          ∫ x in -Real.pi..Real.pi,
            f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I)))
        (Filter.comap Int.natAbs Filter.atTop)
        (nhds 0) := by
    simpa using
      (IntervalIntegrable.tendsto_integral_mul_exp_neg_mul_I_int hf)
  simpa using ((h.const_mul (1 / (2 * Real.pi : ℂ))).norm)