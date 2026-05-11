import Mathlib

open Filter

theorem lim_ge_of_eventually_ge
    {x y : ℕ → ℝ} {a b : ℝ}
    (hxy : ∀ᶠ n in Filter.atTop, x n ≥ y n)
    (hx : Filter.Tendsto x Filter.atTop (nhds a))
    (hy : Filter.Tendsto y Filter.atTop (nhds b)) :
    a ≥ b := by
  have hb_le_a : b ≤ a :=
    @le_of_tendsto_of_tendsto ℝ ℕ _ _ _ y x b a atTop hy hx
      (by filter_upwards [hxy] with n hn using hn)
      (by exact atTop_neBot)
  exact hb_le_a