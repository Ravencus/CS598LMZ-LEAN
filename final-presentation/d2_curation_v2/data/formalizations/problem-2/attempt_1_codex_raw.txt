import Mathlib

theorem convolution_average_tendsto
    (x y : ℕ → ℝ) (A B : ℝ)
    (hx : Filter.Tendsto x Filter.atTop (Filter.nhds A))
    (hy : Filter.Tendsto y Filter.atTop (Filter.nhds B)) :
    Filter.Tendsto
      (fun n : ℕ =>
        ((∑ k in Finset.range (n + 1), x (k + 1) * y (n + 1 - k)) /
          (((n + 1 : ℕ) : ℝ))))
      Filter.atTop
      (Filter.nhds (A * B)) := by
  sorry