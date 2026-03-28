import Mathlib

/-
Let z₁, ..., zₙ be n complex numbers satisfying |z₁| + ... + |zₙ| = 1.
Prove that there exists a subset S such that |∑_{k ∈ S} zₖ| ≥ 1/π.

This is the optimal bound — achieved by the uniform distribution on the circle,
where the best subset (a semicircle) gives exactly 1/π.
-/

theorem complex_subset_sum_pi (n : ℕ) (z : Fin n → ℂ)
    (h : ∑ i, ‖z i‖ = 1) :
    ∃ S : Finset (Fin n), ‖∑ i ∈ S, z i‖ ≥ 1 / Real.pi := by
  sorry
