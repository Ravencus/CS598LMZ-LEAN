import Mathlib
open Polynomial

theorem minpoly_matrix_mul_reverse_differ_by_at_most_X
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ) :
    minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) ∧
    minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) := by
  have mul_pow_comm (X Y : Matrix n n ℂ) : ∀ k : ℕ, X * ((Y * X) ^ k) = ((X * Y) ^ k) * X
    := by
    intro k
    induction k with
    | zero =>
        simp
    | succ k ih =>
        have hstep : ((X * Y) ^ k) * (X * (Y * X)) = ((X * Y) ^ k) * ((X * Y) * X) := by
          simpa [Matrix.mul_assoc] using congrArg (fun z => ((X * Y) ^ k) * z)
            (by simp [Matrix.mul_assoc])
        calc
          X * ((Y * X) ^ (k + 1)) = X * (((Y * X) ^ k) * (Y * X)) := by rw [pow_succ]
          _ = (X * ((Y * X) ^ k)) * (Y * X) := by rw [Matrix.mul_assoc]
          _ = (((X * Y) ^ k) * X) * (Y * X) := by rw [ih]
          _ = ((X * Y) ^ k) * (X * (Y * X)) := by rw [Matrix.mul_assoc]
          _ = ((X * Y) ^ k) * ((X * Y) * X) := hstep
          _ = (((X * Y) ^ k) * (X * Y)) * X := by rw [Matrix.mul_assoc]
          _ = ((X * Y) ^ (k + 1)) * X := by rw [pow_succ]

  have mul_aeval_comm (X Y : Matrix n n ℂ) (p : Polynomial ℂ) : X * (aeval (Y * X) p) = (aeval (X * Y) p) * X := by
    induction p using Polynomial.induction_on' with
    | add p q hp hq =>
        simp [hp, hq, mul_add, add_mul]
    | monomial m a =>
        calc
          X * (aeval (Y * X) (monomial m a)) = X * (a • 1 * ((Y * X) ^ m)) := by
            rw [Polynomial.aeval_monomial, Algebra.algebraMap_eq_smul_one]
          _ = a • (X * ((Y * X) ^ m)) := by
            simpa [Matrix.mul_assoc] using (Algebra.mul_smul_comm X a ((Y * X) ^ m))
          _ = a • (((X * Y) ^ m) * X) := by rw [mul_pow_comm X Y m]
          _ = (a • ((X * Y) ^ m)) * X := by rw [smul_mul_assoc]
          _ = ((algebraMap ℂ (Matrix n n ℂ)) a * ((X * Y) ^ m)) * X := by
            simp [Algebra.algebraMap_eq_smul_one]
          _ = (aeval (X * Y) (monomial m a)) * X := by
            simp [Polynomial.aeval_monomial]

  have hp0 : aeval (B * A) (minpoly ℂ (B * A)) = 0 := minpoly.aeval ℂ (B * A)
  have hq0 : aeval (A * B) (minpoly ℂ (A * B)) = 0 := minpoly.aeval ℂ (A * B)

  have h1 : aeval (A * B) (X * minpoly ℂ (B * A)) = 0 := by
    calc
      aeval (A * B) (X * minpoly ℂ (B * A)) = (aeval (A * B) X) * (aeval (A * B) (minpoly ℂ (B * A))) := by
        rw [aeval_mul]
      _ = (A * B) * (aeval (A * B) (minpoly ℂ (B * A))) := by simp
      _ = A * (B * (aeval (A * B) (minpoly ℂ (B * A)))) := by simp [Matrix.mul_assoc]
      _ = A * ((aeval (B * A) (minpoly ℂ (B * A))) * B) := by rw [mul_aeval_comm B A (minpoly ℂ (B * A))]
      _ = A * (0 * B) := by rw [hp0]
      _ = A * 0 := by simp
      _ = 0 := by simp

  have h2 : aeval (B * A) (X * minpoly ℂ (A * B)) = 0 := by
    calc
      aeval (B * A) (X * minpoly ℂ (A * B)) = (aeval (B * A) X) * (aeval (B * A) (minpoly ℂ (A * B))) := by
        rw [aeval_mul]
      _ = (B * A) * (aeval (B * A) (minpoly ℂ (A * B))) := by simp
      _ = B * (A * (aeval (B * A) (minpoly ℂ (A * B)))) := by simp [Matrix.mul_assoc]
      _ = B * ((aeval (A * B) (minpoly ℂ (A * B))) * A) := by rw [mul_aeval_comm A B (minpoly ℂ (A * B))]
      _ = B * (0 * A) := by rw [hq0]
      _ = B * 0 := by simp
      _ = 0 := by simp

  have hdiv1 : minpoly ℂ (A * B) ∣ X * minpoly ℂ (B * A) :=
    minpoly.dvd (A := ℂ) (x := A * B) h1

  have hdiv2 : minpoly ℂ (B * A) ∣ X * minpoly ℂ (A * B) :=
    minpoly.dvd (A := ℂ) (x := B * A) h2

  exact And.intro hdiv1 hdiv2
