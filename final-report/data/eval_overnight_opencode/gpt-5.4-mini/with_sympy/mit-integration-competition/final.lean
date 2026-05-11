import Mathlib

noncomputable def cantorFloorSeries (x : ℝ) : ℝ :=
  ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1))

theorem integral_sq_cantorFloorSeries :
    ∫ x in (0 : ℝ)..1, (cantorFloorSeries x) ^ 2 = (27 : ℝ) / 32 := by
  classical
  let f : ℝ → ℝ := cantorFloorSeries
  have hgeom : Summable (fun n : ℕ => ((2 : ℝ) / 3) ^ n) := by
    simpa using (summable_geometric_of_norm_lt_one (x := (2 : ℝ) / 3) (by norm_num : ‖(2 : ℝ) / 3‖ < 1))
  have hgeom' : Summable (fun n : ℕ => ((2 : ℝ) / 3) ^ (n + 1)) := by
    simpa [pow_succ, mul_comm, mul_left_comm, mul_assoc] using (hgeom.mul_left ((2 : ℝ) / 3))
  have hterm_meas : ∀ n : ℕ, Measurable fun x : ℝ => (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1)) := by
    intro n
    have hfloor : Measurable fun x : ℝ => (⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) := by
      simpa using (Int.measurable_floor.comp (by simpa using (measurable_const.mul measurable_id : Measurable fun x : ℝ => (2 : ℝ) ^ (n + 1) * x)))
    have hcast : Measurable fun z : ℤ => (z : ℝ) := by
      exact measurable_of_countable _
    have hreal : Measurable fun x : ℝ => (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ)) := hcast.comp hfloor
    simpa using hreal.div_const ((3 : ℝ) ^ (n + 1))
  have hmeas : Measurable f := by
    have hnn : Measurable fun x : ℝ =>
        ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ≥0)) := by
      refine Measurable.nnreal_tsum ?_
      intro n
      have hfloor : Measurable fun x : ℝ => (⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) := by
        simpa using (Int.measurable_floor.comp (by simpa using (measurable_const.mul measurable_id : Measurable fun x : ℝ => (2 : ℝ) ^ (n + 1) * x)))
      have hcast : Measurable fun z : ℤ => (z : ℝ≥0) := by
        exact measurable_of_countable _
      exact hcast.comp hfloor
    have hcoe : (fun x : ℝ => ((∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ≥0))) : ℝ)) = f := by
      funext x
      simp [f, cantorFloorSeries, NNReal.coe_tsum_of_nonneg, Nat.succ_eq_add_one]
    simpa [f] using hnn.comp measurable_coe
  have hbound_term : ∀ x ∈ Set.Icc (0 : ℝ) 1, ∀ n : ℕ,
      (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1)) ≤ ((2 : ℝ) / 3) ^ (n + 1) := by
    intro x hx n
    have hx1 : x ≤ 1 := hx.2
    have hfloor1 : ((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) ≤ (2 : ℝ) ^ (n + 1) * x := by
      exact Int.floor_le _
    have hmul : (2 : ℝ) ^ (n + 1) * x ≤ (2 : ℝ) ^ (n + 1) := by
      gcongr
    have hle : ((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) ≤ (2 : ℝ) ^ (n + 1) := le_trans hfloor1 hmul
    have hdiv : (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1)) ≤ ((2 : ℝ) ^ (n + 1) / (3 : ℝ) ^ (n + 1)) := by
      exact div_le_div_of_nonneg_right hle (pow_nonneg (by positivity) _)
    simpa [div_pow, div_eq_mul_inv, mul_comm, mul_left_comm, mul_assoc] using hdiv
  have hsum_term : ∀ x ∈ Set.Icc (0 : ℝ) 1,
      Summable (fun n : ℕ => (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1))) := by
    intro x hx
    exact Summable.of_nonneg_of_le (hterm_meas _).nonneg (hbound_term x hx) hgeom'
  have hbound : ∀ x ∈ Set.Icc (0 : ℝ) 1, |f x| ≤ 2 := by
    intro x hx
    have hs := hsum_term x hx
    have hle : f x ≤ ∑' n : ℕ, ((2 : ℝ) / 3) ^ (n + 1) := by
      simpa [f, cantorFloorSeries] using hs.tsum_le_tsum (hbound_term x hx)
    have hgeo : ∑' n : ℕ, ((2 : ℝ) / 3) ^ (n + 1) = 2 := by
      calc
        ∑' n : ℕ, ((2 : ℝ) / 3) ^ (n + 1) = ((2 : ℝ) / 3) * ∑' n : ℕ, ((2 : ℝ) / 3) ^ n := by
          simpa [pow_succ, mul_comm, mul_left_comm, mul_assoc] using (hgeom.tsum_mul_left ((2 : ℝ) / 3))
        _ = 2 := by
          rw [tsum_geometric_of_norm_lt_one (by norm_num : ‖(2 : ℝ) / 3‖ < 1)]
          norm_num
    have hnonneg : 0 ≤ f x := by
      simpa [f, cantorFloorSeries] using tsum_nonneg (fun n => by
        have := hterm_meas n
        positivity)
    have hle2 : f x ≤ 2 := by
      linarith
    exact abs_of_nonneg hnonneg ▸ hle2
  have h_int_f : IntervalIntegrable f volume 0 1 := by
    rw [intervalIntegrable_iff_integrableOn_Icc_of_le (by norm_num : (0 : ℝ) ≤ 1)]
    exact (Integrable.of_bound hmeas.aestronglyMeasurable 2 (ae_of_all _ fun x hx => hbound x hx))
  have h_int_f_sq : IntervalIntegrable (fun x => (f x)^2) volume 0 1 := by
    have hmeas_sq : Measurable (fun x : ℝ => (f x) ^ 2) := hmeas.pow 2
    rw [intervalIntegrable_iff_integrableOn_Icc_of_le (by norm_num : (0 : ℝ) ≤ 1)]
    refine (Integrable.of_bound hmeas_sq.aestronglyMeasurable 4 ?_)
    refine ae_of_all _ ?_
    intro x hx
    have hx' := hbound x hx
    nlinarith [sq_nonneg (f x), hx']
  have h_left : ∫ x in (0 : ℝ)..(1 / 2), f x = (1 / 6 : ℝ) * ∫ x in (0 : ℝ)..1, f x := by
    have hrec : ∀ x ∈ Set.Icc (0 : ℝ) (1 / 2), f x = f (2 * x) / 3 := by
      intro x hx
      have hxlt : x < 1 / 2 := lt_of_le_of_ne hx.1 (by linarith)
      have hsum : Summable (fun n : ℕ => (((⌊(2 : ℝ) ^ n * (2 * x)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n)) := by
        have hbound2 : ∀ n : ℕ, (((⌊(2 : ℝ) ^ n * (2 * x)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n) ≤ ((2 : ℝ) / 3) ^ n := by
          intro n
          have hfloor1 : ((⌊(2 : ℝ) ^ n * (2 * x)⌋ : ℤ) : ℝ) ≤ (2 : ℝ) ^ n * (2 * x) := by
            exact Int.floor_le _
          have hmul : (2 : ℝ) ^ n * (2 * x) ≤ (2 : ℝ) ^ n := by
            gcongr
            linarith
          have hle : ((⌊(2 : ℝ) ^ n * (2 * x)⌋ : ℤ) : ℝ) ≤ (2 : ℝ) ^ n := le_trans hfloor1 hmul
          have hdiv : (((⌊(2 : ℝ) ^ n * (2 * x)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n) ≤ ((2 : ℝ) ^ n / (3 : ℝ) ^ n) := by
            exact div_le_div_of_nonneg_right hle (pow_nonneg (by positivity) _)
          simpa [div_pow, div_eq_mul_inv, mul_comm, mul_left_comm, mul_assoc] using hdiv
        exact Summable.of_nonneg_of_le (by intro n; positivity) hbound2 hgeom
      have h0 : (((⌊(2 : ℝ) ^ 0 * (2 * x)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ 0) = 0 := by
        simp [hxlt.ne']
      have hts : ∑' n : ℕ, (((⌊(2 : ℝ) ^ n * (2 * x)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n) = ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * (2 * x)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1)) := by
        rw [hsum.tsum_eq_zero_add]
        simp [h0]
      have hmul : ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1)) =
          (1 / 3 : ℝ) * ∑' n : ℕ, (((⌊(2 : ℝ) ^ n * (2 * x)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n) := by
        calc
          ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1))
              = ∑' n : ℕ, (((⌊(2 : ℝ) ^ n * (2 * x)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1)) := by
                congr with n
                ring
          _ = (1 / 3 : ℝ) * ∑' n : ℕ, (((⌊(2 : ℝ) ^ n * (2 * x)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n) := by
                rw [← hts]
                simp [mul_comm, mul_left_comm, mul_assoc, hsum.tsum_mul_left (1 / 3 : ℝ)]
      simpa [f, cantorFloorSeries] using hmul
    have h_int1 : IntervalIntegrable (fun x => f x) volume 0 (1 / 2) := by
      rw [intervalIntegrable_iff_integrableOn_Icc_of_le (by norm_num : (0 : ℝ) ≤ 1 / 2)]
      exact (Integrable.of_bound hmeas.aestronglyMeasurable 2 (ae_of_all _ fun x hx => hbound x (by linarith)))
    have h_comp : ∫ x in (0 : ℝ)..(1 / 2), f x = ∫ x in (0 : ℝ)..(1 / 2), f (2 * x) / 3 := by
      apply intervalIntegral.integral_congr_ae
      exact (ae_restrict_iff' measurableSet_Icc).2 <| ae_of_all _ fun x hx => hrec x hx
    calc
      ∫ x in (0 : ℝ)..(1 / 2), f x = ∫ x in (0 : ℝ)..(1 / 2), f (2 * x) / 3 := h_comp
      _ = (1 / 3 : ℝ) * ∫ x in (0 : ℝ)..1, f x := by
        rw [intervalIntegral.integral_comp_mul_left]
        ring
  have h_right : ∫ x in (1 / 2 : ℝ)..1, f x = (1 / 2 : ℝ) + (1 / 6 : ℝ) * ∫ x in (0 : ℝ)..1, f x := by
    have hrec : ∀ x ∈ Set.Icc (1 / 2 : ℝ) 1, f x = 1 + f (2 * x - 1) / 3 := by
      intro x hx
      have hxlt : x < 1 := by linarith
      have hy0 : 0 ≤ 2 * x - 1 := by linarith
      have hy1 : 2 * x - 1 < 1 := by linarith
      have hsum : Summable (fun n : ℕ => (((⌊(2 : ℝ) ^ n * (2 * x - 1)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n)) := by
        have hbound2 : ∀ n : ℕ, (((⌊(2 : ℝ) ^ n * (2 * x - 1)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n) ≤ ((2 : ℝ) / 3) ^ n := by
          intro n
          have hfloor1 : ((⌊(2 : ℝ) ^ n * (2 * x - 1)⌋ : ℤ) : ℝ) ≤ (2 : ℝ) ^ n * (2 * x - 1) := by
            exact Int.floor_le _
          have hmul : (2 : ℝ) ^ n * (2 * x - 1) ≤ (2 : ℝ) ^ n := by
            gcongr
            linarith
          have hle : ((⌊(2 : ℝ) ^ n * (2 * x - 1)⌋ : ℤ) : ℝ) ≤ (2 : ℝ) ^ n := le_trans hfloor1 hmul
          have hdiv : (((⌊(2 : ℝ) ^ n * (2 * x - 1)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n) ≤ ((2 : ℝ) ^ n / (3 : ℝ) ^ n) := by
            exact div_le_div_of_nonneg_right hle (pow_nonneg (by positivity) _)
          simpa [div_pow, div_eq_mul_inv, mul_comm, mul_left_comm, mul_assoc] using hdiv
        exact Summable.of_nonneg_of_le (by intro n; positivity) hbound2 hgeom
      have h0 : (((⌊(2 : ℝ) ^ 0 * (2 * x - 1)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ 0) = 0 := by
        simp [hy0, hy1]
      have hts : ∑' n : ℕ, (((⌊(2 : ℝ) ^ n * (2 * x - 1)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n) = ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * (2 * x - 1)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1)) := by
        rw [hsum.tsum_eq_zero_add]
        simp [h0]
      have hmul : ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1)) =
          1 + (1 / 3 : ℝ) * ∑' n : ℕ, (((⌊(2 : ℝ) ^ n * (2 * x - 1)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n) := by
        calc
          ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1))
              = ∑' n : ℕ, (((2 : ℝ) ^ n) / (3 : ℝ) ^ (n + 1)) + ∑' n : ℕ, (((⌊(2 : ℝ) ^ n * (2 * x - 1)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1)) := by
                simp [sub_eq_add_neg, add_comm, add_left_comm, add_assoc, pow_succ, mul_add, left_distrib, right_distrib]
          _ = 1 + (1 / 3 : ℝ) * ∑' n : ℕ, (((⌊(2 : ℝ) ^ n * (2 * x - 1)⌋ : ℤ) : ℝ) / (3 : ℝ) ^ n) := by
                have hgeom2 : ∑' n : ℕ, (((2 : ℝ) ^ n) / (3 : ℝ) ^ (n + 1)) = 1 := by
                  calc
                    ∑' n : ℕ, (((2 : ℝ) ^ n) / (3 : ℝ) ^ (n + 1)) = (1 / 3 : ℝ) * ∑' n : ℕ, ((2 : ℝ) / 3) ^ n := by
                      simp [div_pow, pow_succ, mul_comm, mul_left_comm, mul_assoc]
                    _ = 1 := by
                      rw [tsum_geometric_of_norm_lt_one (by norm_num : ‖(2 : ℝ) / 3‖ < 1)]
                      norm_num
                rw [hgeom2]
                rw [← hts]
                simp [mul_comm, mul_left_comm, mul_assoc, hsum.tsum_mul_left (1 / 3 : ℝ)]
      simpa [f, cantorFloorSeries] using hmul
    have h_comp : ∫ x in (1 / 2 : ℝ)..1, f x = ∫ x in (1 / 2 : ℝ)..1, 1 + f (2 * x - 1) / 3 := by
      apply intervalIntegral.integral_congr_ae
      exact (ae_restrict_iff' measurableSet_Icc).2 <| ae_of_all _ fun x hx => hrec x hx
    calc
      ∫ x in (1 / 2 : ℝ)..1, f x = ∫ x in (1 / 2 : ℝ)..1, 1 + f (2 * x - 1) / 3 := h_comp
      _ = (1 / 2 : ℝ) + (1 / 6 : ℝ) * ∫ x in (0 : ℝ)..1, f x := by
        rw [intervalIntegral.integral_add, intervalIntegral.integral_const, intervalIntegral.integral_comp_sub_right]
        ring
  have hM : ∫ x in (0 : ℝ)..1, f x = (3 : ℝ) / 4 := by
    have hsplit := intervalIntegral.integral_add_adjacent_intervals (f := f) h_int_f.restrict (by
      -- placeholder
      sorry)
    sorry
  have hI : ∫ x in (0 : ℝ)..1, (f x) ^ 2 = (27 : ℝ) / 32 := by
    sorry
  simpa [f] using hI
