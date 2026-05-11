import Mathlib

theorem moment_formulas_common_functions :
    (∀ n k : ℕ,
      ∫ x in (0 : ℝ)..1, (Real.log x) ^ k * x ^ n
        = (((-1 : ℝ) ^ k) * (Nat.factorial k : ℝ)) / (((n : ℝ) + 1) ^ (k + 1))) ∧
    (∀ n : ℕ, ∀ a : ℝ,
      -1 < a →
        ∫ x in (0 : ℝ)..1, Real.rpow (1 - x) a * x ^ n
          = (Real.Gamma (a + 1) * (Nat.factorial n : ℝ)) / Real.Gamma (a + (n : ℝ) + 2)) ∧
    (∀ m : ℕ,
      ∫ x in (0 : ℝ)..1, x ^ (2 * m) / Real.sqrt (1 - x ^ 2)
        = (Real.pi / 2) *
            ((Nat.factorial (2 * m) : ℝ) /
              (((4 : ℝ) ^ m) * (Nat.factorial m : ℝ) ^ 2))) := by
  sorry