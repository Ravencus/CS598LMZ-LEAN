import Mathlib

open scoped BigOperators
open Filter

noncomputable section

def arithmeticOne : ℕ → ℂ := fun _ => 1

def dirichletConvolution (f g : ℕ → ℂ) (n : ℕ) : ℂ :=
  ∑ d in n.divisors, f d * g (n / d)

def LSeries (f : ℕ → ℂ) (s : ℂ) : ℂ :=
  ∑' n : ℕ, f (n + 1) / Complex.cpow ((n + 1 : ℕ) : ℂ) s

def riemannZeta (s : ℂ) : ℂ :=
  ∑' n : ℕ, (1 : ℂ) / Complex.cpow ((n + 1 : ℕ) : ℂ) s

def meanValueSeq (f : ℕ → ℂ) (N : ℕ) : ℂ :=
  (∑ n in Finset.Icc 1 N, f n) / (N : ℂ)

def MeanValueExists (f : ℕ → ℂ) (c : ℂ) : Prop :=
  Tendsto (meanValueSeq f) atTop (nhds c)

theorem dirichlet_generating_function_of_convolution
    (f g : ℕ → ℂ) (s : ℂ)
    (hf : f = dirichletConvolution g arithmeticOne)
    (hs : 1 < s.re) :
    LSeries f s = riemannZeta s * LSeries g s := by
  sorry

theorem mean_value_of_convolution
    (f g : ℕ → ℂ)
    (hf : f = dirichletConvolution g arithmeticOne)
    (hg : Summable (fun n : ℕ => ‖g (n + 1) / (((n + 1 : ℕ) : ℂ))‖)) :
    MeanValueExists f (∑' n : ℕ, g (n + 1) / (((n + 1 : ℕ) : ℂ))) := by
  sorry