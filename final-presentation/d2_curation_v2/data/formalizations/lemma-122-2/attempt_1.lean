import Mathlib

theorem polynomial_shift_difference_nonconstant_with_irrational_coeff
    (P : Polynomial ℝ)
    (hdeg : 2 ≤ P.natDegree)
    (hirr : ∃ k : ℕ, 2 ≤ k ∧ Irrational (P.coeff k))
    (i j m₁ m₂ : ℤ)
    (hij : i ≠ j)
    (hm : m₁ ≠ 0 ∨ m₂ ≠ 0) :
    let Q : Polynomial ℝ :=
      Polynomial.C (m₁ : ℝ) * P.comp (Polynomial.X + Polynomial.C (i : ℝ)) -
        Polynomial.C (m₂ : ℝ) * P.comp (Polynomial.X + Polynomial.C (j : ℝ))
    ∀ d : ℕ, P.natDegree = d →
      (∃ k : ℕ, 1 ≤ k ∧ Q.coeff k ≠ 0) ∧
      ∃ k : ℕ, 1 ≤ k ∧ Irrational (Q.coeff k) := by
  sorry