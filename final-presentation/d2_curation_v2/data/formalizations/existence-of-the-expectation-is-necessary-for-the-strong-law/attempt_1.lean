import Mathlib

open MeasureTheory Filter
open scoped BigOperators ENNReal

def partialSums {Ω : Type*} (X : ℕ → Ω → ℝ) (ω : Ω) (n : ℕ) : ℝ :=
  ∑ i in Finset.range (n + 1), X i ω

def CesaroFiniteLimitEvent {Ω : Type*} (X : ℕ → Ω → ℝ) : Set Ω :=
  {ω | ∃ l : ℝ, Tendsto (fun n : ℕ => partialSums X ω n / (n + 1 : ℝ)) atTop (nhds l)}

def IsIID {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) (X : ℕ → Ω → ℝ) : Prop :=
  True

theorem iid_no_finite_limit_of_infinite_mean
    {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
    (X : ℕ → Ω → ℝ)
    (h_iid : IsIID μ X)
    (h_expectation : ∫⁻ ω, ENNReal.ofReal ‖X 0 ω‖ ∂μ = ∞) :
    μ (CesaroFiniteLimitEvent X) = 0 := by
  sorry