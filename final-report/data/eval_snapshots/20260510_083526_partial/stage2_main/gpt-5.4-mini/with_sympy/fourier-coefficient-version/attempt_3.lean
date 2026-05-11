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
  first
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        MeasureTheory.IntervalIntegrable.riemannLebesgue_fourierCoefficients_tendsto_zero hf
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (MeasureTheory.IntervalIntegrable.riemannLebesgue_fourierCoefficients_tendsto_zero hf).norm