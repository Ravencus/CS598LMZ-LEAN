import Mathlib

noncomputable section

open MeasureTheory Real Filter

def fejerKernel (N : ℕ) (x : ℝ) : ℝ :=
  ((1 : ℝ) / N) * (Real.sin (N * x / 2)) ^ 2 / (Real.sin (x / 2)) ^ 2

def IsApproximateIdentityOnPi (K : ℕ → ℝ → ℝ) : Prop :=
  (∀ N, IntegrableOn (K N) (Set.Icc (-Real.pi) Real.pi)) ∧
  (∀ N x, 0 ≤ K N x) ∧
  Tendsto
    (fun N : ℕ => ∫ x in Set.Icc (-Real.pi) Real.pi, K N x)
    atTop
    (nhds (2 * Real.pi)) ∧
  ∀ δ : ℝ, 0 < δ →
    Tendsto
      (fun N : ℕ => ∫ x in {x ∈ Set.Icc (-Real.pi) Real.pi | δ ≤ |x|}, K N x)
      atTop
      (nhds 0)

theorem fejerKernel_approximateIdentity_L1 :
    IsApproximateIdentityOnPi fejerKernel := by
  sorry