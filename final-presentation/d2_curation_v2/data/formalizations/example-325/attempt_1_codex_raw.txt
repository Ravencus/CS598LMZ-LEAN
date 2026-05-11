import Mathlib

noncomputable section

def I_n (n : ℕ) : ℝ :=
  (n : ℝ) * ∫ x in (0 : ℝ)..1, Real.log (1 + Real.exp x / (n : ℝ))

theorem I_n_def (n : ℕ) :
    I_n n = (n : ℝ) * ∫ x in (0 : ℝ)..1, Real.log (1 + Real.exp x / (n : ℝ)) := by
  sorry