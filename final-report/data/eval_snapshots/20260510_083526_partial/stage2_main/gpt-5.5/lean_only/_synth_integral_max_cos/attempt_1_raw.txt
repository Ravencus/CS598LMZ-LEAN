import Mathlib

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  have h0 : (0 : ℝ) ≤ Real.pi / 2 := by positivity
  have h1 : Real.pi / 2 ≤ 3 * Real.pi / 2 := by
    nlinarith [Real.pi_pos]
  have h2 : 3 * Real.pi / 2 ≤ 2 * Real.pi := by
    nlinarith [Real.pi_pos]
  rw [← intervalIntegral.integral_add_adjacent_intervals
        (a := (0 : ℝ)) (b := Real.pi / 2) (c := 2 * Real.pi)
        (f := fun u : ℝ => max (Real.cos u) 0)]
  rw [← intervalIntegral.integral_add_adjacent_intervals
        (a := Real.pi / 2) (b := 3 * Real.pi / 2) (c := 2 * Real.pi)
        (f := fun u : ℝ => max (Real.cos u) 0)]
  have hleft :
      ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0
        = ∫ u in (0:ℝ)..(Real.pi / 2), Real.cos u := by
    apply intervalIntegral.integral_congr
    intro u hu
    have hu0 : 0 ≤ u := hu.1
    have hup : u ≤ Real.pi / 2 := hu.2
    have hcos : 0 ≤ Real.cos u := Real.cos_nonneg_of_mem_Icc ⟨hu0, hup⟩
    exact max_eq_left hcos
  have hmid :
      ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0
        = ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), 0 := by
    apply intervalIntegral.integral_congr
    intro u hu
    have hcos : Real.cos u ≤ 0 := by
      exact Real.cos_nonpos_of_mem_Icc ⟨hu.1, hu.2⟩
    exact max_eq_right hcos
  have hright :
      ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0
        = ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), Real.cos u := by
    apply intervalIntegral.integral_congr
    intro u hu
    have hcos : 0 ≤ Real.cos u := by
      have hmem : u ∈ Set.Icc (3 * Real.pi / 2) (5 * Real.pi / 2) := by
        constructor
        · exact hu.1
        · nlinarith [hu.2]
      exact Real.cos_nonneg_of_mem_Icc' hmem
    exact max_eq_left hcos
  rw [hleft, hmid, hright]
  simp [Real.sin_pi_div_two, Real.sin_three_pi_div_two]