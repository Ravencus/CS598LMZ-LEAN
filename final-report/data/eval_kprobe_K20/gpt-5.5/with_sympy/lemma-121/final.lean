import Mathlib

abbrev Torus : Type := { z : ℂ // ‖z‖ = (1 : ℝ) }

example : ¬ Subsingleton Torus := by
  intro h
  have hEq : (⟨(1 : ℂ), by simp⟩ : Torus) = ⟨(-1 : ℂ), by simp⟩ := Subsingleton.elim _ _
  have : (1 : ℂ) = -1 := by exact congrArg Subtype.val hEq
  norm_num at this
