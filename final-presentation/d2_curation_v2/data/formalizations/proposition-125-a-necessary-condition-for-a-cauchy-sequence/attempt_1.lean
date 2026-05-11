import Mathlib

theorem cauchySeq_shift_diff_tendsto_zero {a : ℕ → ℝ} (ha : CauchySeq a) :
    ∀ p : ℕ, 0 < p → Filter.Tendsto (fun n : ℕ => |a (n + p) - a n|) Filter.atTop (nhds 0) := by
  sorry