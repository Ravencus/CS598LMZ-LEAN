import Mathlib

open Polynomial

theorem liouville_approximation_lower_bound
    {α : ℝ} {d : ℕ}
    (h_alg : IsAlgebraic ℚ α)
    (h_deg : (minpoly ℚ α).natDegree = d)
    (hd : 2 ≤ d) :
    ∃ C : ℝ, 0 < C ∧ ∀ q : ℕ, 0 < q → ∀ p : ℤ,
      |α - (p : ℝ) / (q : ℝ)| > C / ((q : ℝ) ^ d) := by
  -- Step 1: α is integral over ℚ
  have h_int : IsIntegral ℚ α := h_alg.isIntegral
  -- Step 2: degree of minpoly is ≥ 2
  have h_deg_ge : 2 ≤ (minpoly ℚ α).natDegree := h_deg ▸ hd
  -- Step 3: α is irrational
  have h_irr : Irrational α := by
    have : α ∉ (algebraMap ℚ ℝ).range :=
      (minpoly.two_le_natDegree_iff h_int).mp h_deg_ge
    intro ⟨q, hq⟩
    exact this ⟨q, hq⟩
  -- Step 4: integer polynomial annihilating α
  set f : ℚ[X] := minpoly ℚ α with hf_def
  have hf_ne : f ≠ 0 := minpoly.ne_zero h_int
  have hf_aeval : aeval α f = 0 := minpoly.aeval ℚ α
  set g : ℤ[X] := IsLocalization.integerNormalization (nonZeroDivisors ℤ) f with hg_def
  have hg_ne : g ≠ 0 := by
    rw [hg_def]
    exact (IsLocalization.integerNormalization_eq_zero_iff
      (M := nonZeroDivisors ℤ) (le_refl _) f).not.mpr hf_ne
  have hg_aeval : aeval α g = (0 : ℝ) := by
    rw [hg_def]
    exact IsLocalization.integerNormalization_aeval_eq_zero (M := nonZeroDivisors ℤ) f
      (by simpa using hf_aeval)
  have hg_eval : eval α (g.map (algebraMap ℤ ℝ)) = 0 := by
    rw [eval_map_algebraMap]; exact hg_aeval
  -- Step 5: g.natDegree ≤ d
  have hg_supp : g.support ⊆ f.support := by
    rw [hg_def]
    exact IsLocalization.integerNormalization_support _ f
  have hg_natDeg : g.natDegree ≤ d := by
    rw [← h_deg]
    have hg_nd_mem : g.natDegree ∈ g.support := natDegree_mem_support_of_nonzero hg_ne
    have : g.natDegree ∈ f.support := hg_supp hg_nd_mem
    exact le_natDegree_of_mem_supp _ this
  -- Step 6: apply Liouville
  obtain ⟨A, hA, h_bd⟩ := Liouville.exists_pos_real_of_irrational_root h_irr hg_ne hg_eval
  refine ⟨1 / (2 * A), by positivity, ?_⟩
  intro q hq p
  -- Apply h_bd with a = p, b = q - 1
  have hq1 : (q : ℝ) ≥ 1 := by exact_mod_cast hq
  have hq_pos : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  set b : ℕ := q - 1 with hb_def
  have hb_eq : (b : ℝ) + 1 = (q : ℝ) := by
    have : b + 1 = q := by rw [hb_def]; omega
    exact_mod_cast this
  have key : (1 : ℝ) ≤ ((b : ℝ) + 1) ^ g.natDegree * (|α - p / (b + 1)| * A) := h_bd p b
  rw [hb_eq] at key
  -- |α - p / q| ≥ 1 / (q^g.natDegree * A)
  have hA_pos : 0 < A := hA
  have h_qpow_pos : (0 : ℝ) < (q : ℝ) ^ g.natDegree := by positivity
  have h_qpow_d_pos : (0 : ℝ) < (q : ℝ) ^ d := by positivity
  have h_qpow_le : (q : ℝ) ^ g.natDegree ≤ (q : ℝ) ^ d := by
    apply pow_le_pow_right₀ hq1 hg_natDeg
  -- 1 ≤ q^nd * (|α - p/q| * A) means |α - p/q| ≥ 1/(q^nd * A)
  have h1 : 1 / ((q : ℝ) ^ g.natDegree * A) ≤ |α - p / q| := by
    have : 1 ≤ (q : ℝ) ^ g.natDegree * |α - p / q| * A := by
      have := key
      ring_nf at this ⊢
      linarith
    have hprod_pos : 0 < (q : ℝ) ^ g.natDegree * A := by positivity
    rw [div_le_iff₀ hprod_pos]
    nlinarith [abs_nonneg (α - (p : ℝ) / q)]
  have h2 : 1 / ((q : ℝ) ^ d * A) ≤ |α - p / q| := by
    have h_le : 1 / ((q : ℝ) ^ d * A) ≤ 1 / ((q : ℝ) ^ g.natDegree * A) := by
      apply one_div_le_one_div_of_le
      · positivity
      · nlinarith
    linarith
  -- Now C / q^d < 1 / (q^d * A)
  have h3 : 1 / (2 * A) / ((q : ℝ) ^ d) < 1 / ((q : ℝ) ^ d * A) := by
    rw [div_div, div_lt_div_iff₀ (by positivity) (by positivity)]
    nlinarith [hA_pos, h_qpow_d_pos]
  linarith