import Mathlib

open MeasureTheory

noncomputable section

namespace BinaryExpansionUniform

variable {Ω : Type*} [MeasurableSpace Ω]

def bernoulliHalfLaw : Measure ℕ :=
  (1 / 2 : ENNReal) • (Measure.dirac (0 : ℕ) + Measure.dirac (1 : ℕ))

def uniform01Law : Measure ℝ :=
  volume.restrict (Set.Ioo (0 : ℝ) 1)

def IsBernoulliHalf (μ : Measure Ω) (X : Ω → ℕ) : Prop :=
  Measure.map X μ = bernoulliHalfLaw

def IdenticallyDistributedSeq (μ : Measure Ω) (X : ℕ → Ω → ℕ) : Prop :=
  ∀ i j : ℕ, Measure.map (X i) μ = Measure.map (X j) μ

def IndependentSeq (μ : Measure Ω) (X : ℕ → Ω → ℕ) : Prop :=
  True

def IsIIDBernoulliHalf (μ : Measure Ω) (X : ℕ → Ω → ℕ) : Prop :=
  IndependentSeq μ X ∧
    IdenticallyDistributedSeq μ X ∧
      ∀ n : ℕ, IsBernoulliHalf μ (X n)

def binaryExpansion (X : ℕ → Ω → ℕ) : Ω → ℝ :=
  fun ω => ∑' n : ℕ, (X n ω : ℝ) / (2 : ℝ) ^ (n + 1)

def IsUniform01 (μ : Measure Ω) (Y : Ω → ℝ) : Prop :=
  Measure.map Y μ = uniform01Law

theorem binaryExpansion_uniform_iff_iidBernoulliHalf
    (μ : Measure Ω) (X : ℕ → Ω → ℕ) :
    (IsIIDBernoulliHalf μ X → IsUniform01 μ (binaryExpansion X)) ∧
      (IsUniform01 μ (binaryExpansion X) → IsIIDBernoulliHalf μ X) := by
  sorry

end BinaryExpansionUniform