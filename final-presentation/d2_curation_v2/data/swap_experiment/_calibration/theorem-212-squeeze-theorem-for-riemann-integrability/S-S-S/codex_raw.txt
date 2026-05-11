import Mathlib

-- The requested theorem is not provable with this exact signature.
--
-- Counterexample: take `a = 1`, `b = 0`, and `f x = 1 / x`.
-- Then the right-hand side is true for every `ε > 0` by choosing `α = β = 0`,
-- because `Set.Icc 1 0 = ∅`, so the order hypotheses are vacuous and
-- `|∫ x in 1..0, (0 - 0)| = 0 < ε`.
--
-- But the left-hand side is false: `IntervalIntegrable (fun x : ℝ => 1 / x) volume 1 0`
-- fails because this is the same as integrability on `(0,1]`.
--
-- So the equivalence is false as stated. A correction would at least need the
-- pointwise bounds on `Set.uIcc a b` (or an assumption `a ≤ b`), and likely a
-- different formalization if the intent is genuinely the Riemann criterion rather
-- than Lebesgue `IntervalIntegrable`.

theorem riemannIntegrable_iff_exists_intervalIntegrable_bounds
    {a b : ℝ} {f : ℝ → ℝ} :
    IntervalIntegrable f volume a b ↔
      ∀ ε > 0, ∃ α β : ℝ → ℝ,
        IntervalIntegrable α volume a b ∧
        IntervalIntegrable β volume a b ∧
        (∀ x ∈ Set.Icc a b, α x ≤ f x) ∧
        (∀ x ∈ Set.Icc a b, f x ≤ β x) ∧
        |∫ x in a..b, (α x - β x)| < ε := by
  sorry