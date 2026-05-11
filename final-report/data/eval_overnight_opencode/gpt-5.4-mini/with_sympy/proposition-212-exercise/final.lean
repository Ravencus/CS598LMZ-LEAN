import Mathlib

theorem lim_ge_of_eventually_ge
    {x y : ℕ → ℝ} {a b : ℝ}
    (hxy : ∀ᶠ n in Filter.atTop, x n ≥ y n)
    (hx : Filter.Tendsto x Filter.atTop (nhds a))
    (hy : Filter.Tendsto y Filter.atTop (nhds b)) :
    a ≥ b := by
  by_contra hlt
  have hab : a < b := lt_of_not_ge hlt
  let c : ℝ := (a + b) / 2
  have hac : a < c := by
    dsimp [c]
    linarith
  have hcb : c < b := by
    dsimp [c]
    linarith
  have hxlt' : ∃ N : ℕ, ∀ n ≥ N, x n < c := by
    simpa [Filter.Eventually, Filter.mem_atTop] using ((tendsto_order.mp hx).2 c hac)
  have hygt' : ∃ N : ℕ, ∀ n ≥ N, c < y n := by
    simpa [Filter.Eventually, Filter.mem_atTop] using ((tendsto_order.mp hy).1 c hcb)
  have hxy' : ∃ N : ℕ, ∀ n ≥ N, x n ≥ y n := by
    simpa [Filter.Eventually, Filter.mem_atTop] using hxy
  rcases hxlt' with ⟨Nx, hxN⟩
  rcases hygt' with ⟨Ny, hyN⟩
  rcases hxy' with ⟨Nxy, hxyN⟩
  let N : ℕ := max Nx (max Ny Nxy)
  have hNx : Nx ≤ N := by
    dsimp [N]
    exact Nat.le_max_left _ _
  have hNy : Ny ≤ N := by
    dsimp [N]
    exact le_trans (Nat.le_max_left _ _) (Nat.le_max_right _ _)
  have hNxy : Nxy ≤ N := by
    dsimp [N]
    exact le_trans (Nat.le_max_right _ _) (Nat.le_max_right _ _)
  have hxN : x N < c := hxN N hNx
  have hyN : c < y N := hyN N hNy
  have hxyN : x N ≥ y N := hxyN N hNxy
  linarith