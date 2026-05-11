import Mathlib

open scoped BigOperators

theorem truncated_average_converges_ae_to_expectation
    {Ω : Type*}
    [MeasurableSpace Ω]
    (ℙ : MeasureTheory.Measure Ω)
    [ProbabilityTheory.IsProbabilityMeasure ℙ]
    (X : ℕ → Ω → ℝ)
    (μ : ℝ)
    (h_meas : ∀ n, MeasureTheory.AEStronglyMeasurable (X n) ℙ)
    (h_nonneg : ∀ n ω, 0 ≤ X n ω)
    (h_indep : ProbabilityTheory.iIndepFun X ℙ)
    (h_ident : ∀ n, ProbabilityTheory.IdentDistrib (X n) (X 0) ℙ ℙ)
    (h_int : MeasureTheory.Integrable (X 0) ℙ)
    (hμ : ∫ ω, X 0 ω ∂ℙ = μ) :
    let Y : ℕ → Ω → ℝ := fun i ω => if |X i ω| ≤ (i : ℝ) then X i ω else 0
    let T : ℕ → Ω → ℝ := fun n ω => Finset.sum (Finset.Icc 1 n) (fun i => Y i ω)
    ∀ᵐ ω ∂ℙ, Filter.Tendsto (fun n : ℕ => T n ω / (n : ℝ)) Filter.atTop (nhds μ) := by
  sorry