import Mathlib

theorem lim_ge_of_eventually_ge
    {x y : ℕ → ℝ} {a b : ℝ}
    (hxy : ∀ᶠ n in Filter.atTop, x n ≥ y n)
    (hx : Filter.Tendsto x Filter.atTop (nhds a))
    (hy : Filter.Tendsto y Filter.atTop (nhds b)) :
    a ≥ b := by
  by_contra! hlt
  set ε := (b - a) / 2 with hε_def
  have hε_pos : ε > 0 := by linarith
  have hx_dist : ∀ᶠ n in Filter.atTop, dist (x n) a < ε :=
    (Metric.tendsto_nhds.mp hx) ε hε_pos
  have hy_dist : ∀ᶠ n in Filter.atTop, dist (y n) b < ε :=
    (Metric.tendsto_nhds.mp hy) ε hε_pos
  have hx_abs : ∀ᶠ n in Filter.atTop, |x n - a| < ε := by
    filter_upwards [hx_dist] with n hn
    rw [Real.dist_eq] at hn
    exact hn
  have hy_abs : ∀ᶠ n in Filter.atTop, |y n - b| < ε := by
    filter_upwards [hy_dist] with n hn
    rw [Real.dist_eq] at hn
    exact hn
  have hx_lt : ∀ᶠ n in Filter.atTop, x n < a + ε := by
    filter_upwards [hx_abs] with n hn
    have ⟨hlo, hhi⟩ := abs_lt.mp hn
    linarith
  have hy_gt : ∀ᶠ n in Filter.atTop, y n > b - ε := by
    filter_upwards [hy_abs] with n hn
    have ⟨hlo, hhi⟩ := abs_lt.mp hn
    linarith
  have h_mid : a + ε = b - ε := by
    dsimp [ε]
    ring
  have h_contra : ∀ᶠ n in Filter.atTop, x n < y n := by
    filter_upwards [hx_lt, hy_gt] with n hxlt hygt
    rw [← h_mid] at hygt
    linarith
  rcases Filter.eventually_atTop.mp h_contra with ⟨N₁, hN₁⟩
  rcases Filter.eventually_atTop.mp hxy with ⟨N₂, hN₂⟩
  let N := max N₁ N₂
  have h1 := hN₁ N (le_max_left _ _)
  have h2 := hN₂ N (le_max_right _ _)
  linarith