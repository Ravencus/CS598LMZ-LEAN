import Mathlib

theorem signed_series_liminf_limsup_and_weighted_partial_sums
    (p ε : ℕ → ℝ)
    (hp_pos : ∀ n, 0 < p n)
    (hp_mono : Antitone p)
    (hε : ∀ n, ε n = -1 ∨ ε n = 1)
    (hconv : Summable (fun n : ℕ => ε (n + 1) * p (n + 1))) :
    (¬ Summable (fun n : ℕ => p (n + 1)) →
      Filter.liminf
          (fun n : ℕ => ((∑ i in Finset.Icc 1 (n + 1), ε i) : ℝ) / (n + 1 : ℝ))
          Filter.atTop
        ≤ 0 ∧
      0 ≤
        Filter.limsup
          (fun n : ℕ => ((∑ i in Finset.Icc 1 (n + 1), ε i) : ℝ) / (n + 1 : ℝ))
          Filter.atTop) ∧
    Filter.Tendsto
      (fun n : ℕ => ((∑ i in Finset.Icc 1 (n + 1), ε i) : ℝ) * p (n + 1))
      Filter.atTop
      (nhds 0) := by
  sorry