import Mathlib

theorem convolution_average_tendsto
    (x y : ℕ → ℝ) (A B : ℝ)
    (hx : Filter.Tendsto x Filter.atTop (nhds A))
    (hy : Filter.Tendsto y Filter.atTop (nhds B)) :
    Filter.Tendsto
      (fun n : ℕ =>
        (Finset.sum (Finset.range (n + 1)) (fun k => x (k + 1) * y (n + 1 - k))) /
          (((n + 1 : ℕ) : ℝ)))
      Filter.atTop
      (nhds (A * B)) := by
  sorry