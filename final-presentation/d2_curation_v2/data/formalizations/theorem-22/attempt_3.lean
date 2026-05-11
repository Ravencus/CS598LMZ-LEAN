import Mathlib

noncomputable section

open MeasureTheory Filter

def fejerKernel (N : ℕ) (x : ℝ) : ℝ :=
  (1 / (N : ℝ)) * (Real.sin (((N : ℝ) * x) / 2) ^ 2) / (Real.sin (x / 2) ^ 2)

def IsApproximateIdentityInL1OnPi (K : ℕ → ℝ → ℝ) : Prop :=
  (∀ N x, 0 ≤ K (N + 1) x) ∧
  (∀ N, ∫ x in (-Real.pi)..Real.pi, K (N + 1) x = 2 * Real.pi) ∧
  ∀ ε > 0,
    Tendsto
      (fun N : ℕ =>
        ∫ x in {x : ℝ | ε ≤ |x| ∧ |x| ≤ Real.pi}, |K (N + 1) x| ∂volume)
      atTop
      (𝓝 0)

theorem fejerKernel_isApproximateIdentityInL1OnPi :
    IsApproximateIdentityInL1OnPi fejerKernel := by
  sorry