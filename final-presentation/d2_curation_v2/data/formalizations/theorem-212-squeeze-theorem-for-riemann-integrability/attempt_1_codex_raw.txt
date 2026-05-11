import Mathlib

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