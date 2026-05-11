import Mathlib

def Ω : Set ℕ := {n : ℕ | 3 ≤ n}

noncomputable def L (n : ℕ) : ℝ :=
  2 * (n : ℝ) * Real.sin (Real.pi / (n : ℝ))

theorem unitCircleInscribedRegularPolygonsApproximation (a : ℝ) :
    (∀ n : ℕ, n ∈ Ω ↔ 3 ≤ n) ∧
    (∀ n : ℕ, L n = 2 * (n : ℝ) * Real.sin (Real.pi / (n : ℝ))) ∧
    (∀ ε > 0, ∃ p_n ∈ Ω, |L p_n - a| < ε) := by
  sorry