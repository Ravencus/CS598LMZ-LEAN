import Mathlib

open scoped BigOperators

def DirichletConvolutionWithOne (g : ℕ → ℝ) : ℕ → ℝ :=
  fun n => ∑ d in n.divisors, g d

def HasMeanValue (f : ℕ → ℝ) (M : ℝ) : Prop :=
  Filter.Tendsto
    (fun N : ℕ => ((∑ n in Finset.range (N + 1), f (n + 1)) : ℝ) / (N + 1 : ℝ))
    Filter.atTop
    (𝓝 M)

theorem meanValue_of_dirichletConvolutionWithOne
    (f g : ℕ → ℝ)
    (hconv : ∀ n : ℕ, f n = DirichletConvolutionWithOne g n)
    (habs : Summable (fun n : ℕ => |g (n + 1)| / (n + 1 : ℝ))) :
    HasMeanValue f (∑' n : ℕ, g (n + 1) / (n + 1 : ℝ)) := by
  sorry