import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  constructor
  · apply minpoly.dvd
    rw [Polynomial.aeval_mul, Polynomial.aeval_X]
    calc
      (A * B) * aeval (A * B) (minpoly ℂ (B * A))
          = A * (B * aeval (A * B) (minpoly ℂ (B * A))) := by
              simp only [mul_assoc]
      _ = A * (aeval (B * A) (minpoly ℂ (B * A)) * B) := by
              congr 1
              induction minpoly ℂ (B * A) using Polynomial.induction_on' with
              | h_add p q hp hq =>
                  simp only [map_add, add_mul, mul_add, hp, hq]
              | h_monomial c k =>
                  simp only [Polynomial.aeval_monomial, Algebra.smul_def]
                  induction k with
                  | zero =>
                      simp
                  | succ k ih =>
                      simp only [pow_succ]
                      calc
                        B * ((A * B) ^ k * (A * B) * (c • 1))
                            = (B * (A * B) ^ k) * (A * B) * (c • 1) := by
                                simp only [mul_assoc]
                        _ = ((B * A) ^ k * B) * (A * B) * (c • 1) := by
                                rw [ih]
                        _ = (B * A) ^ k * (B * A) * B * (c • 1) := by
                                simp only [mul_assoc]
                        _ = ((B * A) ^ k * (B * A) * (c • 1)) * B := by
                                simp only [mul_assoc]
      _ = 0 := by
              rw [minpoly.aeval]
              simp
  · apply minpoly.dvd
    rw [Polynomial.aeval_mul, Polynomial.aeval_X]
    calc
      (B * A) * aeval (B * A) (minpoly ℂ (A * B))
          = B * (A * aeval (B * A) (minpoly ℂ (A * B))) := by
              simp only [mul_assoc]
      _ = B * (aeval (A * B) (minpoly ℂ (A * B)) * A) := by
              congr 1
              induction minpoly ℂ (A * B) using Polynomial.induction_on' with
              | h_add p q hp hq =>
                  simp only [map_add, add_mul, mul_add, hp, hq]
              | h_monomial c k =>
                  simp only [Polynomial.aeval_monomial, Algebra.smul_def]
                  induction k with
                  | zero =>
                      simp
                  | succ k ih =>
                      simp only [pow_succ]
                      calc
                        A * ((B * A) ^ k * (B * A) * (c • 1))
                            = (A * (B * A) ^ k) * (B * A) * (c • 1) := by
                                simp only [mul_assoc]
                        _ = ((A * B) ^ k * A) * (B * A) * (c • 1) := by
                                rw [ih]
                        _ = (A * B) ^ k * (A * B) * A * (c • 1) := by
                                simp only [mul_assoc]
                        _ = ((A * B) ^ k * (A * B) * (c • 1)) * A := by
                                simp only [mul_assoc]
      _ = 0 := by
              rw [minpoly.aeval]
              simp