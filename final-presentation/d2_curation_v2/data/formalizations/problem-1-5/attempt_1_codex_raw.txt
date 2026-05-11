import Mathlib

theorem cesaro_mean_of_tendsto
    (x : ℕ → ℝ) (A : ℝ)
    (hx : Filter.Tendsto x Filter.atTop (nhds A)) :
    Filter.Tendsto
      (fun n : ℕ => (∑ i in Finset.Icc 1 n, x i) / (n : ℝ))
      Filter.atTop
      (nhds A) := by
  sorry