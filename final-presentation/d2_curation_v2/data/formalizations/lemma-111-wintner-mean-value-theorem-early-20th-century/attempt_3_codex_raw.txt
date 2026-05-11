import Mathlib

def DirichletConvolutionWithOne (g : ℕ → ℝ) : ℕ → ℝ :=
  fun n => Finset.sum n.divisors g

def HasMeanValue (f : ℕ → ℝ) (M : ℝ) : Prop :=
  Filter.Tendsto
    (fun N : ℕ =>
      ((Finset.sum (Finset.range (N + 1)) fun n => f (n + 1)) : ℝ) / (N + 1 : ℝ))
    Filter.atTop
    (Filter.nhds M)

theorem meanValue_of_dirichletConvolutionWithOne
    (f g : ℕ → ℝ)
    (hconv : ∀ n : ℕ, f n = DirichletConvolutionWithOne g n)
    (habs : Summable (fun n : ℕ => |g (n + 1)| / (n + 1 : ℝ))) :
    HasMeanValue f (tsum (fun n : ℕ => g (n + 1) / (n + 1 : ℝ))) := by
  sorry