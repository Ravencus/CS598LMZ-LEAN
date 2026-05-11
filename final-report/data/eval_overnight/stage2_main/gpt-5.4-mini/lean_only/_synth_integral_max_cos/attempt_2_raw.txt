import Mathlib

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  have h01 : (0 : ℝ) ≤ Real.pi / 2 := by
    nlinarith [Real.pi_pos]
  have h12 : Real.pi / 2 ≤ 3 * Real.pi / 2 := by
    nlinarith [Real.pi_pos]
  have h23 : 3 * Real.pi / 2 ≤ 2 * Real.pi := by
    nlinarith [Real.pi_pos]
  have h02 : (Real.pi / 2 : ℝ) ≤ 2 * Real.pi := by
    nlinarith [Real.pi_pos]

  have h0 : ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0 = ∫ u in 0..(Real.pi / 2), Real.cos u := by
    refine intervalIntegral.integral_congr ?_
    intro u hu
    have huIcc : u ∈ Set.Icc (0 : ℝ) (Real.pi / 2) := by
      simpa [Set.uIcc_of_le h01] using hu
    have hcos : 0 ≤ Real.cos u := Real.cos_nonneg_of_mem_Icc huIcc
    simpa [max_eq_left hcos]

  have hmid : ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0 = 0 := by
    have hmid' : ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0 =
        ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), (0 : ℝ) := by
      refine intervalIntegral.integral_congr ?_
      intro u hu
      have huIcc : u ∈ Set.Icc (Real.pi / 2) (3 * Real.pi / 2) := by
        simpa [Set.uIcc_of_le h12] using hu
      have hu_mem : u - Real.pi ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) := by
        constructor
        · nlinarith [huIcc.1, Real.pi_pos]
        · nlinarith [huIcc.2, Real.pi_pos]
      have hnonneg : 0 ≤ Real.cos (u - Real.pi) := Real.cos_nonneg_of_mem_Icc hu_mem
      have hcos_eq : Real.cos u = - Real.cos (u - Real.pi) := by
        have h := Real.cos_add_pi (u - Real.pi)
        simpa [sub_eq_add_neg, add_comm, add_left_comm, add_assoc] using h
      have hcos : Real.cos u ≤ 0 := by
        nlinarith [hcos_eq, hnonneg]
      simpa [max_eq_right hcos]
    simpa using hmid'

  have h3 : ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 =
      ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), Real.cos u := by
    refine intervalIntegral.integral_congr ?_
    intro u hu
    have huIcc : u ∈ Set.Icc (3 * Real.pi / 2) (2 * Real.pi) := by
      simpa [Set.uIcc_of_le h23] using hu
    have hmem : 2 * Real.pi - u ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) := by
      constructor
      · nlinarith [huIcc.2, Real.pi_pos]
      · nlinarith [huIcc.1, Real.pi_pos]
    have hcos' : 0 ≤ Real.cos (2 * Real.pi - u) := Real.cos_nonneg_of_mem_Icc hmem
    have hcos_eq : Real.cos (2 * Real.pi - u) = Real.cos u := by
      simp [sub_eq_add_neg, Real.cos_add, Real.cos_two_pi, Real.sin_two_pi, Real.cos_neg, Real.sin_neg]
    have hcos : 0 ≤ Real.cos u := by
      rw [← hcos_eq]
      exact hcos'
    simpa [max_eq_left hcos]

  have hcos0 : ∫ u in (0:ℝ)..(Real.pi / 2), Real.cos u = 1 := by
    rw [intervalIntegral.integral_cos]
    have hsin_half : Real.sin (Real.pi / 2) = 1 := by
      simpa using Real.sin_pi_div_two
    rw [hsin_half, Real.sin_zero]
    norm_num

  have hcos2 : ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), Real.cos u = 1 := by
    rw [intervalIntegral.integral_cos]
    have hsin_two_pi : Real.sin (2 * Real.pi) = 0 := by
      simpa using Real.sin_two_pi
    have hsin_three_half : Real.sin (3 * Real.pi / 2) = -1 := by
      simpa using Real.sin_three_pi_div_two
    rw [hsin_two_pi, hsin_three_half]
    norm_num

  let f : ℝ → ℝ := fun u => max (Real.cos u) 0
  have hcont : Continuous f := by
    simpa [f] using (Real.continuous_cos.max continuous_const)
  have hint02 : IntervalIntegrable f (0 : ℝ) (2 * Real.pi) := by
    simpa [f] using hcont.intervalIntegrable
  have hintmid2 : IntervalIntegrable f (Real.pi / 2) (2 * Real.pi) := by
    simpa [f] using hcont.intervalIntegrable

  have hsplit1 :
      ∫ u in (0:ℝ)..(2 * Real.pi), f u =
        ∫ u in (0:ℝ)..(Real.pi / 2), f u + ∫ u in (Real.pi / 2)..(2 * Real.pi), f u := by
    simpa [f, add_assoc] using
      (intervalIntegral.integral_add_adjacent_intervals (f := f) hint02 h01 h02)

  have hsplit2 :
      ∫ u in (Real.pi / 2)..(2 * Real.pi), f u =
        ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), f u + ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), f u := by
    simpa [f, add_assoc] using
      (intervalIntegral.integral_add_adjacent_intervals (f := f) hintmid2 h12 h23)

  calc
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 =
        ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0 +
          ∫ u in (Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 := by
      simpa [f] using hsplit1
    _ = ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0 +
          (∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0 +
            ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0) := by
      rw [hsplit2]
      ring
    _ = 1 + (0 + 1) := by
      rw [h0, hmid, h3, hcos0, hcos2]
    _ = 2 := by norm_num