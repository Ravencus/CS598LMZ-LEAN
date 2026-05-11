import Mathlib

theorem lim_ge_of_eventually_ge
    {x y : ℕ → ℝ} {a b : ℝ}
    (hxy : ∀ᶠ n in Filter.atTop, x n ≥ y n)
    (hx : Filter.Tendsto x Filter.atTop (nhds a))
    (hy : Filter.Tendsto y Filter.atTop (nhds b)) :
    a ≥ b := by
  have hle : ∀ᶠ n in Filter.atTop, y n - x n ≤ (0 : ℝ) := by
    filter_upwards [hxy] with n hn
    linarith
  have hlim : Filter.Tendsto (fun n => y n - x n) Filter.atTop (nhds (b - a)) := hy.sub hx
  have hbound : b - a ≤ 0 := Filter.le_of_tendsto hlim hle
  linarith