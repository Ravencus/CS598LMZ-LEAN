import Mathlib

open Filter

def HasIrrationalityMeasure (x μ : ℝ) : Prop :=
  (∀ ε : ℝ, 0 < ε →
    ∃ C : ℝ, 0 < C ∧
      ∀ p : ℤ, ∀ q : ℕ, q ≠ 0 →
        C / Real.rpow (q : ℝ) (μ + ε) ≤ |x - (p : ℝ) / (q : ℝ)|) ∧
  (∀ ε : ℝ, 0 < ε →
    ∃ᶠ q : ℕ in Filter.atTop,
      ∃ p : ℤ,
        |x - (p : ℝ) / (q : ℝ)| < 1 / Real.rpow (q : ℝ) (μ - ε))

-- Note: Clause 1 of HasIrrationalityMeasure for algebraic irrational x is
-- exactly Roth's theorem (1955), which is NOT currently formalized in
-- Mathlib. Mathlib's docstring on `LiouvilleWith` explicitly states the
-- relevant direction "is not formalized yet". A complete Lean proof
-- requires first formalizing hundreds of pages of Diophantine geometry.
--
-- The second clause (Dirichlet's theorem) IS provable from Mathlib's
-- `Real.infinite_rat_abs_sub_lt_one_div_den_sq_of_irrational`; the
-- structure is fully worked out below but the per-denominator
-- finiteness argument has a small unresolved cast issue.

private lemma dirichlet_den_unbounded {x : ℝ} (hx_irr : Irrational x) (N : ℕ) :
    ∃ r : ℚ, |x - (r : ℝ)| < 1 / (r.den : ℝ)^2 ∧ N ≤ r.den := by
  have hInf := Real.infinite_rat_abs_sub_lt_one_div_den_sq_of_irrational hx_irr
  by_contra hc
  push_neg at hc
  apply hInf
  set S := {q : ℚ | |x - (q : ℝ)| < 1 / (q.den : ℝ)^2}
  set M : ℤ := ⌈(|x| + 1) * (N : ℝ)⌉
  have hbd : ∀ r ∈ S, r.den < N ∧ |r.num| ≤ M := by
    intro r hr
    refine ⟨hc r hr, ?_⟩
    have hrS : |x - (r : ℝ)| < 1 / (r.den : ℝ)^2 := hr
    have hd_pos : 0 < r.den := r.pos
    have hdR_pos : (0 : ℝ) < r.den := by exact_mod_cast hd_pos
    have hd1 : (1 : ℝ) ≤ r.den := by exact_mod_cast hd_pos
    have h2 : |x - (r : ℝ)| < 1 := by
      refine lt_of_lt_of_le hrS ?_
      rw [div_le_one (by positivity)]
      have : (1 : ℝ) ≤ ((r.den : ℝ))^2 := one_le_pow₀ hd1
      linarith
    have hrle : |(r : ℝ)| ≤ |x| + 1 := by
      have h1 : |(r : ℝ)| - |x| ≤ |(r : ℝ) - x| := abs_sub_abs_le_abs_sub _ _
      rw [abs_sub_comm] at h1; linarith
    have heq : (|r.num| : ℝ) = |(r : ℝ)| * r.den := by
      rw [show ((r : ℝ)) = (r.num : ℝ) / (r.den : ℝ) from
          by exact_mod_cast (Rat.num_div_den r).symm]
      rw [abs_div, abs_of_pos hdR_pos, div_mul_cancel₀ _ hdR_pos.ne']
    have hdN : (r.den : ℝ) ≤ N := by exact_mod_cast (hc r hr).le
    have hnum_bd : (|r.num| : ℝ) ≤ (|x| + 1) * N := by
      rw [heq]; gcongr
    have hfinal : (|r.num| : ℝ) ≤ (M : ℝ) :=
      hnum_bd.trans (by exact_mod_cast Int.le_ceil _)
    exact_mod_cast hfinal
  have hfin : (((Finset.range N ×ˢ Finset.Icc (-M) M).image
      (fun p : ℕ × ℤ => (p.2 : ℚ) / (p.1 : ℚ))) : Set ℚ).Finite :=
    Finset.finite_toSet _
  apply hfin.subset
  intro r hr
  obtain ⟨hd, hn⟩ := hbd r hr
  refine Finset.mem_coe.mpr (Finset.mem_image.mpr ⟨(r.den, r.num), ?_, ?_⟩)
  · simp only [Finset.mem_product, Finset.mem_range, Finset.mem_Icc]
    exact ⟨hd, neg_le_of_abs_le hn, le_of_abs_le hn⟩
  · show ((r.num : ℚ) / (r.den : ℚ) : ℚ) = r
    rw [Rat.num_div_den]

theorem algebraic_irrational_has_irrationality_measure_two
    {x : ℝ} (hx_alg : IsAlgebraic ℚ x) (hx_irr : Irrational x) :
    HasIrrationalityMeasure x 2 := by
  refine ⟨?_, ?_⟩
  · -- Roth's theorem (1955, Fields Medal). NOT formalized in Mathlib.
    -- This is a genuine bottleneck — there is no path to completion
    -- within the rules without first formalizing Roth's theorem.
    intro ε hε
    sorry
  · -- Dirichlet's approximation theorem.
    intro ε hε
    rw [Filter.frequently_atTop]
    intro N
    obtain ⟨r, hr1, hr2⟩ := dirichlet_den_unbounded hx_irr N
    refine ⟨r.den, hr2, r.num, ?_⟩
    have hd1 : 1 ≤ r.den := r.pos
    have hdR : (1 : ℝ) ≤ r.den := by exact_mod_cast hd1
    have hdR0 : (0 : ℝ) < r.den := by linarith
    have hreq : ((r : ℝ)) = (r.num : ℝ) / (r.den : ℝ) := by
      exact_mod_cast (Rat.num_div_den r).symm
    rw [← hreq]
    have eq1 : ((r.den : ℝ))^(2:ℕ) = Real.rpow (r.den : ℝ) 2 := by
      rw [← Real.rpow_natCast (r.den:ℝ) 2]; norm_num
    rw [eq1] at hr1
    refine lt_of_lt_of_le hr1 ?_
    rw [one_div, one_div]
    apply inv_anti₀ (Real.rpow_pos_of_pos hdR0 _)
    exact Real.rpow_le_rpow_of_exponent_le hdR (by linarith)