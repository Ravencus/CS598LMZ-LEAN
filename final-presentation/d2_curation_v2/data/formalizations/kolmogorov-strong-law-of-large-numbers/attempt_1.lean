import Mathlib

open MeasureTheory ProbabilityTheory Filter

theorem strong_law_average_of_independent_mean_zero
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (X : ℕ → Ω → ℝ)
    (hindep : iIndepFun X)
    (h_int : ∀ n, Integrable (X n) μ)
    (h_mean_zero : ∀ n, ∫ ω, X n ω ∂ μ = 0)
    (h_finite_variance : ∀ n, Integrable (fun ω => (X n ω)^2) μ)
    (h_var_summable :
      Summable (fun n : ℕ => (∫ ω, (X n ω)^2 ∂ μ) / (((n : ℝ) + 1) ^ 2))) :
    ∀ᵐ ω ∂ μ,
      Tendsto
        (fun n : ℕ => (∑ i in Finset.range (n + 1), X i ω) / ((n : ℝ) + 1))
        atTop
        (nhds 0) := by
  sorry