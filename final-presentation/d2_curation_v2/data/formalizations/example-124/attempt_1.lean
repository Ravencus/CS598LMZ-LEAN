import Mathlib

theorem sin_nat_has_no_limit :
    (∃ n m : ℕ → ℕ,
      (∀ k : ℕ,
        let K : ℝ := ((k + 1 : ℕ) : ℝ)
        2 * K * Real.pi + Real.pi / 4 < (n k : ℝ) ∧
          (n k : ℝ) < 2 * K * Real.pi + 2 * Real.pi / 3) ∧
      (∀ k : ℕ,
        let K : ℝ := ((k + 1 : ℕ) : ℝ)
        2 * K * Real.pi + 5 * Real.pi / 4 < (m k : ℝ) ∧
          (m k : ℝ) < 2 * K * Real.pi + 5 * Real.pi / 3) ∧
      ∀ k : ℕ, Real.sqrt 2 ≤ |Real.sin (n k) - Real.sin (m k)|) ∧
    ¬ ∃ l : ℝ, Filter.Tendsto (fun n : ℕ => Real.sin n) Filter.atTop (nhds l) := by
  sorry