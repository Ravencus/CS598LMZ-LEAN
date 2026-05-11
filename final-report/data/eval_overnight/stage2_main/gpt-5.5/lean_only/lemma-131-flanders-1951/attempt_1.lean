import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  constructor
  · rw [minpoly.dvd]
    rw [map_mul, aeval_X]
    change (A * B) * aeval (A * B) (minpoly ℂ (B * A)) = 0
    rw [← Matrix.mul_assoc]
    conv_lhs =>
      congr
      skip
      rw [← Matrix.one_mul B]
      rw [← minpoly.aeval ℂ (B * A)]
    rw [← Matrix.mul_assoc]
    congr 1
    induction (minpoly ℂ (B * A)) using Polynomial.induction_on' with
    | h_add p q hp hq =>
        simp [map_add, Matrix.mul_add, Matrix.add_mul, hp, hq]
    | h_monomial m c =>
        simp only [map_mul, map_pow, map_C, aeval_X]
        rw [← Matrix.mul_assoc]
        congr 1
        induction m with
        | zero =>
            simp
        | succ m ih =>
            simp only [pow_succ]
            rw [Matrix.mul_assoc A B ((A * B) ^ m)]
            rw [ih]
            simp only [Matrix.mul_assoc]
  · rw [minpoly.dvd]
    rw [map_mul, aeval_X]
    change (B * A) * aeval (B * A) (minpoly ℂ (A * B)) = 0
    rw [← Matrix.mul_assoc]
    conv_lhs =>
      congr
      skip
      rw [← Matrix.one_mul A]
      rw [← minpoly.aeval ℂ (A * B)]
    rw [← Matrix.mul_assoc]
    congr 1
    induction (minpoly ℂ (A * B)) using Polynomial.induction_on' with
    | h_add p q hp hq =>
        simp [map_add, Matrix.mul_add, Matrix.add_mul, hp, hq]
    | h_monomial m c =>
        simp only [map_mul, map_pow, map_C, aeval_X]
        rw [← Matrix.mul_assoc]
        congr 1
        induction m with
        | zero =>
            simp
        | succ m ih =>
            simp only [pow_succ]
            rw [Matrix.mul_assoc B A ((B * A) ^ m)]
            rw [ih]
            simp only [Matrix.mul_assoc]