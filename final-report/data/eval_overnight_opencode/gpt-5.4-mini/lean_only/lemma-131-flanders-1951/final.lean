import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A B : Matrix ι ι ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  constructor
  · have hpow : ∀ m : ℕ, A * (B * A) ^ m = (A * B) ^ m * A := by
      intro m
      induction m with
      | zero => simp
      | succ m ih =>
          have hBAA : A * (B * A) = A * B * A := by rw [mul_assoc]
          calc
            A * (B * A) ^ m.succ = A * ((B * A) ^ m * (B * A)) := by rw [pow_succ]
            _ = (A * (B * A) ^ m) * (B * A) := by rw [mul_assoc]
            _ = ((A * B) ^ m * A) * (B * A) := by rw [ih]
            _ = (A * B) ^ m * (A * (B * A)) := by rw [mul_assoc]
            _ = (A * B) ^ m * (A * B * A) := by simpa [hBAA, mul_assoc]
            _ = ((A * B) ^ m * (A * B)) * A := by rw [mul_assoc]
            _ = (A * B) ^ m.succ * A := by rw [pow_succ]
    have hscalar : ∀ (a : ℂ), ∀ M : Matrix ι ι ℂ,
        M * (algebraMap ℂ (Matrix ι ι ℂ) a) = algebraMap ℂ (Matrix ι ι ℂ) a * M := by
      intro a M
      simpa using (Algebra.commutes (R := ℂ) (A := Matrix ι ι ℂ) a M).symm
    have hcomm : ∀ q : ℂ[X], A * aeval (B * A) q = aeval (A * B) q * A := by
      intro q
      induction q using Polynomial.induction_on' with
      | add p q hp hq =>
          simp [hp, hq, mul_add, add_mul]
      | monomial n a =>
          calc
            A * aeval (B * A) (Polynomial.monomial n a)
                = A * ((algebraMap ℂ (Matrix ι ι ℂ)) a * (B * A) ^ n) := by
                    rw [Polynomial.aeval_monomial]
            _ = (A * (algebraMap ℂ (Matrix ι ι ℂ)) a) * (B * A) ^ n := by rw [mul_assoc]
            _ = ((algebraMap ℂ (Matrix ι ι ℂ)) a * A) * (B * A) ^ n := by rw [hscalar]
            _ = (algebraMap ℂ (Matrix ι ι ℂ)) a * (A * (B * A) ^ n) := by rw [← mul_assoc]
            _ = (algebraMap ℂ (Matrix ι ι ℂ)) a * ((A * B) ^ n * A) := by rw [hpow]
            _ = ((algebraMap ℂ (Matrix ι ι ℂ)) a * (A * B) ^ n) * A := by rw [mul_assoc]
            _ = aeval (A * B) (Polynomial.monomial n a) * A := by rw [Polynomial.aeval_monomial]
    have hq0 : aeval (B * A) (minpoly ℂ (B * A)) = 0 := minpoly.aeval ℂ (B * A)
    have h1 : aeval (A * B) (minpoly ℂ (B * A)) * A = 0 := by
      simpa [hq0] using (hcomm (minpoly ℂ (B * A))).symm
    have h2 : aeval (A * B) (minpoly ℂ (B * A)) * (A * B) = 0 := by
      calc
        aeval (A * B) (minpoly ℂ (B * A)) * (A * B)
            = (aeval (A * B) (minpoly ℂ (B * A)) * A) * B := by rw [mul_assoc]
        _ = 0 := by rw [h1, zero_mul]
    have hdiv : minpoly ℂ (A * B) ∣ minpoly ℂ (B * A) * X := by
      apply minpoly.dvd ℂ (A * B)
      rw [aeval_mul, aeval_X, h2]
    simpa [mul_comm] using hdiv
  · have hpow : ∀ m : ℕ, B * (A * B) ^ m = (B * A) ^ m * B := by
      intro m
      induction m with
      | zero => simp
      | succ m ih =>
          have hBAB : B * (A * B) = B * A * B := by rw [mul_assoc]
          calc
            B * (A * B) ^ m.succ = B * ((A * B) ^ m * (A * B)) := by rw [pow_succ]
            _ = (B * (A * B) ^ m) * (A * B) := by rw [mul_assoc]
            _ = ((B * A) ^ m * B) * (A * B) := by rw [ih]
            _ = (B * A) ^ m * (B * (A * B)) := by rw [mul_assoc]
            _ = (B * A) ^ m * (B * A * B) := by simpa [hBAB, mul_assoc]
            _ = ((B * A) ^ m * (B * A)) * B := by rw [mul_assoc]
            _ = (B * A) ^ m.succ * B := by rw [pow_succ]
    have hscalar : ∀ (a : ℂ), ∀ M : Matrix ι ι ℂ,
        M * (algebraMap ℂ (Matrix ι ι ℂ) a) = algebraMap ℂ (Matrix ι ι ℂ) a * M := by
      intro a M
      simpa using (Algebra.commutes (R := ℂ) (A := Matrix ι ι ℂ) a M).symm
    have hcomm : ∀ q : ℂ[X], B * aeval (A * B) q = aeval (B * A) q * B := by
      intro q
      induction q using Polynomial.induction_on' with
      | add p q hp hq =>
          simp [hp, hq, mul_add, add_mul]
      | monomial n a =>
          calc
            B * aeval (A * B) (Polynomial.monomial n a)
                = B * ((algebraMap ℂ (Matrix ι ι ℂ)) a * (A * B) ^ n) := by
                    rw [Polynomial.aeval_monomial]
            _ = (B * (algebraMap ℂ (Matrix ι ι ℂ)) a) * (A * B) ^ n := by rw [mul_assoc]
            _ = ((algebraMap ℂ (Matrix ι ι ℂ)) a * B) * (A * B) ^ n := by rw [hscalar]
            _ = (algebraMap ℂ (Matrix ι ι ℂ)) a * (B * (A * B) ^ n) := by rw [← mul_assoc]
            _ = (algebraMap ℂ (Matrix ι ι ℂ)) a * ((B * A) ^ n * B) := by rw [hpow]
            _ = ((algebraMap ℂ (Matrix ι ι ℂ)) a * (B * A) ^ n) * B := by rw [mul_assoc]
            _ = aeval (B * A) (Polynomial.monomial n a) * B := by rw [Polynomial.aeval_monomial]
    have hq0 : aeval (A * B) (minpoly ℂ (A * B)) = 0 := minpoly.aeval ℂ (A * B)
    have h1 : aeval (B * A) (minpoly ℂ (A * B)) * B = 0 := by
      simpa [hq0] using (hcomm (minpoly ℂ (A * B))).symm
    have h2 : aeval (B * A) (minpoly ℂ (A * B)) * (B * A) = 0 := by
      calc
        aeval (B * A) (minpoly ℂ (A * B)) * (B * A)
            = (aeval (B * A) (minpoly ℂ (A * B)) * B) * A := by rw [mul_assoc]
        _ = 0 := by rw [h1, zero_mul]
    have hdiv : minpoly ℂ (B * A) ∣ minpoly ℂ (A * B) * X := by
      apply minpoly.dvd ℂ (B * A)
      rw [aeval_mul, aeval_X, h2]
    simpa [mul_comm] using hdiv