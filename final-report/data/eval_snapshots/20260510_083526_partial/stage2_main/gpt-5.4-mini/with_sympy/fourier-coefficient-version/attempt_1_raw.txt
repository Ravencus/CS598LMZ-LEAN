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
        (hf.riemannLebesgue_fourierCoefficients_tendsto_zero)
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (hf.riemannLebesgue_fourierCoefficients_tendsto_zero).norm
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (hf.riemannLebesgue_fourierCoefficient_tendsto_zero)
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (hf.riemannLebesgue_fourierCoefficient_tendsto_zero).norm
    | simpa [mul_comm, mul_left_comm, mul_assoc] using (hf.riemannLebesgue)
    | simpa [mul_comm, mul_left_comm, mul_assoc] using (hf.riemannLebesgue).norm
    | have h := hf.riemannLebesgue
      simpa [norm_mul, mul_comm, mul_left_comm, mul_assoc] using
        h.norm.const_mul ‖(1 / (2 * Real.pi : ℂ))‖
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (MeasureTheory.riemannLebesgue_fourierCoefficients_tendsto_zero hf)
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (MeasureTheory.riemannLebesgue_fourierCoefficients_tendsto_zero hf).norm
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (MeasureTheory.riemannLebesgue_fourierCoefficient_tendsto_zero hf)
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (MeasureTheory.riemannLebesgue_fourierCoefficient_tendsto_zero hf).norm
    | simpa [mul_comm, mul_left_comm, mul_assoc] using (MeasureTheory.riemannLebesgue hf)
    | simpa [mul_comm, mul_left_comm, mul_assoc] using (MeasureTheory.riemannLebesgue hf).norm
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (IntervalIntegrable.riemannLebesgue_fourierCoefficients_tendsto_zero hf)
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (IntervalIntegrable.riemannLebesgue_fourierCoefficients_tendsto_zero hf).norm
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (IntervalIntegrable.riemannLebesgue_fourierCoefficient_tendsto_zero hf)
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (IntervalIntegrable.riemannLebesgue_fourierCoefficient_tendsto_zero hf).norm
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (IntervalIntegrable.riemannLebesgue hf)
    | simpa [mul_comm, mul_left_comm, mul_assoc] using
        (IntervalIntegrable.riemannLebesgue hf).norm