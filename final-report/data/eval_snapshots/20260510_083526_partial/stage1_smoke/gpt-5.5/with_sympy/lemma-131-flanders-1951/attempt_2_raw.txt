import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  have hBA :
      ∀ p : ℂ[X], B * aeval (A * B) p = aeval (B * A) p * B := by
    intro p
    induction p using Polynomial.induction_on' with
    | add p q hp hq =>
        simp [map_add, Matrix.mul_add, Matrix.add_mul, hp, hq]
    | monomial m c =>
        have hpow : B * (A * B) ^ m = (B * A) ^ m * B := by
          induction m with
          | zero =>
              simp
          | succ m ih =>
              calc
                B * (A * B) ^ (m + 1)
                    = (B * (A * B) ^ m) * (A * B) := by
                        simp [pow_succ, Matrix.mul_assoc]
                _ = ((B * A) ^ m * B) * (A * B) := by
                        rw [ih]
                _ = (B * A) ^ (m + 1) * B := by
                        simp [pow_succ, Matrix.mul_assoc]
        simp [hpow, Matrix.mul_assoc]
  have hAB :
      ∀ p : ℂ[X], A * aeval (B * A) p = aeval (A * B) p * A := by
    intro p
    induction p using Polynomial.induction_on' with
    | add p q hp hq =>
        simp [map_add, Matrix.mul_add, Matrix.add_mul, hp, hq]
    | monomial m c =>
        have hpow : A * (B * A) ^ m = (A * B) ^ m * A := by
          induction m with
          | zero =>
              simp
          | succ m ih =>
              calc
                A * (B * A) ^ (m + 1)
                    = (A * (B * A) ^ m) * (B * A) := by
                        simp [pow_succ, Matrix.mul_assoc]
                _ = ((A * B) ^ m * A) * (B * A) := by
                        rw [ih]
                _ = (A * B) ^ (m + 1) * A := by
                        simp [pow_succ, Matrix.mul_assoc]
        simp [hpow, Matrix.mul_assoc]
  constructor
  · apply minpoly.dvd
    calc
      aeval (A * B) (X * minpoly ℂ (B * A))
          = (A * B) * aeval (A * B) (minpoly ℂ (B * A)) := by
              simp
      _ = A * aeval (B * A) (minpoly ℂ (B * A)) * B := by
              rw [← Matrix.mul_assoc, hBA]
              simp [Matrix.mul_assoc]
      _ = 0 := by
              simp [minpoly.aeval]
  · apply minpoly.dvd
    calc
      aeval (B * A) (X * minpoly ℂ (A * B))
          = (B * A) * aeval (B * A) (minpoly ℂ (A * B)) := by
              simp
      _ = B * aeval (A * B) (minpoly ℂ (A * B)) * A := by
              rw [← Matrix.mul_assoc, hAB]
              simp [Matrix.mul_assoc]
      _ = 0 := by
              simp [minpoly.aeval]