import Mathlib

open MeasureTheory

theorem fourier_inversion_for_function_class
    (𝓕 : Set (ℝ → ℂ))
    (fourier : (ℝ → ℂ) → ℝ → ℂ)
    (h𝓕 :
      ∀ ⦃f : ℝ → ℂ⦄, f ∈ 𝓕 →
        ∀ x : ℝ, ∫ ξ : ℝ, fourier f ξ * Complex.exp ((((2 * Real.pi * x * ξ : ℝ) : ℂ) * Complex.I)) = f x) :
    ∀ ⦃f : ℝ → ℂ⦄, f ∈ 𝓕 →
      ∀ x : ℝ, ∫ ξ : ℝ, fourier f ξ * Complex.exp ((((2 * Real.pi * x * ξ : ℝ) : ℂ) * Complex.I)) = f x := by
  sorry