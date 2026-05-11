import Mathlib

open scoped BigOperators Topology Interval
open Filter

def UniformlyDistributedModOne (u : ℕ → ℝ) : Prop := True

def WeylExponentialCondition (u : ℕ → ℝ) : Prop :=
  ∀ k : ℤ, k ≠ 0 →
    Tendsto
      (fun N : ℕ =>
        ((N : ℂ)⁻¹) *
          Finset.sum (Finset.Icc 1 N) (fun n : ℕ =>
            Complex.exp ((((2 : ℝ) * Real.pi * (k : ℝ) * u n) : ℂ) * Complex.I)))
      atTop
      (nhds 0)

def ContinuousTestCondition (u : ℕ → ℝ) (ε : ℝ → ℝ) : Prop :=
  (∀ x, ε x ∈ Set.Icc (-(1 / 2 : ℝ)) (1 / 2 : ℝ)) ∧
    ∀ f : ℝ → ℂ,
      ContinuousOn f (Set.Icc (-(1 / 2 : ℝ)) (1 / 2 : ℝ)) →
        Tendsto
          (fun N : ℕ =>
            ((N : ℂ)⁻¹) * Finset.sum (Finset.Icc 1 N) (fun n : ℕ => f (ε (u n))))
          atTop
          (nhds 0)

theorem uniformlyDistributedModuloOne_iff_weyl_and_continuousTest
    (u : ℕ → ℝ) (ε : ℝ → ℝ) :
    (UniformlyDistributedModOne u ↔ WeylExponentialCondition u) ∧
      (UniformlyDistributedModOne u ↔ ContinuousTestCondition u ε) := by
  sorry