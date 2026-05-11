import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  constructor
  · rw [minpoly.dvd_iff]
    have hswap : ∀ p : ℂ[X], A * Polynomial.aeval (B * A) p = Polynomial.aeval (A * B) p * A := by
      intro p
      refine Polynomial.induction_on p ?_ ?_ ?_ ?_ ?_
      · simp
      · intro c
        simp
      · simp
      · intro p q hp hq
        calc
          A * Polynomial.aeval (B * A) (p + q)
              = A * (Polynomial.aeval (B * A) p + Polynomial.aeval (B * A) q) := by simp
          _ = A * Polynomial.aeval (B * A) p + A * Polynomial.aeval (B * A) q := by rw [mul_add]
          _ = Polynomial.aeval (A * B) p * A + Polynomial.aeval (A * B) q * A := by rw [hp, hq]
          _ = (Polynomial.aeval (A * B) p + Polynomial.aeval (A * B) q) * A := by rw [add_mul]
          _ = Polynomial.aeval (A * B) (p + q) * A := by simp
      · intro p q hp hq
        calc
          A * Polynomial.aeval (B * A) (p * q)
              = A * (Polynomial.aeval (B * A) p * Polynomial.aeval (B * A) q) := by simp
          _ = (A * Polynomial.aeval (B * A) p) * Polynomial.aeval (B * A) q := by rw [mul_assoc]
          _ = (Polynomial.aeval (A * B) p * A) * Polynomial.aeval (B * A) q := by rw [hp]
          _ = Polynomial.aeval (A * B) p * (A * Polynomial.aeval (B * A) q) := by rw [mul_assoc]
          _ = Polynomial.aeval (A * B) p * (Polynomial.aeval (A * B) q * A) := by rw [hq]
          _ = (Polynomial.aeval (A * B) p * Polynomial.aeval (A * B) q) * A := by rw [mul_assoc]
          _ = Polynomial.aeval (A * B) (p * q) * A := by simp
    have hmin : Polynomial.aeval (B * A) (minpoly ℂ (B * A)) = 0 := by
      simpa using (minpoly.aeval (B * A))
    have hzero : Polynomial.aeval (A * B) (minpoly ℂ (B * A)) * A = 0 := by
      rw [← hswap, hmin]
      simp
    have hdiv : Polynomial.aeval (A * B) (X * minpoly ℂ (B * A)) = 0 := by
      calc
        Polynomial.aeval (A * B) (X * minpoly ℂ (B * A))
            = Polynomial.aeval (A * B) (minpoly ℂ (B * A) * X) := by rw [mul_comm]
        _ = Polynomial.aeval (A * B) (minpoly ℂ (B * A)) * Polynomial.aeval (A * B) X := by rw [map_mul]
        _ = Polynomial.aeval (A * B) (minpoly ℂ (B * A)) * (A * B) := by simp
        _ = (Polynomial.aeval (A * B) (minpoly ℂ (B * A)) * A) * B := by rw [mul_assoc]
        _ = 0 := by rw [hzero]; simp
    exact hdiv
  · rw [minpoly.dvd_iff]
    have hswap : ∀ p : ℂ[X], B * Polynomial.aeval (A * B) p = Polynomial.aeval (B * A) p * B := by
      intro p
      refine Polynomial.induction_on p ?_ ?_ ?_ ?_ ?_
      · simp
      · intro c
        simp
      · simp
      · intro p q hp hq
        calc
          B * Polynomial.aeval (A * B) (p + q)
              = B * (Polynomial.aeval (A * B) p + Polynomial.aeval (A * B) q) := by simp
          _ = B * Polynomial.aeval (A * B) p + B * Polynomial.aeval (A * B) q := by rw [mul_add]
          _ = Polynomial.aeval (B * A) p * B + Polynomial.aeval (B * A) q * B := by rw [hp, hq]
          _ = (Polynomial.aeval (B * A) p + Polynomial.aeval (B * A) q) * B := by rw [add_mul]
          _ = Polynomial.aeval (B * A) (p + q) * B := by simp
      · intro p q hp hq
        calc
          B * Polynomial.aeval (A * B) (p * q)
              = B * (Polynomial.aeval (A * B) p * Polynomial.aeval (A * B) q) := by simp
          _ = (B * Polynomial.aeval (A * B) p) * Polynomial.aeval (A * B) q := by rw [mul_assoc]
          _ = (Polynomial.aeval (B * A) p * B) * Polynomial.aeval (A * B) q := by rw [hp]
          _ = Polynomial.aeval (B * A) p * (B * Polynomial.aeval (A * B) q) := by rw [mul_assoc]
          _ = Polynomial.aeval (B * A) p * (Polynomial.aeval (B * A) q * B) := by rw [hq]
          _ = (Polynomial.aeval (B * A) p * Polynomial.aeval (B * A) q) * B := by rw [mul_assoc]
          _ = Polynomial.aeval (B * A) (p * q) * B := by simp
    have hmin : Polynomial.aeval (A * B) (minpoly ℂ (A * B)) = 0 := by
      simpa using (minpoly.aeval (A * B))
    have hzero : Polynomial.aeval (B * A) (minpoly ℂ (A * B)) * B = 0 := by
      rw [← hswap, hmin]
      simp
    have hdiv : Polynomial.aeval (B * A) (X * minpoly ℂ (A * B)) = 0 := by
      calc
        Polynomial.aeval (B * A) (X * minpoly ℂ (A * B))
            = Polynomial.aeval (B * A) (minpoly ℂ (A * B) * X) := by rw [mul_comm]
        _ = Polynomial.aeval (B * A) (minpoly ℂ (A * B)) * Polynomial.aeval (B * A) X := by rw [map_mul]
        _ = Polynomial.aeval (B * A) (minpoly ℂ (A * B)) * (B * A) := by simp
        _ = (Polynomial.aeval (B * A) (minpoly ℂ (A * B)) * B) * A := by rw [← mul_assoc]
        _ = 0 := by rw [hzero]; simp
    exact hdiv