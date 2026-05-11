import Mathlib

open scoped BigOperators
open Filter MeasureTheory

theorem strong_law_of_large_numbers_ae
    {Ω : Type*} [MeasurableSpace Ω]
    (P : Measure Ω) [IsProbabilityMeasure P]
    (X : ℕ → Ω → ℝ)
    (h_indep : Pairwise (fun i j => ProbabilityTheory.IndepFun (X i) (X j) P))
    (h_ident : ∀ n : ℕ, ProbabilityTheory.IdentDistrib (X n) (X 0) P P)
    (h_fourth_moment : Integrable (fun ω => |X 0 ω| ^ (4 : ℕ)) P) :
    ∀ᵐ ω ∂P,
      Tendsto
        (fun n : ℕ => (Finset.sum (Finset.range n) fun i => X i ω) / (n : ℝ))
        atTop
        (𝓝 (∫ ω, X 0 ω ∂P)) := by
  sorry