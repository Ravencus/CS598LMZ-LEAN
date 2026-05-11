import Mathlib

open Filter Asymptotics

noncomputable def partialPowerSum (r : ℝ) (n : ℕ) : ℝ :=
  ∑ k ∈ Finset.Icc 1 n, Real.rpow (k : ℝ) (-r)

noncomputable def mainTerm (ζ : ℝ → ℝ) (r : ℝ) (n : ℕ) : ℝ :=
  ζ r
    + (1 / (1 - r)) * Real.rpow (n : ℝ) (1 - r)
    + (1 / 2 : ℝ) * Real.rpow (n : ℝ) (-r)
    - (r / 12) * Real.rpow (n : ℝ) (-r - 1)

noncomputable def harmonicMainTerm (γ : ℝ) (n : ℕ) : ℝ :=
  γ + Real.log (n : ℝ)
    + (1 / 2 : ℝ) * Real.rpow (n : ℝ) (-1 : ℝ)
    - (1 / 12 : ℝ) * Real.rpow (n : ℝ) (-2 : ℝ)

theorem generalized_harmonic_sum_asymptotic
    (ζ : ℝ → ℝ) (γ : ℝ) :
    (∀ r : ℝ, 0 < r → r ≠ 1 →
      (fun n : ℕ => partialPowerSum r n - mainTerm ζ r n) =O[atTop]
        (fun n : ℕ => Real.rpow (n : ℝ) (-r - 3))) ∧
    ((fun n : ℕ => partialPowerSum 1 n - harmonicMainTerm γ n) =O[atTop]
      (fun n : ℕ => Real.rpow (n : ℝ) (-4 : ℝ))) := by
  sorry