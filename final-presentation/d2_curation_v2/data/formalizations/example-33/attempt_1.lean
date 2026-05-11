import Mathlib

theorem summable_nat_div_partialSums_of_summable_inv
    (a : ℕ → ℝ)
    (ha_pos : ∀ n : ℕ, 0 < a n)
    (ha_mono : Monotone a)
    (hconv : Summable (fun n : ℕ => (1 : ℝ) / a (n + 1))) :
    Summable (fun n : ℕ => ((n + 1 : ℕ) : ℝ) / ∑ i in Finset.range (n + 1), a (i + 1)) := by
  sorry