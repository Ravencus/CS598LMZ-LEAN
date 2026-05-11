import Mathlib

open Polynomial

lemma aux_pow_comm {n : Type*} [Fintype n] [DecidableEq n] (A B : Matrix n n ℂ) (k : ℕ) : 
    A * ((B * A) ^ k) = ((A * B) ^ k) * A := by
  induction' k with k ih
  · simp
  · rw [pow_succ, ← mul_assoc, ih, mul_assoc, ← mul_assoc A B A, mul_assoc]

lemma mul_aeval_comm {n : Type*} [Fintype n] [DecidableEq n] (A B : Matrix n n ℂ) (p : ℂ[X]) : 
    A * (aeval (B * A) p) = (aeval (A * B) p) * A := by
  induction p using Polynomial.induction_on with
  | C c =>
    simp [Algebra.commutes]
  | add p q hp hq =>
    simp [hp, hq, add_mul, mul_add]
  | monomial d c =>
    calc
      A * (aeval (B * A) (C c * X ^ d)) = A * (aeval (B * A) (C c) * aeval (B * A) (X ^ d)) := by
        rw [(aeval (B * A)).map_mul]
      _ = A * ((algebraMap ℂ (Matrix n n ℂ) c) * ((B * A) ^ d)) := by simp
      _ = A * (c • ((B * A) ^ d)) := by simp
      _ = c • (A * ((B * A) ^ d)) := by rw [mul_smul_comm]
      _ = c • (((A * B) ^ d) * A) := by rw [aux_pow_comm A B d]
      _ = (c • ((A * B) ^ d)) * A := by rw [smul_mul_assoc]
      _ = ((algebraMap ℂ (Matrix n n ℂ) c) * ((A * B) ^ d)) * A := by simp
      _ = (aeval (A * B) (C c) * aeval (A * B) (X ^ d)) * A := by simp
      _ = (aeval (A * B) (C c * X ^ d)) * A := by rw [(aeval (A * B)).map_mul]

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  have h_aeval_BA : aeval (B * A) (minpoly ℂ (B * A)) = 0 := by
    simpa using minpoly.aeval ℂ (B * A)
  have h_B_comm : B * (aeval (A * B) (minpoly ℂ (B * A))) = (aeval (B * A) (minpoly ℂ (B * A))) * B := by
    simpa using mul_aeval_comm B A (minpoly ℂ (B * A))
  have h_mul_AB : (A * B) * (aeval (A * B) (minpoly ℂ (B * A))) = 0 := by
    calc
      (A * B) * (aeval (A * B) (minpoly ℂ (B * A))) = A * (B * (aeval (A * B) (minpoly ℂ (B * A)))) := by
        simp [mul_assoc]
      _ = A * ((aeval (B * A) (minpoly ℂ (B * A))) * B) := by rw [h_B_comm]
      _ = (A * (aeval (B * A) (minpoly ℂ (B * A)))) * B := by rw [mul_assoc]
      _ = (A * 0) * B := by rw [h_aeval_BA]
      _ = 0 := by simp
  have h_div1 : minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) := by
    apply minpoly.dvd ℂ (A * B)
    calc
      aeval (A * B) (X * minpoly ℂ (B * A)) = aeval (A * B) X * aeval (A * B) (minpoly ℂ (B * A)) := by
        simp
      _ = (A * B) * aeval (A * B) (minpoly ℂ (B * A)) := by simp
      _ = 0 := h_mul_AB
  have h_aeval_AB : aeval (A * B) (minpoly ℂ (A * B)) = 0 := by
    simpa using minpoly.aeval ℂ (A * B)
  have h_A_comm : A * (aeval (B * A) (minpoly ℂ (A * B))) = (aeval (A * B) (minpoly ℂ (A * B))) * A := by
    simpa using mul_aeval_comm A B (minpoly ℂ (A * B))
  have h_mul_BA : (B * A) * (aeval (B * A) (minpoly ℂ (A * B))) = 0 := by
    calc
      (B * A) * (aeval (B * A) (minpoly ℂ (A * B))) = B * (A * (aeval (B * A) (minpoly ℂ (A * B)))) := by
        simp [mul_assoc]
      _ = B * ((aeval (A * B) (minpoly ℂ (A * B))) * A) := by rw [h_A_comm]
      _ = (B * (aeval (A * B) (minpoly ℂ (A * B)))) * A := by rw [mul_assoc]
      _ = (B * 0) * A := by rw [h_aeval_AB]
      _ = 0 := by simp
  have h_div2 : minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
    apply minpoly.dvd ℂ (B * A)
    calc
      aeval (B * A) (X * minpoly ℂ (A * B)) = aeval (B * A) X * aeval (B * A) (minpoly ℂ (A * B)) := by
        simp
      _ = (B * A) * aeval (B * A) (minpoly ℂ (A * B)) := by simp
      _ = 0 := h_mul_BA
  exact And.intro h_div1 h_div2