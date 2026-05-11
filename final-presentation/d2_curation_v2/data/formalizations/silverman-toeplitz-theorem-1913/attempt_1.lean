import Mathlib

theorem toeplitz_schur_for_nonnegative_double_sequence
    (a : ℕ → ℕ → ℝ)
    (ha_nonneg : ∀ n k, 0 ≤ a n k)
    (ha_sum : ∀ n, 1 ≤ n → ∑ k in Finset.Icc 1 n, a n k = 1)
    (ha_tendsto : ∀ k, Filter.Tendsto (fun n => a n k) Filter.atTop (nhds 0)) :
    ∀ (x : ℕ → ℝ) (l : ℝ),
      Filter.Tendsto x Filter.atTop (nhds l) →
        Filter.Tendsto
          (fun n => ∑ k in Finset.Icc 1 n, a n k * x k)
          Filter.atTop
          (nhds l) := by
  sorry