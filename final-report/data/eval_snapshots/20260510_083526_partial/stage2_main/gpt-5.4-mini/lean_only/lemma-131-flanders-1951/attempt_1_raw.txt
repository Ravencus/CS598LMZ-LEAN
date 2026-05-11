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
    have hm : m.eval (B * A) = 0 := by
      simpa [m] using (minpoly.aeval (K := ℂ) (B * A))
    have hcomm :
        ∀ q : Polynomial ℂ, A * q.eval (B * A) = q.eval (A * B) * A := by
      intro q
      induction q using Polynomial.induction_on with
      | C c =>
          simp
      | X =>
          simp [mul_assoc]
      | add p q hp hq =>
          calc
            A * (p + q).eval (B * A)
                = A * (p.eval (B * A) + q.eval (B * A)) := by simp
            _ = A * p.eval (B * A) + A * q.eval (B * A) := by rw [mul_add]
            _ = p.eval (A * B) * A + q.eval (A * B) * A := by rw [hp, hq]
            _ = (p + q).eval (A * B) * A := by simp [add_mul, mul_add, mul_assoc]
      | mul p q hp hq =>
          calc
            A * (p * q).eval (B * A)
                = A * (p.eval (B * A) * q.eval (B * A)) := by simp
            _ = (A * p.eval (B * A)) * q.eval (B * A) := by rw [mul_assoc]
            _ = (p.eval (A * B) * A) * q.eval (B * A) := by rw [hp]
            _ = p.eval (A * B) * (A * q.eval (B * A)) := by rw [mul_assoc]
            _ = p.eval (A * B) * (q.eval (A * B) * A) := by rw [hq]
            _ = (p.eval (A * B) * q.eval (A * B)) * A := by rw [mul_assoc]
            _ = (p * q).eval (A * B) * A := by simp
    have hzero : (m * X).eval (A * B) = 0 := by
      calc
        (m * X).eval (A * B) = m.eval (A * B) * (A * B) := by simp [mul_assoc]
        _ = (m.eval (A * B) * A) * B := by rw [mul_assoc]
        _ = (A * m.eval (B * A)) * B := by rw [← hcomm]
        _ = A * (m.eval (B * A) * B) := by rw [mul_assoc]
        _ = 0 := by rw [hm]; simp
    have hdiv' : minpoly ℂ (A * B) ∣ m * X := by
      exact minpoly.dvd hzero
    simpa [m, mul_comm] using hdiv'
  constructor
  · exact hdiv A B
  · exact hdiv B A