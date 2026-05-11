import Mathlib

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  have h01 : (0:ℝ) ≤ Real.pi / 2 := by
    nlinarith [Real.pi_pos]
  have h12 : Real.pi / 2 ≤ 3 * Real.pi / 2 := by
    nlinarith [Real.pi_pos]
  have h23 : 3 * Real.pi / 2 ≤ 2 * Real.pi := by
    nlinarith [Real.pi_pos]

  have h0 : ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0 = ∫ u in 0..(Real.pi / 2), Real.cos u := by
    refine intervalIntegral.integral_congr ?_
    intro u hu
    have huIcc : u ∈ Set.Icc (0:ℝ) (Real.pi / 2) := by
      simpa using hu
    have huSym : u ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) := by
      constructor
      · nlinarith [huIcc.1, Real.pi_pos]
      · exact huIcc.2
    have hcos : 0 ≤ Real.cos u := Real.cos_nonneg_of_mem_Icc huSym
    simpa [max_eq_left hcos]

  have hmid : ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0 = 0 := by
    have hmid' : ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0 = ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), (0:ℝ) := by
      refine intervalIntegral.integral_congr ?_
      intro u hu
      have huIcc : u ∈ Set.Icc (Real.pi / 2) (3 * Real.pi / 2) := by
        simpa using hu
      have hcos : Real.cos u ≤ 0 := Real.cos_nonpos_of_mem_Icc huIcc
      simpa [max_eq_right hcos]
    simpa using hmid'

  have h3 : ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 = ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), Real.cos u := by
    refine intervalIntegral.integral_congr ?_
    intro u hu
    have huIcc : u ∈ Set.Icc (3 * Real.pi / 2) (2 * Real.pi) := by
      simpa using hu
    have hmem : 2 * Real.pi - u ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) := by
      constructor
      · nlinarith [huIcc.2, Real.pi_pos]
      · nlinarith [huIcc.1, Real.pi_pos]
    have hcos' : 0 ≤ Real.cos (2 * Real.pi - u) := Real.cos_nonneg_of_mem_Icc hmem
    have hcos_eq : Real.cos (2 * Real.pi - u) = Real.cos u := by
      simp [sub_eq_add_neg, Real.cos_add, Real.cos_two_pi, Real.sin_two_pi, Real.cos_neg, Real.sin_neg]
    have hcos : 0 ≤ Real.cos u := by
      simpa [hcos_eq] using hcos'
    simpa [max_eq_left hcos]

  have hcos0 : ∫ u in (0:ℝ)..(Real.pi / 2), Real.cos u = 1 := by
    rw [Real.integral_cos]
    have hsin_half : Real.sin (Real.pi / 2) = 1 := by
      simpa using Real.sin_pi_div_two
    rw [hsin_half, Real.sin_zero]
    norm_num

  have hcos2 : ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), Real.cos u = 1 := by
    rw [Real.integral_cos]
    have hsin_two_pi : Real.sin (2 * Real.pi) = 0 := by
      simpa using Real.sin_two_pi
    have hsin_three_half : Real.sin (3 * Real.pi / 2) = -1 := by
      simpa using Real.sin_three_pi_div_two
    rw [hsin_two_pi, hsin_three_half]
    norm_num

  have hsplit :
      ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 =
        ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0
          + (∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0
          + ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0) := by
    rw [intervalIntegral.integral_add_adjacent_intervals (f := fun u => max (Real.cos u) 0) h01 h12]
    rw [intervalIntegral.integral_add_adjacent_intervals (f := fun u => max (Real.cos u) 0) h12 h23]
    ring

  calc
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 =
        ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0
          + (∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0
          + ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0) := hsplit
    _ = 1 + (0 + 1) := by
      rw [h0, hmid, h3, hcos0, hcos2]
    _ = 2 := by norm_num