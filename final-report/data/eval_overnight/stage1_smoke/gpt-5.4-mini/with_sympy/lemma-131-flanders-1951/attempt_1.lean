import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  have h_right : ∀ (C D : Matrix n n ℂ) (p : Polynomial ℂ),
      D * p.eval (C * D) = p.eval (D * C) * D := by
    intro C D p
    induction p using Polynomial.induction_on with
    | C c =>
        simp [mul_assoc]
    | X =>
        simp [mul_assoc]
    | add p q hp hq =>
        calc
          D * (p + q).eval (C * D)
              = D * (p.eval (C * D) + q.eval (C * D)) := by simp
          _ = D * p.eval (C * D) + D * q.eval (C * D) := by rw [mul_add]
          _ = p.eval (D * C) * D + q.eval (D * C) * D := by rw [hp, hq]
          _ = (p.eval (D * C) + q.eval (D * C)) * D := by rw [add_mul]
          _ = (p + q).eval (D * C) * D := by simp
    | mul p q hp hq =>
        calc
          D * (p * q).eval (C * D)
              = D * (p.eval (C * D) * q.eval (C * D)) := by simp [Polynomial.eval_mul]
          _ = (D * p.eval (C * D)) * q.eval (C * D) := by rw [mul_assoc]
          _ = (p.eval (D * C) * D) * q.eval (C * D) := by rw [hp]
          _ = p.eval (D * C) * (D * q.eval (C * D)) := by rw [mul_assoc]
          _ = p.eval (D * C) * (q.eval (D * C) * D) := by rw [hq]
          _ = (p.eval (D * C) * q.eval (D * C)) * D := by rw [mul_assoc]
          _ = (p * q).eval (D * C) * D := by simpa [Polynomial.eval_mul]
  have h_left : ∀ (C D : Matrix n n ℂ) (p : Polynomial ℂ),
      (C * D) * p.eval (C * D) = C * p.eval (D * C) * D := by
    intro C D p
    calc
      (C * D) * p.eval (C * D) = C * (D * p.eval (C * D)) := by rw [mul_assoc]
      _ = C * (p.eval (D * C) * D) := by rw [h_right C D p]
      _ = C * p.eval (D * C) * D := by rw [mul_assoc]
  constructor
  · have hmin : (minpoly ℂ (B * A)).eval (B * A) = 0 := by
      simpa using (minpoly.aeval_eq_zero (B * A))
    have h0 : (X * minpoly ℂ (B * A)).eval (A * B) = 0 := by
      calc
        (X * minpoly ℂ (B * A)).eval (A * B)
            = (A * B) * (minpoly ℂ (B * A)).eval (A * B) := by simp [Polynomial.eval_mul]
        _ = A * (minpoly ℂ (B * A)).eval (B * A) * B := by
          rw [h_left A B (minpoly ℂ (B * A))]
        _ = A * 0 * B := by rw [hmin]
        _ = 0 := by simp
    exact minpoly.dvd h0
  · have hmin : (minpoly ℂ (A * B)).eval (A * B) = 0 := by
      simpa using (minpoly.aeval_eq_zero (A * B))
    have h0 : (X * minpoly ℂ (A * B)).eval (B * A) = 0 := by
      calc
        (X * minpoly ℂ (A * B)).eval (B * A)
            = (B * A) * (minpoly ℂ (A * B)).eval (B * A) := by simp [Polynomial.eval_mul]
        _ = B * (minpoly ℂ (A * B)).eval (A * B) * A := by
          rw [h_left B A (minpoly ℂ (A * B))]
        _ = B * 0 * A := by rw [hmin]
        _ = 0 := by simp
    exact minpoly.dvd h0