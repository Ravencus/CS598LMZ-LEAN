import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  have hpow (k : ℕ) : (A * B) ^ (k+1) = A * (B * A) ^ k * B := by
    induction' k with k ih
    · simp
    · rw [pow_succ' (A * B) (k+1), ih]
      calc
        (A * B) * (A * (B * A) ^ k * B) = ((A * B) * (A * (B * A) ^ k)) * B := by rw [← mul_assoc]
        _ = (((A * B) * A) * (B * A) ^ k) * B := by rw [← mul_assoc]
        _ = (A * (B * A) * (B * A) ^ k) * B := by rw [mul_assoc A B A]
        _ = A * ((B * A) * (B * A) ^ k) * B := by rw [mul_assoc A (B * A) ((B * A) ^ k)]
        _ = A * (B * A) ^ (k+1) * B := by rw [pow_succ' (B * A) k]
  sorry