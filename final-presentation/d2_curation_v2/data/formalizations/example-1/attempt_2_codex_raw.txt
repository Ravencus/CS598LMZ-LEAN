import Mathlib

open Matrix Polynomial

theorem matrix_products_charpoly_minpoly_example :
    let P : Matrix (Fin 2) (Fin 2) ℚ := !![0, 1; 0, 0];
    let Q : Matrix (Fin 2) (Fin 2) ℚ := !![0, 0; 0, 1];
    P ⬝ Q = !![0, 1; 0, 0] ∧
      Q ⬝ P = !![0, 0; 0, 0] ∧
      Matrix.charpoly (P ⬝ Q) = (X : Polynomial ℚ) ^ 2 ∧
      Matrix.charpoly (Q ⬝ P) = (X : Polynomial ℚ) ^ 2 ∧
      minpoly ℚ (P ⬝ Q) = (X : Polynomial ℚ) ^ 2 ∧
      minpoly ℚ (Q ⬝ P) = (X : Polynomial ℚ) := by
  sorry