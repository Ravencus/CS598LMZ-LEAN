import Mathlib

noncomputable section

open scoped BigOperators Topology

def RPrime (N : ℕ) : ℝ :=
  ∑' k : ℕ,
    1 /
      (((N + k + 2 : ℕ) : ℝ) *
        ((N + k + 3 : ℕ) : ℝ) *
          (((N + k + 3).factorial : ℕ) : ℝ))

theorem RPrime_eventually_theta_one_div_factorial_mul_pow_five :
    ∃ c C : ℝ,
      0 < c ∧
      0 < C ∧
      ∃ N₀ : ℕ,
        ∀ N : ℕ,
          N₀ ≤ N →
            c * (1 / ((N.factorial : ℝ) * (N : ℝ) ^ 5)) ≤ RPrime N ∧
              RPrime N ≤ C * (1 / ((N.factorial : ℝ) * (N : ℝ) ^ 5)) := by
  sorry