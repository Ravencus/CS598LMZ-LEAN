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
    intro hrat
    rcases hrat with ⟨r, rfl⟩
    have h1 : (minpoly ℚ (r : ℝ)).natDegree = 1 := by
      simpa using
        congrArg Polynomial.natDegree
          (minpoly.eq_X_sub_C_of_algebraMap_inj (A := ℚ) (B := ℝ) r (algebraMap ℚ ℝ).injective)
    rw [h_deg] at h1
    omega

  let p : ℚ[X] := minpoly ℚ α
  let pZ : ℤ[X] := IsLocalization.integerNormalization (M := nonZeroDivisors ℤ) p
  obtain ⟨b, hb, hmap⟩ := IsLocalization.integerNormalization_spec (M := nonZeroDivisors ℤ) (p := p)
  have hb0 : (b : ℤ) ≠ 0 := mem_nonZeroDivisors_iff_ne_zero.mp hb
  have hpZ_root : aeval α pZ = 0 := by
    simpa [pZ, p] using
      (IsLocalization.integerNormalization_aeval_eq_zero (M := nonZeroDivisors ℤ)
        (p := p) (x := α) (R := ℤ) (S := ℚ) (R' := ℝ) (hx := minpoly.aeval ℚ α))
  have hpZ_deg : pZ.natDegree = d := by
    rw [← Polynomial.natDegree_map (f := algebraMap ℤ ℚ) (p := pZ), hmap]
    simpa [h_deg] using
      (Polynomial.natDegree_smul (p := p) (a := (b : ℤ)) hb0)
  have hp_ne : p ≠ 0 := by
    simpa [p] using (minpoly.ne_zero h_alg.isIntegral)
  have hpZ_ne : pZ ≠ 0 := by
    intro h0
    exact hp_ne ((IsLocalization.integerNormalization_eq_zero_iff (M := nonZeroDivisors ℤ)
      (p := p) (hM := le_rfl)).1 h0)
  obtain ⟨A, hApos, hA⟩ := Liouville.exists_pos_real_of_irrational_root h_irr hpZ_ne hpZ_root
  refine ⟨1 / (2 * A), ?_, ?_⟩
  · positivity
  · intro q hq p
    have hq1 : (q - 1 + 1 : ℕ) = q := Nat.succ_pred_eq_of_pos hq
    have hq1R : ((q - 1 : ℕ) : ℝ) + 1 = (q : ℝ) := by
      exact_mod_cast hq1
    have hbase : (1 : ℝ) ≤ (q : ℝ) ^ d * (|α - (p : ℝ) / (q : ℝ)| * A) := by
      simpa [hq1R, hpZ_deg, mul_assoc] using hA p (q - 1)
    have hmain : (1 : ℝ) / A ≤ (q : ℝ) ^ d * |α - (p : ℝ) / (q : ℝ)| := by
      have hbase' : (1 : ℝ) ≤ ((q : ℝ) ^ d * |α - (p : ℝ) / (q : ℝ)|) * A := by
        simpa [mul_assoc] using hbase
      exact (div_le_iff₀ hApos).2 hbase'
    have h2Apos : 0 < (2 : ℝ) * A := by nlinarith
    have hA_lt : A < (2 : ℝ) * A := by nlinarith [hApos]
    have hlt : (1 : ℝ) / (2 * A) < (1 : ℝ) / A := by
      exact (one_div_lt_one_div h2Apos hApos).2 hA_lt
    have hC : (1 : ℝ) / (2 * A) < (q : ℝ) ^ d * |α - (p : ℝ) / (q : ℝ)| := by
      exact lt_of_lt_of_le hlt hmain
    have hCcomm : (1 : ℝ) / (2 * A) < |α - (p : ℝ) / (q : ℝ)| * (q : ℝ) ^ d := by
      simpa [mul_comm, mul_left_comm, mul_assoc] using hC
    have hqpow_pos : 0 < (q : ℝ) ^ d := by positivity
    exact (div_lt_iff₀ hqpow_pos).2 hCcomm