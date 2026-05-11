import Mathlib

theorem summable_of_partial_sums_little_o_sqrt
    (a : ℕ → ℝ)
    (h :
      Filter.Tendsto
        (fun n : ℕ =>
          (∑ j in Finset.range n.succ, a j.succ) / Real.sqrt (n.succ : ℝ))
        Filter.atTop
        (nhds 0)) :
    Summable (fun j : ℕ => a j.succ / (j.succ : ℝ)) := by
  sorry