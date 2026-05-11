import Mathlib

open scoped BigOperators

-- The requested theorem is not provable as stated.
-- Reason: `ζ : ℝ → ℝ` is completely arbitrary, but the conclusion asserts a
-- specific asymptotic formula with a uniformly small error term for that
-- arbitrary function.
--
-- For example, if one takes `ζ := fun _ => 10^100`, the stated bound on `E n`
-- cannot hold in general, because the first conjunct forces `E n` to absorb the
-- arbitrary value of `ζ r`.
--
-- A provable version would need `ζ` to be the actual Riemann zeta function (or
-- at least assume the relevant identity), and would also require substantial
-- analytic infrastructure beyond what is present in the statement.

theorem zeta_partial_sum_euler_maclaurin
    (ζ : ℝ → ℝ) (r : ℝ) (hr : 1 < r) :
    ∃ E : ℕ → ℝ,
      ∀ n : ℕ, 1 ≤ n →
        (Finset.sum (Finset.Icc 1 n) (fun k => Real.rpow (k : ℝ) (-r)) =
            ζ r
              + (1 / (1 - r)) * Real.rpow (n : ℝ) (1 - r)
              + (1 / 2 : ℝ) * Real.rpow (n : ℝ) (-r)
              - (r / 12 : ℝ) * Real.rpow (n : ℝ) (-r - 1)
              + E n)
          ∧
          |E n| < (r * (r + 1) * (r + 2)) / (720 * Real.rpow (n : ℝ) (r + 3)) := by
  sorry