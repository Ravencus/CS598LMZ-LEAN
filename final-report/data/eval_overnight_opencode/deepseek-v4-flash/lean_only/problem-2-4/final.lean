import Mathlib
open Filter
open Finset
example (a : ℕ → ℝ) (ha : Filter.Tendsto a Filter.atTop (nhds (0 : ℝ))) :
    Filter.Tendsto (fun n : ℕ => (∑ k ∈ range n, a k) / (n : ℝ)) Filter.atTop (nhds (0 : ℝ)) := by
  simpa [div_eq_mul_inv, mul_comm] using ha.cesaro