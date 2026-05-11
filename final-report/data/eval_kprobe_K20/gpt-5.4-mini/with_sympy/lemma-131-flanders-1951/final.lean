import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  constructor
  · apply minpoly.dvd ℂ (A * B)
    have hcomm : ∀ p : Polynomial ℂ, B * aeval (A * B) p = aeval (B * A) p * B := by
      intro p
      induction p using Polynomial.induction_on with
      | C c =>
          simp [Polynomial.aeval_C, Algebra.algebraMap_eq_smul_one]
      | add p q hp hq =>
          simp [hp, hq, add_mul, mul_add]
      | monomial n c =>
          induction n with
          | zero =>
              simp [Polynomial.aeval_C, Algebra.algebraMap_eq_smul_one]
          | succ n ih =>
              simp [Polynomial.aeval_monomial, pow_succ, ih, Matrix.mul_assoc, mul_smul, smul_mul_assoc]
    calc
      aeval (A * B) (X * minpoly ℂ (B * A))
          = (aeval (A * B) X) * (aeval (A * B) (minpoly ℂ (B * A))) := by
              rw [aeval_mul]
      _ = (A * B) * (aeval (A * B) (minpoly ℂ (B * A))) := by simp
      _ = A * (B * aeval (A * B) (minpoly ℂ (B * A))) := by simp [Matrix.mul_assoc]
      _ = A * ((aeval (B * A) (minpoly ℂ (B * A))) * B) := by rw [hcomm]
      _ = A * (0 * B) := by rw [minpoly.aeval]
      _ = 0 := by simp
  · apply minpoly.dvd ℂ (B * A)
    have hcomm : ∀ p : Polynomial ℂ, A * aeval (B * A) p = aeval (A * B) p * A := by
      intro p
      induction p using Polynomial.induction_on with
      | C c =>
          simp [Polynomial.aeval_C, Algebra.algebraMap_eq_smul_one]
      | add p q hp hq =>
          simp [hp, hq, add_mul, mul_add]
      | monomial n c =>
          induction n with
          | zero =>
              simp [Polynomial.aeval_C, Algebra.algebraMap_eq_smul_one]
          | succ n ih =>
              simp [Polynomial.aeval_monomial, pow_succ, ih, Matrix.mul_assoc, mul_smul, smul_mul_assoc]
    calc
      aeval (B * A) (X * minpoly ℂ (A * B))
          = (aeval (B * A) X) * (aeval (B * A) (minpoly ℂ (A * B))) := by
              rw [aeval_mul]
      _ = (B * A) * (aeval (B * A) (minpoly ℂ (A * B))) := by simp
      _ = B * (A * aeval (B * A) (minpoly ℂ (A * B))) := by simp [Matrix.mul_assoc]
      _ = B * ((aeval (A * B) (minpoly ℂ (A * B))) * A) := by rw [hcomm]
      _ = B * (0 * A) := by rw [minpoly.aeval]
      _ = 0 := by simp