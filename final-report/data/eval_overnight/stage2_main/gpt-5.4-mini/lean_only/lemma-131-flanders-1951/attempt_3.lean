import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {idx : Type*} [Fintype idx] [DecidableEq idx]
    (A B : Matrix idx idx ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  have hdiv : ∀ A B : Matrix idx idx ℂ, minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) := by
    intro A B
    let m : Polynomial ℂ := minpoly ℂ (B * A)
    have hm : Polynomial.aeval (B * A) m = 0 := by
      simpa [m] using (minpoly.aeval (K := ℂ) (B * A))
    have hpow : ∀ k : ℕ, A * (B * A) ^ k = (A * B) ^ k * A := by
      intro k
      induction k with
      | zero =>
          simp
      | succ k hk =>
          calc
            A * (B * A) ^ Nat.succ k
                = (A * (B * A) ^ k) * (B * A) := by simp [pow_succ, mul_assoc]
            _ = ((A * B) ^ k * A) * (B * A) := by rw [hk]
            _ = (A * B) ^ k * (A * (B * A)) := by rw [mul_assoc]
            _ = (A * B) ^ k * ((A * B) * A) := by rw [mul_assoc]
            _ = ((A * B) ^ k * (A * B)) * A := by rw [mul_assoc]
            _ = (A * B) ^ Nat.succ k * A := by simp [pow_succ, mul_assoc]
    have hcomm : ∀ q : Polynomial ℂ, A * Polynomial.aeval (B * A) q = Polynomial.aeval (A * B) q * A := by
      intro q
      induction q using Polynomial.induction_on with
      | C c =>
          ext i j
          simp [Matrix.mul_apply, mul_comm, mul_left_comm, mul_assoc]
      | add p q hp hq =>
          calc
            A * Polynomial.aeval (B * A) (p + q)
                = A * (Polynomial.aeval (B * A) p + Polynomial.aeval (B * A) q) := by simp
            _ = A * Polynomial.aeval (B * A) p + A * Polynomial.aeval (B * A) q := by rw [mul_add]
            _ = Polynomial.aeval (A * B) p * A + Polynomial.aeval (A * B) q * A := by rw [hp, hq]
            _ = (Polynomial.aeval (A * B) p + Polynomial.aeval (A * B) q) * A := by rw [add_mul]
            _ = Polynomial.aeval (A * B) (p + q) * A := by simp
      | monomial c k =>
          have hc : A * (algebraMap ℂ (Matrix idx idx ℂ) c) =
              (algebraMap ℂ (Matrix idx idx ℂ) c) * A := by
            ext i j
            simp [Matrix.mul_apply, mul_comm, mul_left_comm, mul_assoc]
          calc
            A * Polynomial.aeval (B * A) (Polynomial.monomial c k)
                = A * (algebraMap ℂ (Matrix idx idx ℂ) c * (B * A) ^ k) := by
                    simp [Polynomial.aeval_monomial]
            _ = (A * (algebraMap ℂ (Matrix idx idx ℂ) c)) * (B * A) ^ k := by rw [mul_assoc]
            _ = ((algebraMap ℂ (Matrix idx idx ℂ) c) * A) * (B * A) ^ k := by rw [hc]
            _ = (algebraMap ℂ (Matrix idx idx ℂ) c) * (A * (B * A) ^ k) := by rw [mul_assoc]
            _ = (algebraMap ℂ (Matrix idx idx ℂ) c) * ((A * B) ^ k * A) := by rw [hpow k]
            _ = ((algebraMap ℂ (Matrix idx idx ℂ) c) * (A * B) ^ k) * A := by rw [mul_assoc]
            _ = Polynomial.aeval (A * B) (Polynomial.monomial c k) * A := by
                simp [Polynomial.aeval_monomial, mul_assoc]
    have h1 : Polynomial.aeval (A * B) m * A = 0 := by
      calc
        Polynomial.aeval (A * B) m * A = A * Polynomial.aeval (B * A) m := by
          rw [← hcomm m]
        _ = 0 := by rw [hm]; simp
    have hzero : Polynomial.aeval (A * B) (m * X) = 0 := by
      calc
        Polynomial.aeval (A * B) (m * X)
            = Polynomial.aeval (A * B) m * (A * B) := by simp [mul_assoc]
        _ = (Polynomial.aeval (A * B) m * A) * B := by rw [mul_assoc]
        _ = 0 := by rw [h1]; simp
    have hdiv' : minpoly ℂ (A * B) ∣ m * X := by
      apply minpoly.dvd
      exact hzero
    simpa [m, mul_comm] using hdiv'
  constructor
  · exact hdiv A B
  · exact hdiv B A