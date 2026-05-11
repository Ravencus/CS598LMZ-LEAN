import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  have hdiv : ∀ A B : Matrix n n ℂ, minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) := by
    intro A B
    let m : Polynomial ℂ := minpoly ℂ (B * A)
    have hm : Polynomial.aeval (B * A) m = 0 := by
      simpa [m] using (minpoly.aeval (K := ℂ) (B * A))
    have hcomm :
        ∀ q : Polynomial ℂ, A * Polynomial.aeval (B * A) q = Polynomial.aeval (A * B) q * A := by
      intro q
      induction q using Polynomial.induction_on with
      | C c =>
          simp
      | X =>
          simp [mul_assoc]
      | add p q hp hq =>
          calc
            A * Polynomial.aeval (B * A) (p + q)
                = A * (Polynomial.aeval (B * A) p + Polynomial.aeval (B * A) q) := by simp
            _ = A * Polynomial.aeval (B * A) p + A * Polynomial.aeval (B * A) q := by rw [mul_add]
            _ = Polynomial.aeval (A * B) p * A + Polynomial.aeval (A * B) q * A := by rw [hp, hq]
            _ = (Polynomial.aeval (A * B) p + Polynomial.aeval (A * B) q) * A := by rw [← add_mul]
            _ = Polynomial.aeval (A * B) (p + q) * A := by simp
      | mul p q hp hq =>
          calc
            A * Polynomial.aeval (B * A) (p * q)
                = A * (Polynomial.aeval (B * A) p * Polynomial.aeval (B * A) q) := by simp
            _ = (A * Polynomial.aeval (B * A) p) * Polynomial.aeval (B * A) q := by rw [mul_assoc]
            _ = (Polynomial.aeval (A * B) p * A) * Polynomial.aeval (B * A) q := by rw [hp]
            _ = Polynomial.aeval (A * B) p * (A * Polynomial.aeval (B * A) q) := by rw [mul_assoc]
            _ = Polynomial.aeval (A * B) p * (Polynomial.aeval (A * B) q * A) := by rw [hq]
            _ = (Polynomial.aeval (A * B) p * Polynomial.aeval (A * B) q) * A := by rw [mul_assoc]
            _ = Polynomial.aeval (A * B) (p * q) * A := by simp
    have hzero : Polynomial.aeval (A * B) (m * X) = 0 := by
      calc
        Polynomial.aeval (A * B) (m * X)
            = Polynomial.aeval (A * B) m * Polynomial.aeval (A * B) X := by simp [mul_assoc]
        _ = (Polynomial.aeval (A * B) m * A) * B := by simp [mul_assoc]
        _ = (A * Polynomial.aeval (B * A) m) * B := by rw [← hcomm]
        _ = A * (Polynomial.aeval (B * A) m * B) := by rw [mul_assoc]
        _ = 0 := by rw [hm]; simp
    have hdiv' : minpoly ℂ (A * B) ∣ m * X := by
      exact minpoly.dvd hzero
    simpa [m, mul_comm] using hdiv'
  constructor
  · exact hdiv A B
  · exact hdiv B A