import Mathlib

open Filter Topology BigOperators

theorem silvermanToeplitz_real
    (a : ℕ → ℕ → ℝ) (x : ℕ → ℝ) (l : ℝ)
    (h_sum_one : Filter.Tendsto (fun n => ∑ k in Finset.Icc 1 n, a n k) Filter.atTop (nhds 1))
    (h_pointwise : ∀ k : ℕ, Filter.Tendsto (fun n => a n k) Filter.atTop (nhds 0))
    (h_bdd : ∃ C : ℝ, ∀ n : ℕ, ∑ k in Finset.Icc 1 n, |a n k| ≤ C)
    (h_conv : Filter.Tendsto x Filter.atTop (nhds l)) :
    Filter.Tendsto (fun n => ∑ k in Finset.Icc 1 n, a n k * x k) Filter.atTop (nhds l) := by
  sorry