import Mathlib

def UniformlyDistributedModOne (u : ℕ → ℝ) : Prop := by
  sorry

theorem uniformlyDistributedModOne_of_all_positive_shifts
    (u : ℕ → ℝ)
    (h_uniform :
      ∀ h : ℕ, 0 < h → UniformlyDistributedModOne (fun n : ℕ => u (n + h) - u n)) :
    UniformlyDistributedModOne u := by
  sorry