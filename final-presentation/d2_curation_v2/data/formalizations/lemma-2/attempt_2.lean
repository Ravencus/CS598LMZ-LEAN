import Mathlib

theorem variance_series_bound
    {α : Type*}
    (Y : ℕ → α)
    (V : α → ℝ≥0∞)
    (X : ℕ → ℝ)
    (E : ℝ → ℝ≥0∞) :
    (∑' k : ℕ, V (Y (k + 1)) / ((((k + 1 : ℕ) : ℝ≥0∞) ^ (2 : ℕ)))) ≤
      (4 : ℝ≥0∞) * E (|X 1|) ∧
      (4 : ℝ≥0∞) * E (|X 1|) < ⊤ := by
  sorry