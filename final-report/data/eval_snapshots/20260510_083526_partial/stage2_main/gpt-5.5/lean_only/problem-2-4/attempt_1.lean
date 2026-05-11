import Mathlib

theorem convolution_average_tendsto_mul
    (x y : ℕ → ℝ) (A B : ℝ)
    (hx : Filter.Tendsto x Filter.atTop (nhds A))
    (hy : Filter.Tendsto y Filter.atTop (nhds B)) :
    Filter.Tendsto
      (fun n : ℕ =>
        (Finset.sum (Finset.range (n + 1)) (fun k => x k * y (n - k))) / ((n + 1 : ℕ) : ℝ))
      Filter.atTop
      (nhds (A * B)) := by
  simpa using hx.cesaro_mul hy