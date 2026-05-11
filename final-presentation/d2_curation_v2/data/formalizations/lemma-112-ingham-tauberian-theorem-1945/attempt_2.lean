import Mathlib

theorem dirichletConvolutionSummatoryAsymptotic
    (f g : ℕ → ℝ) (A : ℝ)
    (hconv : ∀ n : ℕ, f n = Finset.sum n.divisors g)
    (hF :
      ((fun x : ℝ => (∑ n in Finset.Icc 1 ⌊x⌋₊, f n) - A * x) =o[Filter.atTop]
        fun x => x)) :
    ((fun x : ℝ =>
        (∑ n in Finset.Icc 1 ⌊x⌋₊, g n / (n : ℝ)) -
          (((∑ n in Finset.Icc 1 ⌊x⌋₊, g n) / x) + A)) =o[Filter.atTop]
      fun x => (1 : ℝ)) := by
  sorry