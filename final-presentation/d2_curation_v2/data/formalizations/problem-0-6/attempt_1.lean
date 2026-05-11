import Mathlib

theorem min_sequence_diverges_of_nonincreasing
    (a : ℕ → ℝ)
    (h_nonneg : ∀ n, 0 ≤ a n)
    (h_mono : ∀ n, a (n + 1) ≤ a n)
    (h_div : ¬ Summable (fun n : ℕ => a (n + 1))) :
    ¬ Summable (fun n : ℕ => min (a (n + 1)) (1 / ((n : ℝ) + 1))) := by
  sorry