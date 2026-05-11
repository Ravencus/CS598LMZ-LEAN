import Mathlib

open MeasureTheory

theorem ae_absolutelyConvergent_series_div_sqrt_abs_sub
    (a r : ℕ → ℝ)
    (ha : Summable (fun n => |a n|)) :
    ∀ᵐ x : ℝ ∂volume, Summable (fun n => |a n / Real.sqrt (|x - r n|)|) := by
  sorry