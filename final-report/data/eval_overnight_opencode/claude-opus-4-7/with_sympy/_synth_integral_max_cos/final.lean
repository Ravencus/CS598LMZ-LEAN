import Mathlib

open Real intervalIntegral MeasureTheory

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  have hpi : (0:ℝ) < Real.pi := Real.pi_pos
  -- Split: [0, π/2] ∪ [π/2, 3π/2] ∪ [3π/2, 2π]
  have h1 : (0:ℝ) ≤ Real.pi / 2 := by linarith
  have h2 : Real.pi / 2 ≤ 3 * Real.pi / 2 := by linarith
  have h3 : 3 * Real.pi / 2 ≤ 2 * Real.pi := by linarith
  -- The function max(cos u, 0) is continuous
  have hcont : Continuous (fun u => max (Real.cos u) 0) :=
    Real.continuous_cos.max continuous_const
  -- Split the integral
  rw [← intervalIntegral.integral_add_adjacent_intervals
    (a := (0:ℝ)) (b := Real.pi/2) (c := 2 * Real.pi)
    (hcont.intervalIntegrable _ _) (hcont.intervalIntegrable _ _)]
  rw [← intervalIntegral.integral_add_adjacent_intervals
    (a := Real.pi/2) (b := 3 * Real.pi / 2) (c := 2 * Real.pi)
    (hcont.intervalIntegrable _ _) (hcont.intervalIntegrable _ _)]
  -- Piece 1: [0, π/2], cos ≥ 0, so max = cos, integral = sin(π/2) - sin(0) = 1
  have piece1 : ∫ u in (0:ℝ)..(Real.pi/2), max (Real.cos u) 0 = 1 := by
    have heq : ∀ u ∈ Set.uIcc (0:ℝ) (Real.pi/2), max (Real.cos u) 0 = Real.cos u := by
      intro u hu
      rw [Set.uIcc_of_le h1] at hu
      have : 0 ≤ Real.cos u := Real.cos_nonneg_of_mem_Icc ⟨by linarith [hu.1], by linarith [hu.2]⟩
      exact max_eq_left this
    rw [intervalIntegral.integral_congr heq]
    rw [integral_cos]
    simp [Real.sin_pi_div_two]
  -- Piece 2: [π/2, 3π/2], cos ≤ 0, so max = 0, integral = 0
  have piece2 : ∫ u in (Real.pi/2)..(3 * Real.pi / 2), max (Real.cos u) 0 = 0 := by
    have heq : ∀ u ∈ Set.uIcc (Real.pi/2) (3 * Real.pi / 2), max (Real.cos u) 0 = 0 := by
      intro u hu
      rw [Set.uIcc_of_le h2] at hu
      have hcos : Real.cos u ≤ 0 := by
        apply Real.cos_nonpos_of_pi_div_two_le_of_le hu.1
        linarith [hu.2]
      exact max_eq_right hcos
    rw [intervalIntegral.integral_congr heq]
    simp
  -- Piece 3: [3π/2, 2π], cos ≥ 0, so max = cos, integral = sin(2π) - sin(3π/2) = 0 - (-1) = 1
  have piece3 : ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 = 1 := by
    have heq : ∀ u ∈ Set.uIcc (3 * Real.pi / 2) (2 * Real.pi), max (Real.cos u) 0 = Real.cos u := by
      intro u hu
      rw [Set.uIcc_of_le h3] at hu
      have : 0 ≤ Real.cos u := by
        have h4 : Real.cos u = Real.cos (u - 2 * Real.pi) := by
          rw [Real.cos_sub_two_pi]
        rw [h4]
        apply Real.cos_nonneg_of_mem_Icc
        constructor
        · linarith [hu.1]
        · linarith [hu.2]
      exact max_eq_left this
    rw [intervalIntegral.integral_congr heq]
    rw [integral_cos]
    have h2pi : Real.sin (2 * Real.pi) = 0 := by
      rw [show (2 * Real.pi) = 2 * Real.pi from rfl]
      simp [Real.sin_two_pi]
    have h3pi2 : Real.sin (3 * Real.pi / 2) = -1 := by
      have : (3 * Real.pi / 2) = Real.pi + Real.pi / 2 := by ring
      rw [this, Real.sin_add, Real.sin_pi, Real.cos_pi, Real.sin_pi_div_two]
      ring
    rw [h2pi, h3pi2]; ring
  rw [piece1, piece2, piece3]; ring