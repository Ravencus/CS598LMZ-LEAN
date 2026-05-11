import Mathlib
open Filter
open Set
open Real

theorem algebraic_irrational_has_irrationality_measure_two
    {x : ℝ} (hx_alg : IsAlgebraic ℚ x) (hx_irr : Irrational x) :
    HasIrrationalityMeasure x 2 := by
  have hx_irrational : Irrational x := hx_irr
  have h_infinite_good : {q : ℚ | |x - q| < 1 / (q.den : ℝ) ^ 2}.Infinite :=
    Real.infinite_rat_abs_sub_lt_one_div_den_sq_of_irrational hx_irrational
  constructor
  · intro ε hε
    rcases hx_alg with ⟨P, hP_ne, hP_root⟩
    have hdeg : P.degree ≠ 0 := by
      intro hdeg0
      apply hx_irrational
      have hconst : P = C (P.coeff 0) := by
        rw [eq_C_of_degree_eq_zero hdeg0]
      have : aeval x (C (P.coeff 0)) = 0 := by
        rw [hconst] at hP_root
        exact hP_root
      simp at this
      have hcoeff : P.coeff 0 = 0 := by
        simpa using this
      have : P = 0 := by
        rw [hconst, hcoeff, C_0]
      exact hP_ne this
    have : IsAlgebraic ℚ x := hx_alg
    let d := (minpoly ℚ x).natDegree
    have hd_pos : 0 < d := by
      apply natDegree_pos_of_irrational hx_irrational
    sorry
  · intro ε hε
    have hpos : 0 < 2 - ε := by linarith
    have h_ineq : ∀ (q : ℚ), |x - q| < 1 / (q.den : ℝ) ^ 2 →
      |x - q| < 1 / Real.rpow (q.den : ℝ) (2 - ε) := by
      intro q hq
      have h_den_pos : (0 : ℝ) < q.den := by exact Nat.cast_pos.mpr q.pos
      have hden_one : (q.den : ℝ) ≥ 1 := by exact_mod_cast (Nat.one_le_iff_ne_zero.mpr q.den_ne_zero)
      have hrpow_lt : Real.rpow (q.den : ℝ) (2 - ε) < (q.den : ℝ) ^ 2 := by
        refine Real.rpow_lt_rpow_of_exponent_lt hden_one ?_
        linarith
      have h_div_lt : 1 / ((q.den : ℝ) ^ 2) < 1 / Real.rpow (q.den : ℝ) (2 - ε) := by
        refine (one_div_lt_one_div ?_ ?_).mpr hrpow_lt
        · positivity
        · positivity
      calc
        |x - q| < 1 / ((q.den : ℝ) ^ 2) := hq
        _ < 1 / Real.rpow (q.den : ℝ) (2 - ε) := h_div_lt
    have h_unbounded_den : ∀ N : ℕ, ∃ (q : ℚ), |x - q| < 1 / (q.den : ℝ) ^ 2 ∧ N ≤ q.den := by
      by_contra! h
      rcases h with ⟨N, hN⟩
      have h_finite : Set.Finite {q : ℚ | |x - q| < 1 / (q.den : ℝ) ^ 2} := by
        have h_bounded : {q : ℚ | |x - q| < 1 / (q.den : ℝ) ^ 2} ⊆
          {q : ℚ | q.den < N} := by
          intro q hq
          have hden_lt : q.den < N := hN q hq
          exact hden_lt
        have h_finite_den : Set.Finite {q : ℚ | q.den < N} := by
          have : Finset.ℚ '' (Finset.Icc (-⌈N * |x| + 1⌉ : ℤ) ⌈N * |x| + 1⌉ : Finset ℚ) =
            Finset.ℚ := by
            sorry
          sorry
        exact Set.Finite.subset h_finite_den h_bounded
      exact h_infinite_good h_finite
    rw [Filter.eventually_atTop]
    intro N
    rcases h_unbounded_den N with ⟨q, hq, hden⟩
    refine ⟨q.den, hden, ?_⟩
    have hq' : |x - (q.num : ℝ) / (q.den : ℝ)| < 1 / Real.rpow (q.den : ℝ) (2 - ε) := by
      have : (q.num : ℝ) / (q.den : ℝ) = (q : ℝ) := by exact mod_cast q.num_div_den.symm
      rw [this]
      exact h_ineq q hq
    refine ⟨q.num, ?_⟩
    simpa [q.num_div_den] using hq'
