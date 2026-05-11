import Mathlib

open scoped BigOperators

noncomputable section

theorem aeuBounded_averages_tendsto_ae_zero
    {X : Type*} [MeasurableSpace X] {μ : Measure X} (f : ℕ → X → ℝ)
    (hf_meas : ∀ n : ℕ, Measurable (f n))
    (hf_ae_bdd : ∃ C : ℝ, ∀ᵐ x ∂μ, ∀ n : ℕ, ‖f n x‖ ≤ C)
    (hseries :
      Summable
        (fun N : ℕ =>
          ((1 : ℝ) / (N + 1 : ℝ)) *
            ∫ x, ((((N + 1 : ℝ)⁻¹) * (Finset.sum (Finset.Icc 1 (N + 1)) fun n => f n x)) ^ (2 : ℕ)) ∂μ)) :
    ∀ᵐ x ∂μ, Filter.Tendsto
      (fun N : ℕ =>
        ((N + 1 : ℝ)⁻¹) * (Finset.sum (Finset.Icc 1 (N + 1)) fun n => f n x))
      Filter.atTop (nhds 0) := by
  sorry