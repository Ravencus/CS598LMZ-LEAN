import Mathlib

theorem riemann_sum_error_limit
    (f : ℝ → ℝ) (hf : ContDiff ℝ 2 f) :
    Filter.Tendsto
      (fun n : ℕ =>
        (n : ℝ) *
          ((∫ t in (0 : ℝ)..1, f t) -
            (1 / (n : ℝ)) * (∑ k in Finset.range n, f ((k : ℝ) / (n : ℝ)))))
      Filter.atTop
      (nhds ((f 1 - f 0) / 2)) := by
  sorry