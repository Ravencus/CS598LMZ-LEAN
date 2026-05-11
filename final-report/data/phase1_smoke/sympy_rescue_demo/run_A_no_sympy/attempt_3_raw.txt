import Mathlib

open MeasureTheory

lemma integral_max_cos :
    ∫ u in (0 : ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  have hInt₁ : IntervalIntegrable (fun u : ℝ => max (Real.cos u) 0) volume
      (0 : ℝ) (Real.pi / 2) := by
    continuity
  have hInt₂ : IntervalIntegrable (fun u : ℝ => max (Real.cos u) 0) volume
      (Real.pi / 2) (3 * Real.pi / 2) := by
    continuity
  have hInt₃ : IntervalIntegrable (fun u : ℝ => max (Real.cos u) 0) volume
      (3 * Real.pi / 2) (2 * Real.pi) := by
    continuity
  have hsplit :
      ∫ u in (0 : ℝ)..(2 * Real.pi), max (Real.cos u) 0 =
        ∫ u in (0 : ℝ)..(Real.pi / 2), max (Real.cos u) 0 +
          ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0 +
          ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 := by
    rw [← intervalIntegral.integral_add_adjacent_intervals hInt₁ hInt₂]
    rw [← intervalIntegral.integral_add_adjacent_intervals (hInt₁.trans hInt₂) hInt₃]
    ring
  rw [hsplit]
  have hleft :
      ∫ u in (0 : ℝ)..(Real.pi / 2), max (Real.cos u) 0 =
        ∫ u in (0 : ℝ)..(Real.pi / 2), Real.cos u := by
    apply intervalIntegral.integral_congr
    intro u hu
    rw [max_eq_left]
    exact Real.cos_nonneg_of_mem_Icc ⟨hu.1, hu.2⟩
  have hmid :
      ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0 =
        ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), 0 := by
    apply intervalIntegral.integral_congr
    intro u hu
    rw [max_eq_right]
    exact Real.cos_nonpos_of_mem_Icc ⟨hu.1, hu.2⟩
  have hright :
      ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 =
        ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), Real.cos u := by
    apply intervalIntegral.integral_congr
    intro u hu
    rw [max_eq_left]
    have hcos : Real.cos u = Real.sin (u - 3 * Real.pi / 2) := by
      rw [← Real.sin_add_pi_div_two]
      congr 1
      ring
    rw [hcos]
    exact Real.sin_nonneg_of_mem_Icc ⟨by linarith, by linarith⟩
  rw [hleft, hmid, hright]
  have hsin_three : Real.sin (3 * Real.pi / 2) = -1 := by
    have : 3 * Real.pi / 2 = Real.pi + Real.pi / 2 := by ring
    rw [this, Real.sin_add]
    simp
  simp [hsin_three]