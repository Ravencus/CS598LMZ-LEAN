import Mathlib

open Polynomial

-- Helper: A * (B*A)^k = (A*B)^k * A
private lemma aux_pow {n : Type*} [Fintype n] [DecidableEq n] (A B : Matrix n n ℂ) :
    ∀ k : ℕ, A * (B * A)^k = (A * B)^k * A := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
    rw [pow_succ, pow_succ, ← mul_assoc, ih, mul_assoc, mul_assoc, mul_assoc]

-- Helper: A * aeval (B*A) p = aeval (A*B) p * A
private lemma aux_aeval {n : Type*} [Fintype n] [DecidableEq n] (A B : Matrix n n ℂ) (p : ℂ[X]) :
    A * (Polynomial.aeval (B * A) p) = (Polynomial.aeval (A * B) p) * A := by
  induction p using Polynomial.induction_on' with
  | add p q hp hq =>
    simp only [map_add]
    rw [mul_add, add_mul, hp, hq]
  | monomial k c =>
    simp only [aeval_monomial]
    have h := aux_pow A B k
    have hcomm1 : A * (algebraMap ℂ (Matrix n n ℂ)) c = (algebraMap ℂ (Matrix n n ℂ)) c * A :=
      (Algebra.commutes c A).symm
    rw [← mul_assoc, hcomm1, mul_assoc, h, mul_assoc]

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  refine ⟨?_, ?_⟩
  · apply minpoly.dvd
    rw [map_mul, aeval_X]
    set q := Polynomial.aeval (A * B) (minpoly ℂ (B * A)) with hq_def
    have hqA : q * A = 0 := by
      have h := aux_aeval A B (minpoly ℂ (B * A))
      rw [minpoly.aeval] at h
      simpa [q] using h.symm
    have hcomm : (A * B) * q = q * (A * B) := by
      have e1 : (A * B) * q = Polynomial.aeval (A*B) (X * minpoly ℂ (B*A)) := by
        rw [map_mul, aeval_X]
      have e2 : q * (A * B) = Polynomial.aeval (A*B) (minpoly ℂ (B*A) * X) := by
        rw [map_mul, aeval_X]
      rw [e1, e2, mul_comm]
    rw [hcomm, ← mul_assoc, hqA, zero_mul]
  · apply minpoly.dvd
    rw [map_mul, aeval_X]
    set q := Polynomial.aeval (B * A) (minpoly ℂ (A * B)) with hq_def
    have hqB : q * B = 0 := by
      have h := aux_aeval B A (minpoly ℂ (A * B))
      rw [minpoly.aeval] at h
      simpa [q] using h.symm
    have hcomm : (B * A) * q = q * (B * A) := by
      have e1 : (B * A) * q = Polynomial.aeval (B*A) (X * minpoly ℂ (A*B)) := by
        rw [map_mul, aeval_X]
      have e2 : q * (B * A) = Polynomial.aeval (B*A) (minpoly ℂ (A*B) * X) := by
        rw [map_mul, aeval_X]
      rw [e1, e2, mul_comm]
    rw [hcomm, ← mul_assoc, hqB, zero_mul]