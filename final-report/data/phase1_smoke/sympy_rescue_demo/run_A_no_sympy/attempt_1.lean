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
        = ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0
          + ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0
          + ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 := by
            rw [intervalIntegral.integral_add_adjacent_intervals h0]
            rw [intervalIntegral.integral_add_adjacent_intervals h1]
            ring
    _ = ∫ u in (0:ℝ)..(Real.pi / 2), Real.cos u
          + ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), 0
          + ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), Real.cos u := by
            congr 2
            · apply intervalIntegral.integral_congr
              intro u hu
              rw [max_eq_left]
              exact Real.cos_nonneg_of_mem_Icc ⟨hu.1, hu.2⟩
            · apply intervalIntegral.integral_congr
              intro u hu
              rw [max_eq_right]
              exact Real.cos_nonpos_of_mem_Icc ⟨hu.1, hu.2⟩
            · apply intervalIntegral.integral_congr
              intro u hu
              rw [max_eq_left]
              have hs : Real.sin (u - 3 * Real.pi / 2) ≤ 0 := by
                have hmem : u - 3 * Real.pi / 2 ∈ Set.Icc 0 (Real.pi / 2) := by
                  constructor <;> linarith
                have hcos := Real.cos_nonneg_of_mem_Icc hmem
                simpa [Real.cos_sub, Real.cos_three_mul_pi_div_two, Real.sin_three_mul_pi_div_two,
                  zero_mul, neg_mul, sub_eq_add_neg, add_comm, add_left_comm, add_assoc] using hcos
              have hcos : Real.cos u = Real.sin (u - 3 * Real.pi / 2) := by
                rw [← Real.sin_add_pi_div_two]
                congr 1
                ring
              rw [hcos]
              exact hs
    _ = (Real.sin (Real.pi / 2) - Real.sin 0)
          + 0
          + (Real.sin (2 * Real.pi) - Real.sin (3 * Real.pi / 2)) := by
            simp
    _ = 2 := by
            simp [Real.sin_two_pi, Real.sin_three_mul_pi_div_two]