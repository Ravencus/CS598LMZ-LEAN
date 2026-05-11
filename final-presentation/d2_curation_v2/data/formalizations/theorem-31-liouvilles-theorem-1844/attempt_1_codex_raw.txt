import Mathlib

theorem liouville_approximation_lower_bound
    {α : ℝ} {d : ℕ}
    (h_alg : IsAlgebraic ℚ α)
    (h_deg : (minpoly ℚ α).natDegree = d)
    (hd : 2 ≤ d) :
    ∃ C : ℝ, 0 < C ∧ ∀ q : ℕ, 0 < q → ∀ p : ℤ,
      |α - (p : ℝ) / (q : ℝ)| > C / ((q : ℝ) ^ d) := by
  sorry