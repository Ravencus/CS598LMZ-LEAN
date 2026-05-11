import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  have key : ∀ (X' Y' : Matrix n n ℂ) (p : ℂ[X]),
      Y' * (aeval (X' * Y') p) = (aeval (Y' * X') p) * Y' := by
    intro X' Y' p
    induction p using Polynomial.induction_on' with
    | add p q hp hq => simp [hp, hq, mul_add, add_mul]
    | monomial k c =>
      have hpow : Y' * (X' * Y') ^ k = (Y' * X') ^ k * Y' := by
        induction k with
        | zero => simp
        | succ k ih =>
          rw [pow_succ, pow_succ, ← mul_assoc, ih, mul_assoc, mul_assoc, mul_assoc]
      simp only [aeval_monomial]
      rw [← mul_assoc, ← Algebra.commutes, mul_assoc, hpow, mul_assoc]
  refine ⟨?_, ?_⟩
  · rw [minpoly.dvd_iff]
    rw [map_mul, aeval_X]
    have h1 : B * aeval (A * B) (minpoly ℂ (B * A)) =
              aeval (B * A) (minpoly ℂ (B * A)) * B := key A B _
    rw [minpoly.aeval, zero_mul] at h1
    calc (A * B) * aeval (A * B) (minpoly ℂ (B * A))
        = A * (B * aeval (A * B) (minpoly ℂ (B * A))) := by rw [mul_assoc]
      _ = A * 0 := by rw [h1]
      _ = 0 := mul_zero _
  · rw [minpoly.dvd_iff]
    rw [map_mul, aeval_X]
    have h1 : A * aeval (B * A) (minpoly ℂ (A * B)) =
              aeval (A * B) (minpoly ℂ (A * B)) * A := key B A _
    rw [minpoly.aeval, zero_mul] at h1
    calc (B * A) * aeval (B * A) (minpoly ℂ (A * B))
        = B * (A * aeval (B * A) (minpoly ℂ (A * B))) := by rw [mul_assoc]
      _ = B * 0 := by rw [h1]
      _ = 0 := mul_zero _