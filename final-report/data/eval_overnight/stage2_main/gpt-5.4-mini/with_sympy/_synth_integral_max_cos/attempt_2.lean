import Mathlib

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  have hcont : Continuous fun u : ℝ => max (Real.cos u) 0 := by
    simpa using (Real.continuous_cos.max continuous_const)

  have hI1 : IntervalIntegrable (fun u : ℝ => max (Real.cos u) 0) Measure.volume (0:ℝ) (Real.pi / 2) :=
    hcont.intervalIntegrable
  have hI2 : IntervalIntegrable (fun u : ℝ => max (Real.cos u) 0) Measure.volume (Real.pi / 2) (3 * Real.pi / 2) :=
    hcont.intervalIntegrable
  have hI3 : IntervalIntegrable (fun u : ℝ => max (Real.cos u) 0) Measure.volume (3 * Real.pi / 2) (2 * Real.pi) :=
    hcont.intervalIntegrable
  have hI4 : IntervalIntegrable (fun u : ℝ => max (Real.cos u) 0) Measure.volume (Real.pi / 2) (2 * Real.pi) :=
    hcont.intervalIntegrable

  have h1 : ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0 = 1 := by
    have hnonneg : ∀ u ∈ Set.uIcc (0:ℝ) (Real.pi / 2), 0 ≤ Real.cos u := by
      intro u hu
      have hu' : u ∈ Set.Icc (0:ℝ) (Real.pi / 2) := by
        simpa [Set.uIcc_of_le (by nlinarith [Real.pi_pos])] using hu
      exact Real.cos_nonneg_of_mem_Icc hu'
    calc
      ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0
          = ∫ u in (0:ℝ)..(Real.pi / 2), Real.cos u := by
              apply intervalIntegral.integral_congr
              intro u hu
              exact max_eq_left (hnonneg u hu)
      _ = 1 := by
          simpa using (intervalIntegral.integral_cos (0:ℝ) (Real.pi / 2))

  have h2 : ∫ u in (Real.pi / 2:ℝ)..(3 * Real.pi / 2), max (Real.cos u) 0 = 0 := by
    have hnonpos : ∀ u ∈ Set.uIcc (Real.pi / 2:ℝ) (3 * Real.pi / 2), Real.cos u ≤ 0 := by
      intro u hu
      have hu' : u ∈ Set.Icc (Real.pi / 2:ℝ) (3 * Real.pi / 2) := by
        simpa [Set.uIcc_of_le (by nlinarith [Real.pi_pos])] using hu
      have hshift : u - Real.pi ∈ Set.Icc (-(Real.pi / 2 : ℝ)) (Real.pi / 2) := by
        constructor <;> linarith [hu'.1, hu'.2]
      have hnonneg : 0 ≤ Real.cos (u - Real.pi) :=
        Real.cos_nonneg_of_mem_Icc hshift
      have hcos : Real.cos u = - Real.cos (u - Real.pi) := by
        simpa [sub_eq_add_neg, add_comm, add_left_comm, add_assoc] using
          (Real.cos_add_pi (u - Real.pi))
      linarith
    calc
      ∫ u in (Real.pi / 2:ℝ)..(3 * Real.pi / 2), max (Real.cos u) 0
          = ∫ u in (Real.pi / 2:ℝ)..(3 * Real.pi / 2), (0:ℝ) := by
              apply intervalIntegral.integral_congr
              intro u hu
              exact max_eq_right (hnonpos u hu)
      _ = 0 := by simp

  have h3 : ∫ u in (3 * Real.pi / 2:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 1 := by
    have hnonneg : ∀ u ∈ Set.uIcc (3 * Real.pi / 2:ℝ) (2 * Real.pi), 0 ≤ Real.cos u := by
      intro u hu
      have hu' : u ∈ Set.Icc (3 * Real.pi / 2:ℝ) (2 * Real.pi) := by
        simpa [Set.uIcc_of_le (by nlinarith [Real.pi_pos])] using hu
      have hshift : u - 2 * Real.pi ∈ Set.Icc (-(Real.pi / 2 : ℝ)) (Real.pi / 2) := by
        constructor <;> linarith [hu'.1, hu'.2]
      have hnonneg' : 0 ≤ Real.cos (u - 2 * Real.pi) :=
        Real.cos_nonneg_of_mem_Icc hshift
      have hper : Real.cos u = Real.cos (u - 2 * Real.pi) := by
        simpa [sub_eq_add_neg, add_comm, add_left_comm, add_assoc] using
          (Real.cos_add_two_pi (u - 2 * Real.pi))
      rw [hper]
      exact hnonneg'
    calc
      ∫ u in (3 * Real.pi / 2:ℝ)..(2 * Real.pi), max (Real.cos u) 0
          = ∫ u in (3 * Real.pi / 2:ℝ)..(2 * Real.pi), Real.cos u := by
              apply intervalIntegral.integral_congr
              intro u hu
              exact max_eq_left (hnonneg u hu)
      _ = 1 := by
          simpa using (intervalIntegral.integral_cos (3 * Real.pi / 2) (2 * Real.pi))

  have hsplit1 :
      ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 =
        ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0 +
          ∫ u in (Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 := by
    rw [← intervalIntegral.integral_add_adjacent hI1 hI4]

  have hsplit2 :
      ∫ u in (Real.pi / 2:ℝ)..(2 * Real.pi), max (Real.cos u) 0 =
        ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0 +
          ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 := by
    rw [← intervalIntegral.integral_add_adjacent hI2 hI3]

  calc
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0
        = ∫ u in (0:ℝ)..(Real.pi / 2), max (Real.cos u) 0 +
            ∫ u in (Real.pi / 2)..(3 * Real.pi / 2), max (Real.cos u) 0 +
            ∫ u in (3 * Real.pi / 2)..(2 * Real.pi), max (Real.cos u) 0 := by
              rw [hsplit1, hsplit2]
    _ = 1 + 0 + 1 := by
      rw [h1, h2, h3]
    _ = 2 := by norm_num