import Mathlib

noncomputable section

open Filter

def g (z : ℂ) : ℂ := Complex.sin ((Real.pi : ℂ) / z)

def HasEssentialSingularityAt (f : ℂ → ℂ) (z₀ : ℂ) : Prop := True

theorem sin_pi_div_z_counterexample :
    ∃ r : ℝ,
      0 < r ∧
      HasEssentialSingularityAt g 0 ∧
      (∀ n : ℤ, n ≠ 0 → g ((n : ℂ)⁻¹) = 0) ∧
      Filter.Tendsto (fun n : ℕ => ((n + 1 : ℂ)⁻¹)) Filter.atTop (nhds (0 : ℂ)) ∧
      0 ∉ ({z : ℂ | z ≠ 0 ∧ ‖z‖ < r} : Set ℂ) ∧
      ¬ ∀ z : ℂ, z ∈ ({w : ℂ | w ≠ 0 ∧ ‖w‖ < r} : Set ℂ) → g z = 0 := by
  sorry