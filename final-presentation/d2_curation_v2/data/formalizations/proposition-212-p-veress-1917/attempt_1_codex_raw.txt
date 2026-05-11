import Mathlib

theorem fractional_parts_partial_sums_dense
    (a : ℕ → ℝ)
    (ha_pos : ∀ k : ℕ, 1 ≤ k → 0 < a k)
    (ha_tendsto : Filter.Tendsto a Filter.atTop (nhds 0))
    (ha_nonsummable : ¬ Summable (fun k : ℕ => a (k + 1))) :
    ∀ x ∈ Set.Ico (0 : ℝ) 1, ∀ ε > 0, ∃ n : ℕ,
      |Int.fract (∑ k in Finset.Icc 1 n, a k) - x| < ε := by
  sorry