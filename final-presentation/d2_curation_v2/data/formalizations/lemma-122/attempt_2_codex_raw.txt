import Mathlib

open Set

noncomputable def uniformNormOn (s : Set ℝ) (f : ℝ → ℂ) : ℝ :=
  sSup ((fun x : ℝ => ‖f x‖) '' s)

def CirclePolynomial (P : ℂ → ℂ) : Prop :=
  ∃ s : Finset ℤ, ∃ c : ℤ → ℂ, ∀ z : ℂ, P z = Finset.sum s (fun n => c n * z ^ (Int.natAbs n))

theorem periodic_continuous_complex_uniform_trig_approx
    (f : ℝ → ℂ)
    (hf : ContinuousOn f (Set.Icc (-((1 : ℝ) / 2)) ((1 : ℝ) / 2)))
    (hperiod : f (-((1 : ℝ) / 2)) = f ((1 : ℝ) / 2)) :
    ∀ ε : ℝ, ε > 0 →
      ∃ P : ℂ → ℂ,
        CirclePolynomial P ∧
        uniformNormOn
          (Set.Icc (-((1 : ℝ) / 2)) ((1 : ℝ) / 2))
          (fun x => f x - P (Complex.exp (2 * Real.pi * Complex.I * (x : ℂ)))) < ε := by
  sorry