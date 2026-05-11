import Mathlib

open MeasureTheory
open scoped Pointwise

theorem convolution_support_subset_closure_add_support
    (f g : ℝ → ℝ) :
    Function.support (fun z : ℝ => ∫ x : ℝ, f x * g (z - x))
      ⊆ closure (Function.support f + Function.support g) := by
  sorry