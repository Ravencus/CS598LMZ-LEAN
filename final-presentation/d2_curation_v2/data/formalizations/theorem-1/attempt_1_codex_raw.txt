import Mathlib

noncomputable section

open scoped BigOperators
open Filter MeasureTheory

def sampleMean {Ω : Type*} (X : ℕ → Ω → ℝ) (n : ℕ) : Ω → ℝ :=
  fun ω => (∑ i in Finset.range n.succ, X i ω) / (n.succ : ℝ)

def ConvergesInProbabilityTo {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (Y : ℕ → Ω → ℝ) (p : ℝ) : Prop :=
  ∀ ε : ℝ, 0 < ε →
    Tendsto (fun n => μ {ω | ε ≤ ‖Y n ω - p‖}) atTop (nhds 0)

def IsIID {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) (X : ℕ → Ω → ℝ) : Prop :=
  True

def HasMeanOn (E : Set ℝ) {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (X : ℕ → Ω → ℝ) (p : ℝ) : Prop :=
  p ∈ E ∧ ∀ n : ℕ, ∫ ω, X n ω ∂μ = p

def supNormOn (E : Set ℝ) (g : E → ℝ) : ℝ :=
  sSup (Set.range fun x : E => ‖g x‖)

theorem bounded_uniformly_continuous_expectation_uniform_convergence
    (E : Set ℝ) (f : ℝ → ℝ) (g : ℕ → E → ℝ)
    (h_bounded : ∃ C : ℝ, ∀ x ∈ E, ‖f x‖ ≤ C)
    (h_uc : UniformContinuous fun x : E => f x.1)
    (h_prob :
      ∀ p : E,
        ∃ (Ω : Type*) (_ : MeasurableSpace Ω) (μ : Measure Ω),
          IsProbabilityMeasure μ ∧
          ∃ X : ℕ → Ω → ℝ,
            IsIID μ X ∧
            HasMeanOn E μ X p.1 ∧
            ConvergesInProbabilityTo μ (sampleMean X) p.1 ∧
            (∀ n : ℕ, Integrable (fun ω => f (sampleMean X n ω)) μ) ∧
            (∀ n : ℕ, g n p = ∫ ω, f (sampleMean X n ω) ∂μ)) :
    Tendsto (fun n => supNormOn E (fun p => g n p - f p.1)) atTop (nhds 0) := by
  sorry