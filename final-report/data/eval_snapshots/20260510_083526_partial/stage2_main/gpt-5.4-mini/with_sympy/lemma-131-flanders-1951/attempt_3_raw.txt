import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  have hswap : ∀ (A B : Matrix n n ℂ) (p : ℂ[X]),
      B * Polynomial.aeval (A * B) p = Polynomial.aeval (B * A) p * B := by
    intro A B p
    induction p using Polynomial.induction_on with
    | C c =>
        ext i j
        simp [Polynomial.aeval_C, Matrix.mul_apply, mul_comm, mul_left_comm, mul_assoc]
    | add p q hp hq =>
        calc
          B * Polynomial.aeval (A * B) (p + q)
              = B * (Polynomial.aeval (A * B) p + Polynomial.aeval (A * B) q) := by simp
          _ = B * Polynomial.aeval (A * B) p + B * Polynomial.aeval (A * B) q := by rw [mul_add]
          _ = Polynomial.aeval (B * A) p * B + Polynomial.aeval (B * A) q * B := by rw [hp, hq]
          _ = (Polynomial.aeval (B * A) p + Polynomial.aeval (B * A) q) * B := by rw [add_mul]
          _ = Polynomial.aeval (B * A) (p + q) * B := by simp
    | monomial n c =>
        have hpow : B * (A * B) ^ n = (B * A) ^ n * B := by
          induction n with
          | zero =>
              simp
          | succ n ih =>
              calc
                B * (A * B) ^ (n + 1)
                    = B * ((A * B) ^ n * (A * B)) := by rw [pow_succ]
                _ = (B * (A * B) ^ n) * (A * B) := by rw [mul_assoc]
                _ = ((B * A) ^ n * B) * (A * B) := by rw [ih]
                _ = (B * A) ^ n * (B * (A * B)) := by rw [mul_assoc]
                _ = (B * A) ^ n * ((B * A) * B) := by rw [mul_assoc]
                _ = ((B * A) ^ n * (B * A)) * B := by rw [← mul_assoc]
                _ = (B * A) ^ (n + 1) * B := by rw [← pow_succ]
        calc
          B * Polynomial.aeval (A * B) (monomial n c)
              = B * (c • (A * B) ^ n) := by simp
          _ = c • (B * (A * B) ^ n) := by rw [mul_smul_comm]
          _ = c • ((B * A) ^ n * B) := by rw [hpow]
          _ = (c • (B * A) ^ n) * B := by rw [← smul_mul_assoc]
          _ = Polynomial.aeval (B * A) (monomial n c) * B := by simp
  constructor
  · rw [minpoly.dvd_iff]
    have hmin : Polynomial.aeval (B * A) (minpoly ℂ (B * A)) = 0 := by
      simpa using (minpoly.aeval (B * A))
    have hswapBA : B * Polynomial.aeval (A * B) (minpoly ℂ (B * A)) =
        Polynomial.aeval (B * A) (minpoly ℂ (B * A)) * B := by
      exact hswap A B (minpoly ℂ (B * A))
    have hzero : B * Polynomial.aeval (A * B) (minpoly ℂ (B * A)) = 0 := by
      rw [hswapBA, hmin]
      simp
    have hdiv : Polynomial.aeval (A * B) (X * minpoly ℂ (B * A)) = 0 := by
      calc
        Polynomial.aeval (A * B) (X * minpoly ℂ (B * A))
            = Polynomial.aeval (A * B) X * Polynomial.aeval (A * B) (minpoly ℂ (B * A)) := by
              rw [map_mul]
        _ = (A * B) * Polynomial.aeval (A * B) (minpoly ℂ (B * A)) := by simp
        _ = A * (B * Polynomial.aeval (A * B) (minpoly ℂ (B * A))) := by rw [mul_assoc]
        _ = 0 := by rw [hzero]; simp
    exact hdiv
  · rw [minpoly.dvd_iff]
    have hmin : Polynomial.aeval (A * B) (minpoly ℂ (A * B)) = 0 := by
      simpa using (minpoly.aeval (A * B))
    have hswapAB : A * Polynomial.aeval (B * A) (minpoly ℂ (A * B)) =
        Polynomial.aeval (A * B) (minpoly ℂ (A * B)) * A := by
      simpa using (hswap B A (minpoly ℂ (A * B)))
    have hzero : A * Polynomial.aeval (B * A) (minpoly ℂ (A * B)) = 0 := by
      rw [hswapAB, hmin]
      simp
    have hdiv : Polynomial.aeval (B * A) (X * minpoly ℂ (A * B)) = 0 := by
      calc
        Polynomial.aeval (B * A) (X * minpoly ℂ (A * B))
            = Polynomial.aeval (B * A) X * Polynomial.aeval (B * A) (minpoly ℂ (A * B)) := by
              rw [map_mul]
        _ = (B * A) * Polynomial.aeval (B * A) (minpoly ℂ (A * B)) := by simp
        _ = B * (A * Polynomial.aeval (B * A) (minpoly ℂ (A * B))) := by rw [mul_assoc]
        _ = 0 := by rw [hzero]; simp
    exact hdiv