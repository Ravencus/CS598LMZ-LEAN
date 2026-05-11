import Mathlib

theorem schurTriangularization
    (n : ℕ) (A : Matrix (Fin n) (Fin n) ℂ) :
    ∃ Q T : Matrix (Fin n) (Fin n) ℂ,
      Matrix.IsUpperTriangular T ∧
      A = Q ⬝ T ⬝ Qᴴ ∧
      Q ⬝ Qᴴ = 1 ∧
      Qᴴ ⬝ Q = 1 ∧
      ∀ i : Fin n, Polynomial.IsRoot (Matrix.charpoly A) (T i i) := by
  sorry