import Mathlib

theorem partialSums_littleO_of_series_div_nat_summable
    (a : ℕ → ℂ)
    (h : Summable (fun n : ℕ => a (n + 1) / ((n + 1 : ℕ) : ℂ))) :
    (fun N : ℕ => ∑ n in Finset.Icc 1 N, a n) =o[Filter.atTop] fun N : ℕ => (N : ℂ) := by
  sorry