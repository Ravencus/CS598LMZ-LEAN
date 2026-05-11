import Mathlib

open scoped BigOperators

def MeanValue (f : ℕ → ℂ) (L : ℂ) : Prop :=
  Filter.Tendsto
    (fun N : ℕ => (Finset.sum (Finset.range N) (fun n => f (n + 1)) : ℂ) / (N : ℂ))
    Filter.atTop
    (nhds L)

theorem meanValue_of_dirichletConvolution
    (f g : ℕ → ℂ)
    (hconv : ∀ n : ℕ, f (n + 1) = Finset.sum (n + 1).divisors (fun d => g ((n + 1) / d)))
    (habs : Summable (fun n : ℕ => ‖g (n + 1) / (n + 1 : ℂ)‖)) :
    ∃ L : ℂ, MeanValue f L ∧ L = ∑' n : ℕ, g (n + 1) / (n + 1 : ℂ) := by
  sorry