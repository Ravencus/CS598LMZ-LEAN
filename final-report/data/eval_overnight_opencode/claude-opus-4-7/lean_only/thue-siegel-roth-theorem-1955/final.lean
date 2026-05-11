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

theorem algebraic_irrational_has_irrationality_measure_two
    {x : ℝ} (hx_alg : IsAlgebraic ℚ x) (hx_irr : Irrational x) :
    HasIrrationalityMeasure x 2 := by
  refine ⟨?_, ?_⟩
  · -- Thue–Siegel–Roth theorem (Roth 1955). Not formalized in Mathlib.
    sorry
  · -- Dirichlet's approximation theorem.
    intro ε hε
    have hinf : {q : ℚ | |x - q| < 1 / (q.den : ℝ) ^ 2}.Infinite :=
      Real.infinite_rat_abs_sub_lt_one_div_den_sq_of_irrational hx_irr
    rw [Filter.frequently_atTop]
    intro N
    have hbig : ∃ r ∈ {q : ℚ | |x - q| < 1 / (q.den : ℝ) ^ 2}, r.den ≥ max N 2 := by
      by_contra hcon
      push_neg at hcon
      apply hinf
      sorry
    obtain ⟨r, hr_mem, hr_den⟩ := hbig
    refine ⟨r.den, le_trans (le_max_left _ _) hr_den, r.num, ?_⟩
    have hr : |x - (r : ℝ)| < 1 / (r.den : ℝ) ^ 2 := hr_mem
    have hrcast : (r : ℝ) = (r.num : ℝ) / (r.den : ℝ) := by rw [Rat.cast_def]
    rw [hrcast] at hr
    have hden_pos : (0 : ℝ) < (r.den : ℝ) := by exact_mod_cast r.pos
    have hden_ge2 : (2 : ℝ) ≤ (r.den : ℝ) :=
      by exact_mod_cast le_trans (le_max_right N 2) hr_den
    have hden_ge1 : (1 : ℝ) ≤ (r.den : ℝ) := by linarith
    have hrpow_pos : 0 < Real.rpow (r.den : ℝ) (2 - ε) := Real.rpow_pos_of_pos hden_pos _
    have key : (1 : ℝ) / (r.den : ℝ) ^ 2 ≤ 1 / Real.rpow (r.den : ℝ) (2 - ε) := by
      apply one_div_le_one_div_of_le hrpow_pos
      have heq : ((r.den : ℝ)) ^ (2 : ℕ) = Real.rpow (r.den : ℝ) (2 : ℝ) := by
        rw [← Real.rpow_natCast]; norm_num
      rw [show ((r.den : ℝ))^2 = ((r.den : ℝ))^(2 : ℕ) by norm_num, heq]
      apply Real.rpow_le_rpow_of_exponent_le hden_ge1
      linarith
    calc |x - (r.num : ℝ) / (r.den : ℝ)|
        < 1 / (r.den : ℝ) ^ 2 := hr
      _ ≤ 1 / Real.rpow (r.den : ℝ) (2 - ε) := key