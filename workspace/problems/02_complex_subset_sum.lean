import Mathlib

/-
Let z₁, ..., zₙ be n complex numbers satisfying |z₁| + ... + |zₙ| = 1.
Prove that there exists a subset S such that |∑_{k ∈ S} zₖ| ≥ 1/6.
-/

theorem complex_subset_sum (n : ℕ) (z : Fin n → ℂ)
    (h : ∑ i, ‖z i‖ = 1) :
    ∃ S : Finset (Fin n), ‖∑ i ∈ S, z i‖ ≥ (1 : ℝ) / 6 := by
  sorry
