import Mathlib

theorem monotone_integer_sum_integral_estimate
    (f : ℝ → ℝ) (hf : Monotone f) (x y : ℤ) (hxy : y ≤ x) :
    ∃ C : ℝ,
      0 ≤ C ∧
        |(∑ n in Finset.Icc y x, f n) - (∫ t in (y : ℝ)..(x : ℝ), f t)|
          ≤ C * (|f x| + |f y|) := by
  sorry