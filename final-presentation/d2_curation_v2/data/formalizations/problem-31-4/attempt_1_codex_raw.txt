import Mathlib

noncomputable def decimalDigit (n : ℕ) (x : ℝ) : ℤ :=
  Int.floor (((10 : ℝ) ^ n) * x) % 10

noncomputable def decimalDigitSeries (x : ℝ) : ℝ :=
  ∑' n : ℕ, ((decimalDigit (n + 1) x : ℝ) / (3 : ℝ) ^ (n + 1))

theorem integral_square_decimalDigitSeries :
    ∫ x in (0 : ℝ)..1, (decimalDigitSeries x) ^ 2 ∂volume = (195 : ℝ) / 32 := by
  sorry