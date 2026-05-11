import Mathlib

theorem summable_of_partial_sums_little_o_sqrt
    (a : ℕ → ℝ)
    (h :
      Filter.Tendsto
        (fun n : ℕ =>
          (Finset.sum (Finset.range n.succ) (fun j => a j.succ)) / Real.sqrt (n.succ : ℝ))
        Filter.atTop
        (𝓝 0)) :
    Summable (fun j : ℕ => a j.succ / (j.succ : ℝ)) := by
  sorry