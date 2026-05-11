import Mathlib

abbrev Torus : Type := { z : ℂ // ‖z‖ = (1 : ℝ) }

example : Torus := ⟨1, by simp⟩
