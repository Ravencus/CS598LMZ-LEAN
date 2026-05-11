import Mathlib

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  have h0 : (0:ℝ) ≤ Real.pi / 2 := by positivity
  have h1 : Real.pi / 2 ≤ 3 * Real.pi / 2 := by
    nlinarith [Real.pi_pos]
  have h2 : 3 * Real.pi / 2 ≤ 2 * Real.pi := by
    nlinarith [Real.pi_pos]
  calc
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0
        = (∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0)
          + (∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0)
          + (∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0) := by
            rw [← intervalIntegral.integral_add_adjacent_intervals
                (a := (0:ℝ)) (b := Real.pi / 2) (c := 3 * Real.pi / 2),
              ← intervalIntegral.integral_add_adjacent_intervals
                (a := (0:ℝ)) (b := 3 * Real.pi / 2) (c := 2 * Real.pi)]
            abel
    _ = (∫ u in (0:ℝ)..(Real.pi / 2), Real.cos u)
          + 0
          + (∫ u in (3 * Real.pi / 2)..(2 * Real.pi), Real.cos u) := by
            congr 2
            · apply intervalIntegral.integral_congr
              intro u hu
              exact max_eq_left (Real.cos_nonneg_of_mem_Icc ⟨by linarith [hu.1], by linarith [hu.2]⟩)
            · apply intervalIntegral.integral_eq_zero_of_forall_eq_zero
              intro u hu
              exact max_eq_right (Real.cos_nonpos_of_mem_Icc ⟨by linarith [hu.1], by linarith [hu.2]⟩)
            · apply intervalIntegral.integral_congr
              intro u hu
              have hnonneg : 0 ≤ Real.cos (u - 2 * Real.pi) :=
                Real.cos_nonneg_of_mem_Icc ⟨by linarith [hu.1], by linarith [hu.2]⟩
              simpa [Real.cos_sub_two_pi] using hnonneg
    _ = 2 := by
      simp [intervalIntegral.integral_cos]
      ring