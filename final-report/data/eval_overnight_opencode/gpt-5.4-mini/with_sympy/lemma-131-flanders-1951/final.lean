import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  constructor
  · apply minpoly.dvd
    have hcomm : ∀ p : Polynomial ℂ, A * aeval (B * A) p = aeval (A * B) p * A := by
      intro p
      induction p using Polynomial.induction_on with
      | C c =>
          change A * (c • (1 : Matrix n n ℂ)) = (c • (1 : Matrix n n ℂ)) * A
          simp [mul_smul, smul_mul_assoc]
      | monomial m c =>
          induction m with
          | zero =>
              change A * (c • (1 : Matrix n n ℂ)) = (c • (1 : Matrix n n ℂ)) * A
              simp [mul_smul, smul_mul_assoc]
          | succ m ih =>
              simp [pow_succ, ih, Matrix.mul_assoc, mul_smul, smul_mul_assoc]
      | add p q hp hq =>
          simp [hp, hq, add_mul, mul_add, Matrix.mul_assoc]
    calc
      aeval (B * A) (X * minpoly ℂ (A * B))
          = (B * A) * aeval (B * A) (minpoly ℂ (A * B)) := by simp
      _ = B * (A * aeval (B * A) (minpoly ℂ (A * B))) := by simp [Matrix.mul_assoc]
      _ = B * (aeval (A * B) (minpoly ℂ (A * B)) * A) := by rw [hcomm]
      _ = 0 := by simp [aeval_minpoly, Matrix.mul_assoc]
  · apply minpoly.dvd
    have hcomm : ∀ p : Polynomial ℂ, B * aeval (A * B) p = aeval (B * A) p * B := by
      intro p
      induction p using Polynomial.induction_on with
      | C c =>
          change B * (c • (1 : Matrix n n ℂ)) = (c • (1 : Matrix n n ℂ)) * B
          simp [mul_smul, smul_mul_assoc]
      | monomial m c =>
          induction m with
          | zero =>
              change B * (c • (1 : Matrix n n ℂ)) = (c • (1 : Matrix n n ℂ)) * B
              simp [mul_smul, smul_mul_assoc]
          | succ m ih =>
              simp [pow_succ, ih, Matrix.mul_assoc, mul_smul, smul_mul_assoc]
      | add p q hp hq =>
          simp [hp, hq, add_mul, mul_add, Matrix.mul_assoc]
    calc
      aeval (A * B) (X * minpoly ℂ (B * A))
          = (A * B) * aeval (A * B) (minpoly ℂ (B * A)) := by simp
      _ = A * (B * aeval (A * B) (minpoly ℂ (B * A))) := by simp [Matrix.mul_assoc]
      _ = A * (aeval (B * A) (minpoly ℂ (B * A)) * B) := by rw [hcomm]
      _ = 0 := by simp [aeval_minpoly, Matrix.mul_assoc]