import Mathlib

theorem measure_set_ge_le_LpNorm_pow
    {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (fₙ f : α → ℝ) (ε : ℝ) (p : ℕ) :
    μ ({x : α | |fₙ x - f x| ≥ ε} : Set α) ≤
      ENNReal.ofReal ((ε ^ p)⁻¹ * ∫ x, ‖fₙ x - f x‖ ^ p ∂μ) := by
  sorry