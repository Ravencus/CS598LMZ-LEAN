import Mathlib

open Filter

theorem lim_ge_of_eventually_ge
    {x y : ℕ → ℝ} {a b : ℝ}
    (hxy : ∀ᶠ n in Filter.atTop, x n ≥ y n)
    (hx : Filter.Tendsto x Filter.atTop (nhds a))
    (hy : Filter.Tendsto y Filter.atTop (nhds b)) :
    a ≥ b := by
  have hle : b ≤ a := le_of_tendsto_of_tendsto hy hx (by
    filter_upwards [hxy] with n hn
    exact hn)
  exact hle