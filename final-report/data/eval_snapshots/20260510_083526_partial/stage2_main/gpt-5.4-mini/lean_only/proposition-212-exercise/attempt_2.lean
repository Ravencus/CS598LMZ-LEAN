import Mathlib

theorem lim_ge_of_eventually_ge
    {x y : ℕ → ℝ} {a b : ℝ}
    (hxy : ∀ᶠ n in Filter.atTop, x n ≥ y n)
    (hx : Filter.Tendsto x Filter.atTop (nhds a))
    (hy : Filter.Tendsto y Filter.atTop (nhds b)) :
    a ≥ b := by
  have hxy' : ∀ᶠ n in Filter.atTop, y n ≤ x n := by
    simpa [ge_iff_le] using hxy
  exact Filter.Tendsto.le_of_eventuallyLE hy hx hxy'