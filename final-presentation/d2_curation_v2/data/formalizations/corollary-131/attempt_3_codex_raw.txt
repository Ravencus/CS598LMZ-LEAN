import Mathlib

open Filter Topology
open scoped BigOperators

theorem partialSums_dense_in_open_interval_of_bounded_divergent
    (a : ℕ → ℝ)
    (ha0 : Tendsto a atTop (nhds 0))
    (hbounded : ∃ M : ℝ, ∀ N : ℕ, |(∑ n in Finset.range (N + 1), a n)| ≤ M)
    (hdiv :
      ¬ ∃ l : ℝ, Tendsto (fun N : ℕ => ∑ n in Finset.range (N + 1), a n) atTop (nhds l)) :
    ∀ x ∈
        Set.Ioo
          (sInf
            {y : ℝ |
              Filter.ClusterPt y
                (Filter.map (fun N : ℕ => ∑ n in Finset.range (N + 1), a n) atTop)})
          (sSup
            {y : ℝ |
              Filter.ClusterPt y
                (Filter.map (fun N : ℕ => ∑ n in Finset.range (N + 1), a n) atTop)}),
      ∀ ε > 0, ∃ N : ℕ, |(∑ n in Finset.range (N + 1), a n) - x| < ε := by
  sorry