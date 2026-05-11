import Mathlib

open Real
open Set
open intervalIntegral

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  have hcont : Continuous fun u : ℝ => max (Real.cos u) 0 :=
    Continuous.max Real.continuous_cos continuous_const
  have hint01 : IntervalIntegrable (fun u : ℝ => max (Real.cos u) 0) MeasureTheory.volume 0 (π / 2) := by
    simpa using (hcont.intervalIntegrable (0 : ℝ) (π / 2))
  have hint12 : IntervalIntegrable (fun u : ℝ => max (Real.cos u) 0) MeasureTheory.volume (π / 2) (3 * π / 2) := by
    simpa using (hcont.intervalIntegrable (π / 2 : ℝ) (3 * π / 2))
  have hint23 : IntervalIntegrable (fun u : ℝ => max (Real.cos u) 0) MeasureTheory.volume (3 * π / 2) (2 * π) := by
    simpa using (hcont.intervalIntegrable (3 * π / 2 : ℝ) (2 * π))
  have h_split : ∫ u in (0:ℝ)..(2*π), max (Real.cos u) 0 =
      (∫ u in (0:ℝ)..(π/2), max (Real.cos u) 0) +
      (∫ u in (π/2)..(3*π/2), max (Real.cos u) 0) +
      (∫ u in (3*π/2)..(2*π), max (Real.cos u) 0) := by
    have hsplit1 : (∫ u in (0:ℝ)..(π/2), max (Real.cos u) 0) +
        (∫ u in (π/2)..(2*π), max (Real.cos u) 0) =
        ∫ u in (0:ℝ)..(2*π), max (Real.cos u) 0 :=
      intervalIntegral.integral_add_adjacent_intervals hint01 (by simpa using (hcont.intervalIntegrable (π / 2 : ℝ) (2 * π)))
    have hsplit2 : (∫ u in (π/2)..(3*π/2), max (Real.cos u) 0) +
        (∫ u in (3*π/2)..(2*π), max (Real.cos u) 0) =
        ∫ u in (π/2)..(2*π), max (Real.cos u) 0 :=
      intervalIntegral.integral_add_adjacent_intervals hint12 hint23
    calc
      ∫ u in (0:ℝ)..(2*π), max (Real.cos u) 0
          = (∫ u in (0:ℝ)..(π/2), max (Real.cos u) 0) + (∫ u in (π/2)..(2*π), max (Real.cos u) 0) := by
        exact hsplit1.symm
      _ = (∫ u in (0:ℝ)..(π/2), max (Real.cos u) 0) +
          ((∫ u in (π/2)..(3*π/2), max (Real.cos u) 0) + (∫ u in (3*π/2)..(2*π), max (Real.cos u) 0)) := by
        rw [hsplit2]
      _ = (∫ u in (0:ℝ)..(π/2), max (Real.cos u) 0) + (∫ u in (π/2)..(3*π/2), max (Real.cos u) 0) +
          (∫ u in (3*π/2)..(2*π), max (Real.cos u) 0) := by ring_nf
  have h_int1 : (∫ u in (0:ℝ)..(π/2), max (Real.cos u) 0) = (∫ u in (0:ℝ)..(π/2), Real.cos u) := by
    refine intervalIntegral.integral_congr (fun u hu => ?_)
    rw [Set.mem_uIcc] at hu
    rcases hu with ⟨hu1, hu2⟩ | ⟨hu1, hu2⟩
    ·
      have h_nonneg : 0 ≤ Real.cos u := by
        apply Real.cos_nonneg_of_mem_Icc
        have hpi2 : (0 : ℝ) ≤ π / 2 := by positivity
        have h_lower : -(π / 2) ≤ u := by
          have hneg : -(π / 2 : ℝ) ≤ 0 := by nlinarith [Real.pi_pos]
          linarith [hu1, hneg]
        exact ⟨h_lower, hu2⟩
      rw [max_eq_left h_nonneg]
    · exfalso
      nlinarith [hu1, hu2, Real.pi_pos]
  have h_int2 : (∫ u in (π/2)..(3*π/2), max (Real.cos u) 0) = 0 := by
    calc
      (∫ u in (π/2)..(3*π/2), max (Real.cos u) 0) = (∫ u in (π/2)..(3*π/2), (0 : ℝ)) := by
        refine intervalIntegral.integral_congr (fun u hu => ?_)
        rw [Set.mem_uIcc] at hu
        rcases hu with ⟨hu1, hu2⟩ | ⟨hu1, hu2⟩
        ·
          have h_shift : u - π ∈ Set.Icc (-(π/2)) (π/2) := by
            constructor
            · nlinarith [hu1, Real.pi_pos]
            · nlinarith [hu2, Real.pi_pos]
          have h_nonneg_shift : 0 ≤ Real.cos (u - π) := Real.cos_nonneg_of_mem_Icc h_shift
          have h_cos_eq : Real.cos u = -Real.cos (u - π) := by
            have h := Real.cos_add_pi (u - π)
            simpa [sub_eq_add_neg, add_comm, add_left_comm, add_assoc] using h
          have h_nonpos : Real.cos u ≤ 0 := by
            linarith
          rw [max_eq_right h_nonpos]
        · exfalso
          nlinarith [hu1, hu2, Real.pi_pos]
      _ = 0 := by simp
  have h_int3 : (∫ u in (3*π/2)..(2*π), max (Real.cos u) 0) = (∫ u in (3*π/2)..(2*π), Real.cos u) := by
    refine intervalIntegral.integral_congr (fun u hu => ?_)
    rw [Set.mem_uIcc] at hu
    rcases hu with ⟨hu1, hu2⟩ | ⟨hu1, hu2⟩
    ·
      have h_shift : u - 2 * π ∈ Set.Icc (-(π/2)) (π/2) := by
        constructor
        · nlinarith [hu1, Real.pi_pos]
        · nlinarith [hu2, Real.pi_pos]
      have h_nonneg_shift : 0 ≤ Real.cos (u - 2 * π) := Real.cos_nonneg_of_mem_Icc h_shift
      have h_cos_eq : Real.cos (u - 2 * π) = Real.cos u := by
        calc
          Real.cos (u - 2 * π) = Real.cos u * Real.cos (2 * π) + Real.sin u * Real.sin (2 * π) := by
            rw [Real.cos_sub]
          _ = Real.cos u * 1 + Real.sin u * 0 := by simp
          _ = Real.cos u := by ring_nf
      have h_nonneg : 0 ≤ Real.cos u := by
        simpa [h_cos_eq] using h_nonneg_shift
      rw [max_eq_left h_nonneg]
    · exfalso
      nlinarith [hu1, hu2, Real.pi_pos]
  have h_sin_3pi_div_2 : Real.sin (3*π/2) = -1 := by
    calc
      Real.sin (3*π/2) = Real.sin (π + π/2) := by ring_nf
      _ = Real.sin π * Real.cos (π/2) + Real.cos π * Real.sin (π/2) := by rw [Real.sin_add]
      _ = 0 * 0 + (-1) * 1 := by simp
      _ = -1 := by ring_nf
  calc
    ∫ u in (0:ℝ)..(2*π), max (Real.cos u) 0
        = (∫ u in (0:ℝ)..(π/2), max (Real.cos u) 0) + (∫ u in (π/2)..(3*π/2), max (Real.cos u) 0) +
          (∫ u in (3*π/2)..(2*π), max (Real.cos u) 0) := by rw [h_split]
    _ = (∫ u in (0:ℝ)..(π/2), Real.cos u) + 0 + (∫ u in (3*π/2)..(2*π), Real.cos u) := by
      rw [h_int1, h_int2, h_int3]
    _ = (∫ u in (0:ℝ)..(π/2), Real.cos u) + (∫ u in (3*π/2)..(2*π), Real.cos u) := by ring_nf
    _ = (Real.sin (π/2) - Real.sin 0) + (Real.sin (2*π) - Real.sin (3*π/2)) := by
      rw [integral_cos, integral_cos]
    _ = (1 - 0) + (0 - (-1)) := by
      simp [Real.sin_pi_div_two, Real.sin_zero, Real.sin_two_pi, h_sin_3pi_div_2]
    _ = 2 := by ring_nf
