import Mathlib

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  have hsplit1 :
      ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0
        = ∫ u in (0:ℝ)..(3 * Real.pi / 2), max (Real.cos u) 0
          + ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 := by
    simpa using
      (intervalIntegral.integral_add_adjacent_intervals
        (f := fun u => max (Real.cos u) 0)
        (a := (0 : ℝ)) (b := 3 * Real.pi / 2) (c := 2 * Real.pi)
        (by nlinarith [Real.pi_pos]) (by nlinarith [Real.pi_pos]))
  have hsplit2 :
      ∫ u in (0:ℝ)..(3 * Real.pi / 2), max (Real.cos u) 0
        = ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0
          + ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0 := by
    simpa using
      (intervalIntegral.integral_add_adjacent_intervals
        (f := fun u => max (Real.cos u) 0)
        (a := (0 : ℝ)) (b := Real.pi / 2) (c := 3 * Real.pi / 2)
        (by nlinarith [Real.pi_pos]) (by nlinarith [Real.pi_pos]))
  have h1 :
      ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0
        = ∫ u in (0:ℝ)..(Real.pi / 2), Real.cos u := by
    refine intervalIntegral.integral_congr ?_
    intro u hu
    have hcos : 0 ≤ Real.cos u := by
      apply Real.cos_nonneg_of_mem_Icc
      rcases hu with ⟨hu0, hu1⟩
      constructor
      · nlinarith [hu0, Real.pi_pos]
      · exact hu1
    simpa [max_eq_left hcos]
  have h2 :
      ∫ u in (Real.pi / 2:ℝ)..(3 * Real.pi / 2), max (Real.cos u) 0 = 0 := by
    simpa using
      (intervalIntegral.integral_congr (by
        intro u hu
        have hcos : Real.cos u ≤ 0 := by
          apply Real.cos_nonpos_of_mem_Icc
          exact hu
        simpa [max_eq_right hcos]))
  have h3 :
      ∫ u in (3 * Real.pi / 2:ℝ)..(2 * Real.pi), max (Real.cos u) 0
        = ∫ u in (3 * Real.pi / 2:ℝ)..(2 * Real.pi), Real.cos u := by
    refine intervalIntegral.integral_congr ?_
    intro u hu
    have hnonpos : Real.cos (u - Real.pi) ≤ 0 := by
      apply Real.cos_nonpos_of_mem_Icc
      rcases hu with ⟨hu0, hu1⟩
      constructor
      · nlinarith [hu0, Real.pi_pos]
      · nlinarith [hu1, Real.pi_pos]
    have hcos : 0 ≤ Real.cos u := by
      have hcos' : Real.cos u = - Real.cos (u - Real.pi) := by
        have h := Real.cos_add_pi (u - Real.pi)
        simpa [sub_eq_add_neg, add_comm, add_left_comm, add_assoc] using h
      rw [hcos']
      linarith
    simpa [max_eq_left hcos]
  calc
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0
        = ∫ u in (0:ℝ)..(3 * Real.pi / 2), max (Real.cos u) 0
            + ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 := hsplit1
    _ = (∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0
            + ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0)
            + ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 := by
          rw [hsplit2]
    _ = (∫ u in (0:ℝ)..(Real.pi / 2), Real.cos u + 0)
            + ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), Real.cos u := by
          rw [h1, h2, h3]
    _ = 2 := by
          rw [intervalIntegral.integral_cos, intervalIntegral.integral_cos]
          simp