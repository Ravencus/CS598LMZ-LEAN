import Mathlib

open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  have h_right : ∀ (C D : Matrix n n ℂ) (p : Polynomial ℂ),
      D * p.aeval (C * D) = p.aeval (D * C) * D := by
    intro C D p
    induction p using Polynomial.induction_on with
    | C c =>
        simp [mul_assoc]
    | X =>
        simp [mul_assoc]
    | add p q hp hq =>
        calc
          D * (p + q).aeval (C * D)
              = D * (p.aeval (C * D) + q.aeval (C * D)) := by simp
          _ = D * p.aeval (C * D) + D * q.aeval (C * D) := by rw [mul_add]
          _ = p.aeval (D * C) * D + q.aeval (D * C) * D := by rw [hp, hq]
          _ = (p.aeval (D * C) + q.aeval (D * C)) * D := by rw [add_mul]
          _ = (p + q).aeval (D * C) * D := by simp
    | mul p q hp hq =>
        calc
          D * (p * q).aeval (C * D)
              = D * (p.aeval (C * D) * q.aeval (C * D)) := by simp
          _ = (D * p.aeval (C * D)) * q.aeval (C * D) := by rw [mul_assoc]
          _ = (p.aeval (D * C) * D) * q.aeval (C * D) := by rw [hp]
          _ = p.aeval (D * C) * (D * q.aeval (C * D)) := by rw [mul_assoc]
          _ = p.aeval (D * C) * (q.aeval (D * C) * D) := by rw [hq]
          _ = (p.aeval (D * C) * q.aeval (D * C)) * D := by rw [mul_assoc]
          _ = (p * q).aeval (D * C) * D := by simp
  have h_left : ∀ (C D : Matrix n n ℂ) (p : Polynomial ℂ),
      (C * D) * p.aeval (C * D) = C * p.aeval (D * C) * D := by
    intro C D p
    calc
      (C * D) * p.aeval (C * D) = C * (D * p.aeval (C * D)) := by rw [mul_assoc]
      _ = C * (p.aeval (D * C) * D) := by rw [h_right C D p]
      _ = C * p.aeval (D * C) * D := by rw [mul_assoc]
  constructor
  · have hmin : (minpoly ℂ (B * A)).aeval (B * A) = 0 := by
      simpa using (minpoly.aeval_eq_zero (B * A))
    have h0 : (X * minpoly ℂ (B * A)).aeval (A * B) = 0 := by
      calc
        (X * minpoly ℂ (B * A)).aeval (A * B)
            = (A * B) * (minpoly ℂ (B * A)).aeval (A * B) := by simp
        _ = A * (minpoly ℂ (B * A)).aeval (B * A) * B := by
          rw [h_left A B (minpoly ℂ (B * A))]
        _ = A * 0 * B := by rw [hmin]
        _ = 0 := by simp
    exact minpoly.dvd h0
  · have hmin : (minpoly ℂ (A * B)).aeval (A * B) = 0 := by
      simpa using (minpoly.aeval_eq_zero (A * B))
    have h0 : (X * minpoly ℂ (A * B)).aeval (B * A) = 0 := by
      calc
        (X * minpoly ℂ (A * B)).aeval (B * A)
            = (B * A) * (minpoly ℂ (A * B)).aeval (B * A) := by simp
        _ = B * (minpoly ℂ (A * B)).aeval (A * B) * A := by
          rw [h_left B A (minpoly ℂ (A * B))]
        _ = B * 0 * A := by rw [hmin]
        _ = 0 := by simp
    exact minpoly.dvd h0