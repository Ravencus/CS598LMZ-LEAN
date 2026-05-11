import Mathlib

open MeasureTheory Filter

theorem ae_tendsto_zero_of_L1_norm_geometric
    (f : ℕ → ℝ → ℝ)
    (h_meas : ∀ n : ℕ, Measurable (f n))
    (h_L1 : ∀ n : ℕ, Integrable (f n) ∧ ∫ x, ‖f n x‖ ∂volume ≤ (1 / 4 : ℝ) ^ n) :
    ∀ᵐ x ∂volume, Tendsto (fun n : ℕ => f n x) atTop (nhds 0) := by
  sorry