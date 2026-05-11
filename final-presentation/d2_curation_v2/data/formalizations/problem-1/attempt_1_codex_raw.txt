import Mathlib

open scoped BigOperators Topology

theorem cesaro_mean_of_convergent_sequence
    {x : ℕ → ℝ} {A : ℝ}
    (hx : Filter.Tendsto x Filter.atTop (nhds A)) :
    Filter.Tendsto
      (fun n : ℕ => (∑ k in Finset.range n, x (k + 1)) / (n : ℝ))
      Filter.atTop
      (nhds A) := by
  sorry