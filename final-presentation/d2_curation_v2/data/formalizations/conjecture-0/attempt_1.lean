import Mathlib

theorem recursive_sequence_rpow_limit
    {a β : ℝ} (u : ℕ → ℝ)
    (ha : 0 < a) (hβ : 0 < β)
    (h_init : u 1 = a)
    (h_rec : ∀ n : ℕ, 1 ≤ n →
      u (n + 1) = u n + Real.rpow (n : ℝ) (2 * β) / (∑ k in Finset.Icc 1 n, u k)) :
    Filter.Tendsto
      (fun n : ℕ => u n / Real.rpow (n : ℝ) β)
      Filter.atTop
      (Filter.nhds (Real.sqrt ((β + 1) / β))) := by
  sorry