import Mathlib

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  have h1 : ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0 = 1 := by
    calc
      ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0
          = ∫ u in (0:ℝ)..(Real.pi / 2), Real.cos u := by
              exact intervalIntegral.integral_congr (by
                intro u hu
                have hmem : 0 ≤ u ∧ u ≤ Real.pi / 2 := by
                  have h' := hu
                  simp at h'
                  exact h'
                simpa using (max_eq_left (by
                  have hIcc : u ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) := by
                    constructor
                    · linarith
                    · exact hmem.2
                  exact Real.cos_nonneg_of_mem_Icc hIcc)))
      _ = 1 := by simpa using (integral_cos (0:ℝ) (Real.pi / 2))
  have h2 : ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0 = 0 := by
    calc
      ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0
          = ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), (0 : ℝ) := by
              exact intervalIntegral.integral_congr (by
                intro u hu
                have hmem : Real.pi / 2 ≤ u ∧ u ≤ 3 * Real.pi / 2 := by
                  have h' := hu
                  simp at h'
                  exact h'
                simpa using (max_eq_right (by
                  have hIcc : (u - Real.pi) ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) := by
                    constructor <;> linarith
                  have hnonneg : 0 ≤ Real.cos (u - Real.pi) := Real.cos_nonneg_of_mem_Icc hIcc
                  have hle : Real.cos u ≤ 0 := by
                    have := hnonneg
                    rw [Real.cos_sub_pi] at this
                    linarith
                  exact hle)))
      _ = 0 := by simp
  have h3 : ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 = 1 := by
    calc
      ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0
          = ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), Real.cos u := by
              exact intervalIntegral.integral_congr (by
                intro u hu
                have hmem : 3 * Real.pi / 2 ≤ u ∧ u ≤ 2 * Real.pi := by
                  have h' := hu
                  simp at h'
                  exact h'
                simpa using (max_eq_left (by
                  have hIcc : (u - 2 * Real.pi) ∈ Set.Icc (-(Real.pi / 2)) (Real.pi / 2) := by
                    constructor <;> linarith
                  exact Real.cos_nonneg_of_mem_Icc hIcc)))
      _ = 1 := by simpa using (integral_cos (3 * Real.pi / 2) (2 * Real.pi))
  have hsum :
      ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 =
        ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0
          + ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0
          + ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 := by
    rw [intervalIntegral.integral_add_adjacent_intervals,
      intervalIntegral.integral_add_adjacent_intervals]
  nlinarith [hsum, h1, h2, h3]