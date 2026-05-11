import Mathlib
open Polynomial

example {α : ℝ} (h : IsAlgebraic ℚ α) : Monic (minpoly ℚ α) := by
  have h_int : IsIntegral ℚ α := by
    rcases h with ⟨f, hf, hfα⟩
    -- need to find a monic polynomial with α as root
    sorry
  exact minpoly.monic h_int