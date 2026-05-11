import Mathlib

theorem lim_ge_of_eventually_ge
    {x y : ℕ → ℝ} {a b : ℝ}
    (hxy : ∀ᶠ n in Filter.atTop, x n ≥ y n)
    (hx : Filter.Tendsto x Filter.atTop (nhds a))
    (hy : Filter.Tendsto y Filter.atTop (nhds b)) :
    a ≥ b := by
  by_contra h
  have hab : a < b := lt_of_not_ge h
  let ε : ℝ := (b - a) / 3

  have hε : 0 < ε := by
    dsimp [ε]
    nlinarith

  have hxI : ∀ᶠ n in Filter.atTop, x n ∈ Set.Ioo (a - ε) (a + ε) := by
    have hmem : Set.Ioo (a - ε) (a + ε) ∈ nhds a := by
      have ha : a ∈ Set.Ioo (a - ε) (a + ε) := by
        constructor <;> dsimp [ε] <;> nlinarith
      simpa using (isOpen_Ioo.mem_nhds ha)
    exact hx hmem

  have hyI : ∀ᶠ n in Filter.atTop, y n ∈ Set.Ioo (b - ε) (b + ε) := by
    have hmem : Set.Ioo (b - ε) (b + ε) ∈ nhds b := by
      have hb : b ∈ Set.Ioo (b - ε) (b + ε) := by
        constructor <;> dsimp [ε] <;> nlinarith
      simpa using (isOpen_Ioo.mem_nhds hb)
    exact hy hmem

  rcases (Filter.eventually_atTop.1 hxy) with ⟨Nxy, hNxy⟩
  rcases (Filter.eventually_atTop.1 hxI) with ⟨Nx, hNx⟩
  rcases (Filter.eventually_atTop.1 hyI) with ⟨Ny, hNy⟩

  let N : ℕ := max Nxy (max Nx Ny)

  have hNxyN : Nxy ≤ N := by
    dsimp [N]
    exact Nat.le_max_left _ _

  have hNxN : Nx ≤ N := by
    dsimp [N]
    exact le_trans (Nat.le_max_left _ _) (Nat.le_max_right _ _)

  have hNyN : Ny ≤ N := by
    dsimp [N]
    exact le_trans (Nat.le_max_right _ _) (Nat.le_max_right _ _)

  have hge : x N ≥ y N := hNxy N hNxyN

  have hxN : x N < a + ε := by
    have hmem := hNx hNxN
    exact (Set.mem_Ioo.mp hmem).2

  have hyN : b - ε < y N := by
    have hmem := hNy hNyN
    exact (Set.mem_Ioo.mp hmem).1

  have hlt : x N < y N := by
    have hgap : a + ε < b - ε := by
      dsimp [ε]
      nlinarith
    linarith

  exact (lt_irrefl _ (lt_of_lt_of_le hlt hge))