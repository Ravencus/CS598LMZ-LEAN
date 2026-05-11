import Mathlib

theorem fractional_parts_dense_of_nondecreasing_positive_tendsto_infty
    (x : ℕ → ℝ)
    (hmono : Monotone x)
    (hpos : ∀ n : ℕ, 0 < x n)
    (htendsto : Filter.Tendsto x Filter.atTop Filter.atTop)
    (hdiff : Filter.Tendsto (fun n : ℕ => x (n + 1) - x n) Filter.atTop (nhds 0)) :
    DenseRange (fun n : ℕ => (⟨Int.fract (x n), ⟨Int.fract_nonneg (x n), Int.fract_lt_one (x n)⟩⟩ : Set.Ico (0 : ℝ) 1)) := by
  sorry