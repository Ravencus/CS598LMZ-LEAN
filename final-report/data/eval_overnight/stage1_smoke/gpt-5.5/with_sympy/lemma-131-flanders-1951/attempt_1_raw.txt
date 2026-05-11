import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  constructor
  · apply minpoly.dvd
    calc
      aeval (A * B) (X * minpoly ℂ (B * A))
          = (A * B) * aeval (A * B) (minpoly ℂ (B * A)) := by
              simp
      _ = A * aeval (B * A) (minpoly ℂ (B * A)) * B := by
              rw [show (A * B) * aeval (A * B) (minpoly ℂ (B * A))
                    = A * (B * aeval (A * B) (minpoly ℂ (B * A))) by
                    simp [Matrix.mul_assoc]]
              congr 1
              induction minpoly ℂ (B * A) using Polynomial.induction_on' with
              | h_add p q hp hq =>
                  simp [map_add, Matrix.mul_add, Matrix.add_mul, hp, hq]
              | h_monomial m c =>
                  induction m with
                  | zero =>
                      simp
                  | succ m ih =>
                      simp only [pow_succ', map_mul, map_pow, map_C, aeval_X]
                      rw [Matrix.mul_assoc, ih]
                      simp [Matrix.mul_assoc]
      _ = 0 := by
              simp [minpoly.aeval]
  · apply minpoly.dvd
    calc
      aeval (B * A) (X * minpoly ℂ (A * B))
          = (B * A) * aeval (B * A) (minpoly ℂ (A * B)) := by
              simp
      _ = B * aeval (A * B) (minpoly ℂ (A * B)) * A := by
              rw [show (B * A) * aeval (B * A) (minpoly ℂ (A * B))
                    = B * (A * aeval (B * A) (minpoly ℂ (A * B))) by
                    simp [Matrix.mul_assoc]]
              congr 1
              induction minpoly ℂ (A * B) using Polynomial.induction_on' with
              | h_add p q hp hq =>
                  simp [map_add, Matrix.mul_add, Matrix.add_mul, hp, hq]
              | h_monomial m c =>
                  induction m with
                  | zero =>
                      simp
                  | succ m ih =>
                      simp only [pow_succ', map_mul, map_pow, map_C, aeval_X]
                      rw [Matrix.mul_assoc, ih]
                      simp [Matrix.mul_assoc]
      _ = 0 := by
              simp [minpoly.aeval]