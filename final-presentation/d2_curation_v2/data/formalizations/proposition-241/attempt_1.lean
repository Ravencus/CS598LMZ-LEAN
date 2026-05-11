import Mathlib

open MeasureTheory Filter Topology BigOperators

noncomputable section

def variance {Ω : Type*} [MeasurableSpace Ω] (P : Measure Ω) [IsProbabilityMeasure P]
    (X : Ω → ℝ) : ℝ :=
  ∫ ω, (X ω - ∫ t, X t ∂P) ^ (2 : ℕ) ∂P

theorem l2_tendsto_zero_and_summable_variances_implies_ae_tendsto_zero
    {Ω : Type*} [MeasurableSpace Ω] (P : Measure Ω) [IsProbabilityMeasure P]
    (f : ℕ → Ω → ℝ)
    (h_int : ∀ n : ℕ, Integrable (f n) P)
    (h_sq_int : ∀ n : ℕ, Integrable (fun ω => ‖f n ω‖ ^ (2 : ℕ)) P)
    (h_l2 : Tendsto (fun n : ℕ => ∫ ω, ‖f n ω‖ ^ (2 : ℕ) ∂P) atTop (nhds 0))
    (h_var : Summable (fun n : ℕ => variance P (f n))) :
    ∀ᵐ ω ∂P, Tendsto (fun n : ℕ => f n ω) atTop (nhds 0) := by
  sorry