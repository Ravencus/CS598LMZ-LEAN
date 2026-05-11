import Mathlib

open Real intervalIntegral MeasureTheory

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  have hpi : (0:ℝ) < Real.pi := Real.pi_pos
  have h1 : (0:ℝ) ≤ Real.pi / 2 := by linarith
  have h2 : Real.pi / 2 ≤ 3 * Real.pi / 2 := by linarith
  have h3 : 3 * Real.pi / 2 ≤ 2 * Real.pi := by linarith
  have hcont : Continuous (fun u : ℝ => max (Real.cos u) 0) :=
    Real.continuous_cos.max continuous_const
  have hint : ∀ a b : ℝ, IntervalIntegrable (fun u => max (Real.cos u) 0) MeasureTheory.volume a b :=
    fun a b => hcont.intervalIntegrable a b
  rw [← integral_add_adjacent_intervals (hint 0 (Real.pi/2)) (hint (Real.pi/2) (2*Real.pi))]
  rw [← integral_add_adjacent_intervals (hint (Real.pi/2) (3*Real.pi/2)) (hint (3*Real.pi/2) (2*Real.pi))]
  have eq1 : ∫ u in (0:ℝ)..(Real.pi/2), max (Real.cos u) 0 = 1 := by
    have heq : ∀ u ∈ Set.uIcc (0:ℝ) (Real.pi/2), max (Real.cos u) 0 = Real.cos u := by
      intro u hu
      rw [Set.uIcc_of_le h1] at hu
      obtain ⟨ha, hb⟩ := hu
      have : 0 ≤ Real.cos u := Real.cos_nonneg_of_mem_Icc ⟨by linarith, by linarith⟩
      exact max_eq_left this
    rw [integral_congr heq, integral_cos]
    simp [Real.sin_pi_div_two]
  have eq2 : ∫ u in (Real.pi/2)..(3*Real.pi/2), max (Real.cos u) 0 = 0 := by
    have heq : ∀ u ∈ Set.uIcc (Real.pi/2) (3*Real.pi/2), max (Real.cos u) 0 = 0 := by
      intro u hu
      rw [Set.uIcc_of_le h2] at hu
      obtain ⟨ha, hb⟩ := hu
      have hc : Real.cos u ≤ 0 := Real.cos_nonpos_of_pi_div_two_le_of_le ha (by linarith)
      exact max_eq_right hc
    rw [integral_congr heq]; simp
  have eq3 : ∫ u in (3*Real.pi/2)..(2*Real.pi), max (Real.cos u) 0 = 1 := by
    have heq : ∀ u ∈ Set.uIcc (3*Real.pi/2) (2*Real.pi), max (Real.cos u) 0 = Real.cos u := by
      intro u hu
      rw [Set.uIcc_of_le h3] at hu
      obtain ⟨ha, hb⟩ := hu
      have hshift : Real.cos u = Real.cos (u - 2 * Real.pi) := by
        rw [Real.cos_sub_two_pi]
      have hnn : 0 ≤ Real.cos u := by
        rw [hshift]
        apply Real.cos_nonneg_of_mem_Icc
        refine ⟨by linarith, by linarith⟩
      exact max_eq_left hnn
    rw [integral_congr heq, integral_cos]
    have hs1 : Real.sin (2 * Real.pi) = 0 := by
      rw [show (2 * Real.pi : ℝ) = Real.pi + Real.pi by ring, Real.sin_add_pi, Real.sin_pi]
      ring
    have hs2 : Real.sin (3 * Real.pi / 2) = -1 := by
      rw [show (3 * Real.pi / 2 : ℝ) = Real.pi / 2 + Real.pi by ring, Real.sin_add_pi, Real.sin_pi_div_two]
    rw [hs1, hs2]; ring
  rw [eq1, eq2, eq3]; ring