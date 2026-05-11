import Mathlib

theorem arithmetic_function_dirichlet_series_implies_partial_sum_decay
    (f : ℕ → ℂ)
    (h :
      ∃ s : ℂ,
        0 < s.re ∧
          Summable (fun n : ℕ => f (n + 1) / Complex.cpow (((n + 1 : ℕ) : ℂ)) s)) :
    ∃ s : ℂ,
      0 < s.re ∧
        Filter.Tendsto
          (fun N : ℕ =>
            (Complex.cpow (((N + 1 : ℕ) : ℂ)) s)⁻¹ *
              ∑ n in Finset.Icc 1 (N + 1), f n)
          Filter.atTop
          (nhds 0) := by
  sorry