import Mathlib

theorem convolution_average_tendsto_mul
    (x y : ℕ → ℝ) (A B : ℝ)
    (hx : Filter.Tendsto x Filter.atTop (nhds A))
    (hy : Filter.Tendsto y Filter.atTop (nhds B)) :
    Filter.Tendsto
      (fun n : ℕ =>
        ((∑ k in Finset.range (n + 1), x k * y (n - k)) : ℝ) / (n + 1 : ℝ))
      Filter.atTop
      (nhds (A * B)) := by
  sorry