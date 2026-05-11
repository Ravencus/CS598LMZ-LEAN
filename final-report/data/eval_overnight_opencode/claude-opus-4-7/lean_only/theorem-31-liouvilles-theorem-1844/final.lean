import Mathlib

open Polynomial

theorem liouville_approximation_lower_bound
    {α : ℝ} {d : ℕ}
    (h_alg : IsAlgebraic ℚ α)
    (h_deg : (minpoly ℚ α).natDegree = d)
    (hd : 2 ≤ d) :
    ∃ C : ℝ, 0 < C ∧ ∀ q : ℕ, 0 < q → ∀ p : ℤ,
      |α - (p : ℝ) / (q : ℝ)| > C / ((q : ℝ) ^ d) := by
  -- Step 1: α is irrational.
  have h_int : IsIntegral ℚ α := h_alg.isIntegral
  have hα_irr : Irrational α := by
    intro ⟨r, hr⟩
    have hr_range : α ∈ (algebraMap ℚ ℝ).range := ⟨r, by simpa using hr⟩
    have h2 : 2 ≤ (minpoly ℚ α).natDegree := h_deg ▸ hd
    exact (minpoly.two_le_natDegree_iff h_int).mp h2 hr_range
  -- Step 2: Get an integer polynomial f with α as root.
  set fQ : ℚ[X] := minpoly ℚ α with hfQ_def
  have hfQ_ne : fQ ≠ 0 := minpoly.ne_zero h_int
  set f : ℤ[X] := IsLocalization.integerNormalization (nonZeroDivisors ℤ) fQ with hf_def
  have hf_aeval : aeval α f = 0 :=
    IsLocalization.integerNormalization_aeval_eq_zero (nonZeroDivisors ℤ) fQ
      (minpoly.aeval ℚ α)
  have hf_eval : eval α (f.map (algebraMap ℤ ℝ)) = 0 := by
    rw [eval_map_algebraMap]; exact hf_aeval
  have hf_ne : f ≠ 0 :=
    (IsLocalization.integerNormalization_eq_zero_iff (le_refl _) fQ).not.mpr hfQ_ne
  -- Step 3: f has the same natDegree d
  obtain ⟨b, hb_mem, hb_eq⟩ := IsLocalization.integerNormalization_spec (nonZeroDivisors ℤ) fQ
  have hb_ne : (b : ℤ) ≠ 0 := nonZeroDivisors.ne_zero hb_mem
  have hbQ_ne : ((b : ℤ) : ℚ) ≠ 0 := by exact_mod_cast hb_ne
  have h_map_deg : (f.map (algebraMap ℤ ℚ)).natDegree = fQ.natDegree := by
    rw [hb_eq]
    have hsmul : (b • fQ : ℚ[X]) = C ((b : ℤ) : ℚ) * fQ := by
      rw [show (b • fQ : ℚ[X]) = ((b : ℚ) • fQ : ℚ[X]) from by
        rw [Int.cast_smul_eq_zsmul]]
      rw [qsmul_eq_C_mul]
      simp
    rw [hsmul]
    exact natDegree_C_mul hbQ_ne
  have hf_deg : f.natDegree = d := by
    have h_inj := (algebraMap ℤ ℚ).injective_int
    rw [← natDegree_map_eq_of_injective h_inj f, h_map_deg]
    exact h_deg
  -- Step 4: Apply the Liouville lemma
  obtain ⟨A, hA_pos, hA⟩ := Liouville.exists_pos_real_of_irrational_root hα_irr hf_ne hf_eval
  -- Step 5: Set C and prove
  refine ⟨1 / (2 * A), by positivity, ?_⟩
  intro q hq p
  set b' : ℕ := q - 1 with hb'_def
  have hqb : (q : ℝ) = (b' : ℝ) + 1 := by
    have : q = b' + 1 := (Nat.sub_add_cancel hq).symm
    rw [this]; push_cast; ring
  have hA_app := hA p b'
  rw [hf_deg] at hA_app
  rw [← hqb] at hA_app
  have hq_pos : (0 : ℝ) < q := by exact_mod_cast hq
  have hqd_pos : (0 : ℝ) < (q : ℝ) ^ d := by positivity
  have hAq_pos : (0 : ℝ) < A * (q : ℝ) ^ d := mul_pos hA_pos hqd_pos
  have habs_nonneg : 0 ≤ |α - (p : ℝ) / (q : ℝ)| := abs_nonneg _
  have hge : 1 / (A * (q : ℝ) ^ d) ≤ |α - (p : ℝ) / (q : ℝ)| := by
    rw [div_le_iff₀ hAq_pos]
    nlinarith [hA_app, hA_pos, habs_nonneg, hqd_pos]
  have hlt : 1 / (2 * A) / ((q : ℝ) ^ d) < 1 / (A * (q : ℝ) ^ d) := by
    rw [div_div, div_lt_div_iff₀ (by positivity) hAq_pos]
    nlinarith [hA_pos, hqd_pos]
  linarith