import Mathlib
open scoped Polynomial

theorem liouville_approximation_lower_bound
    {α : ℝ} {d : ℕ}
    (h_alg : IsAlgebraic ℚ α)
    (h_deg : (minpoly ℚ α).natDegree = d)
    (hd : 2 ≤ d) :
    ∃ C : ℝ, 0 < C ∧ ∀ q : ℕ, 0 < q → ∀ p : ℤ,
      |α - (p : ℝ) / (q : ℝ)| > C / ((q : ℝ) ^ d) := by
  have h_irr : Irrational α := by
    rintro ⟨q, rfl⟩
    have h1 : (minpoly ℚ α).natDegree = 1 := by
      exact (minpoly.natDegree_eq_one_iff (A := ℚ) (x := α)).2 ⟨q, rfl⟩
    have hd1 : d = 1 := by
      simpa [h_deg] using h1
    omega
  let P : ℚ[X] := minpoly ℚ α
  have hP0 : P ≠ 0 := by
    simpa [P] using (minpoly.ne_zero h_alg.isIntegral)
  let M : Submonoid ℤ := nonZeroDivisors ℤ
  have hQ0 : (IsLocalization.integerNormalization M P) ≠ 0 := by
    intro hzero
    apply hP0
    exact (IsLocalization.integerNormalization_eq_zero_iff (M := M) (hM := le_rfl) P).mp hzero
  have hQroot : Polynomial.aeval α (IsLocalization.integerNormalization M P) = 0 := by
    simpa [M, P] using
      (IsLocalization.integerNormalization_aeval_eq_zero (M := M) (algebraMap ℚ ℝ) P (x := α)
        (by simpa [P] using (minpoly.aeval (A := ℚ) (x := α))))
  obtain ⟨b, hb, hmap⟩ := IsLocalization.integerNormalization_spec (M := M) P
  have hb0 : (b : ℚ) ≠ 0 := by
    exact_mod_cast (mem_nonZeroDivisors_iff_ne_zero.mp hb)
  have hdegP : P.natDegree = d := by
    simpa [P] using h_deg
  have hdegQ : (IsLocalization.integerNormalization M P).natDegree = d := by
    have htmp : ((IsLocalization.integerNormalization M P).map (algebraMap ℤ ℚ)).natDegree = d := by
      rw [hmap]
      simpa [hdegP, Algebra.smul_def] using
        (Polynomial.natDegree_C_mul (a := (b : ℚ)) hb0 (p := P))
    have hmapnat := Polynomial.natDegree_map_eq_of_injective (algebraMap ℤ ℚ).injective
      (p := IsLocalization.integerNormalization M P)
    exact hmapnat.symm.trans htmp
  obtain ⟨A, hApos, hAineq⟩ :=
    Liouville.exists_pos_real_of_irrational_root h_irr (f := IsLocalization.integerNormalization M P)
      hQ0 hQroot
  refine ⟨(1 : ℝ) / (2 * A), ?_, ?_⟩
  · positivity
  · intro q hq p
    have hsucc : (q - 1) + 1 = q := Nat.succ_pred_eq_of_pos hq
    have hpos : (0 : ℝ) < 2 * A * (q : ℝ) ^ d := by
      positivity
    have hbound : (1 : ℝ) ≤ A * (q : ℝ) ^ d * |α - (p : ℝ) / (q : ℝ)| := by
      have hbound' := hAineq p (q - 1)
      simpa [hsucc, hdegQ, mul_assoc, mul_comm, mul_left_comm] using hbound'
    have hlt : (1 : ℝ) < |α - (p : ℝ) / (q : ℝ)| * (2 * A * (q : ℝ) ^ d) := by
      nlinarith
    have hC : (1 : ℝ) / (2 * A * (q : ℝ) ^ d) < |α - (p : ℝ) / (q : ℝ)| := by
      simpa [mul_assoc, mul_comm, mul_left_comm] using (div_lt_iff₀ hpos).2 hlt
    simpa [mul_assoc, mul_comm, mul_left_comm] using hC