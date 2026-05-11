import Mathlib

theorem sum_sin_div_nsq_tendsto_half :
    Filter.Tendsto
      (fun n : ℕ => Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2)))
      Filter.atTop
      (nhds ((1 : ℝ) / 2)) := by
  refine Metric.tendsto_nhds.2 ?_
  intro ε hε
  obtain ⟨N, hN⟩ := exists_nat_gt (max 1 (2 / ε))
  refine Filter.eventually_atTop.2 ?_
  refine ⟨N, ?_⟩
  intro n hn
  have hN1 : 1 < (N : ℝ) := lt_of_le_of_lt (le_max_left _ _) hN
  have hN2 : 2 / ε < (N : ℝ) := lt_of_le_of_lt (le_max_right _ _) hN
  have hn1nat : 1 ≤ n := by
    have : (1 : ℕ) < N := by exact_mod_cast hN1
    omega
  have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn1nat
  have hpos : (0 : ℝ) < n := by linarith
  have hsum :
      Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2)
        = ((n : ℝ) * (n + 1 : ℝ)) / (2 * (n : ℝ) ^ 2) := by
    have hsumk : Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ)) = ((n : ℝ) * (n + 1 : ℝ)) / 2 := by
      have hnat : ∑ k ∈ Finset.range (n + 1), k = n * (n + 1) / 2 := by
        simpa [Nat.succ_eq_add_one, Nat.add_comm, Nat.add_left_comm, Nat.add_assoc, Nat.mul_comm,
          Nat.mul_left_comm, Nat.mul_assoc] using (Finset.sum_range_id (n + 1))
      exact_mod_cast hnat
    calc
      Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2)
          = Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) * ((n : ℝ) ^ 2)⁻¹) := by
              simp [div_eq_mul_inv]
      _ = (Finset.sum (Finset.range (n + 1)) (fun k : ℕ => (k : ℝ))) * ((n : ℝ) ^ 2)⁻¹ := by
              rw [Finset.sum_mul]
      _ = ((n : ℝ) * (n + 1 : ℝ)) / (2 * (n : ℝ) ^ 2) := by
              rw [hsumk]
              ring
  have hterm :
      |Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
          - Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2)|
        ≤ (1 : ℝ) / (n + 1 : ℝ) := by
    have h1 :
        |Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
            - Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2)|
          ≤ Finset.sum (Finset.range (n + 1))
              (fun k => |Real.sin ((k : ℝ) / (n : ℝ) ^ 2) - (k : ℝ) / (n : ℝ) ^ 2|) := by
      have hsumsub :
          Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
            - Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2)
          = Finset.sum (Finset.range (n + 1))
              (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2) - (k : ℝ) / (n : ℝ) ^ 2) := by
        rw [Finset.sum_sub_distrib]
      simpa [hsumsub, sub_eq_add_neg, add_comm, add_left_comm, add_assoc] using
        (Finset.abs_sum_le_sum_abs
          (fun k : ℕ => -(k : ℝ) / (n : ℝ) ^ 2 + Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
          (Finset.range (n + 1)))
    have h2 :
        Finset.sum (Finset.range (n + 1))
          (fun k => |Real.sin ((k : ℝ) / (n : ℝ) ^ 2) - (k : ℝ) / (n : ℝ) ^ 2|)
        ≤ (n + 1 : ℝ) / (6 * (n : ℝ) ^ 3) := by
      have hsumterm :
          Finset.sum (Finset.range (n + 1))
            (fun k => |Real.sin ((k : ℝ) / (n : ℝ) ^ 2) - (k : ℝ) / (n : ℝ) ^ 2|)
          ≤ Finset.sum (Finset.range (n + 1)) (fun _ : ℕ => (1 : ℝ) / (6 * (n : ℝ) ^ 3)) := by
        refine Finset.sum_le_sum ?_
        intro k hk
        have hk_le : (k : ℝ) ≤ n := by
          have hk_lt : k < n + 1 := Finset.mem_range.mp hk
          exact_mod_cast (Nat.le_of_lt_succ hk_lt)
        have hk1 : (k : ℝ) / n ≤ n := by
          nlinarith [hk_le, hn1]
        have hrew : (k : ℝ) / (n : ℝ) ^ 2 = ((k : ℝ) / n) / n := by
          field_simp [hpos.ne']
          ring
        have hnonneg : 0 ≤ (k : ℝ) / (n : ℝ) ^ 2 := by positivity
        have hupper : (k : ℝ) / (n : ℝ) ^ 2 ≤ 1 := by
          rw [hrew]
          rw [div_le_iff₀ hpos]
          simpa using hk1
        have hsinle : Real.sin ((k : ℝ) / (n : ℝ) ^ 2) ≤ (k : ℝ) / (n : ℝ) ^ 2 :=
          Real.sin_le hnonneg
        have hlower :
            (k : ℝ) / (n : ℝ) ^ 2 - ((k : ℝ) / (n : ℝ) ^ 2) ^ 3 / 4 <
              Real.sin ((k : ℝ) / (n : ℝ) ^ 2) := by
          have hposx : 0 < (k : ℝ) / (n : ℝ) ^ 2 := by
            by_cases hk0 : k = 0
            · subst hk0; simp
            · have hkpos : 0 < (k : ℝ) := by exact_mod_cast Nat.pos_of_ne_zero hk0
              positivity
          have := Real.sin_gt_sub_cube hposx hupper
          nlinarith
        have habs :
            |Real.sin ((k : ℝ) / (n : ℝ) ^ 2) - (k : ℝ) / (n : ℝ) ^ 2|
              = (k : ℝ) / (n : ℝ) ^ 2 - Real.sin ((k : ℝ) / (n : ℝ) ^ 2) := by
          rw [abs_of_nonpos]
          · ring
          · linarith
        have hpow : ((k : ℝ) / (n : ℝ) ^ 2) ^ 3 ≤ (1 : ℝ) / (n : ℝ) ^ 3 := by
          nlinarith [hkupper, hnonneg]
        have hterm' :
            |Real.sin ((k : ℝ) / (n : ℝ) ^ 2) - (k : ℝ) / (n : ℝ) ^ 2|
              ≤ (1 : ℝ) / (6 * (n : ℝ) ^ 3) := by
          rw [habs]
          nlinarith [hlower, hsinle, hpow]
        exact hterm'
      simpa [Finset.sum_const, nsmul_eq_mul, div_eq_mul_inv, mul_comm, mul_left_comm, mul_assoc]
        using hsumterm
    have hbound : (n + 1 : ℝ) / (6 * (n : ℝ) ^ 3) ≤ (1 : ℝ) / (n + 1 : ℝ) := by
      have hn2 : (1 : ℝ) ≤ n := by exact_mod_cast hn1nat
      have hpos1 : 0 < (6 * (n : ℝ) ^ 3) := by positivity
      have hpos2 : 0 < (n : ℝ) + 1 := by positivity
      rw [div_le_div_iff₀ hpos1 hpos2]
      nlinarith [hn2]
    exact le_trans h2 hbound
  have hhalf :
      |Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2) - ((1 : ℝ) / 2)|
        = (1 : ℝ) / (2 * (n : ℝ)) := by
    rw [hsum]
    have hsub : ((n : ℝ) * (n + 1 : ℝ)) / (2 * (n : ℝ) ^ 2) - (1 : ℝ) / 2 = (1 : ℝ) / (2 * (n : ℝ)) := by
      field_simp [hpos.ne']
      ring
    have hnonneg : 0 ≤ ((n : ℝ) * (n + 1 : ℝ)) / (2 * (n : ℝ) ^ 2) - (1 : ℝ) / 2 := by
      rw [hsub]
      positivity
    rw [abs_of_nonneg hnonneg, hsub]
  have hdist :
      |Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
          - ((1 : ℝ) / 2)|
        ≤ (2 : ℝ) / (n + 1 : ℝ) := by
    have htri :
        |Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
            - ((1 : ℝ) / 2)|
        ≤ |Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
            - Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2)|
          + |Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2) - ((1 : ℝ) / 2)| := by
      exact abs_sub_le _ _ _
    have hsumle :
        |Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
            - ((1 : ℝ) / 2)|
        ≤ (1 : ℝ) / (n + 1 : ℝ) + (1 : ℝ) / (2 * (n : ℝ)) := by
      nlinarith [htri, hterm, hhalf]
    have hhalf_le : (1 : ℝ) / (2 * (n : ℝ)) ≤ (1 : ℝ) / (n + 1 : ℝ) := by
      rw [le_div_iff₀ (by positivity)]
      nlinarith [hn1]
    have hsumle' :
        (1 : ℝ) / (n + 1 : ℝ) + (1 : ℝ) / (2 * (n : ℝ)) ≤ (2 : ℝ) / (n + 1 : ℝ) := by
      have htmp : (1 : ℝ) / (n + 1 : ℝ) + (1 : ℝ) / (2 * (n : ℝ)) ≤
          (1 : ℝ) / (n + 1 : ℝ) + (1 : ℝ) / (n + 1 : ℝ) := by
        linarith [hhalf_le]
      simpa [two_mul, add_comm, add_left_comm, add_assoc] using htmp
    exact le_trans hsumle hsumle'
  have hlt : (2 : ℝ) / (n + 1 : ℝ) < ε := by
    have hnN : (N : ℝ) ≤ n := by exact_mod_cast hn
    have h2lt : (2 : ℝ) / ε < n + 1 := by
      have : (2 : ℝ) / ε < n := lt_of_lt_of_le hN2 hnN
      nlinarith
    have hposden : 0 < (n : ℝ) + 1 := by positivity
    have hmul : 2 < ε * ((n : ℝ) + 1) := by
      have htmp := mul_lt_mul_of_pos_left h2lt hε
      field_simp [hε.ne'] at htmp
      linarith
    rw [div_lt_iff₀ hposden]
    exact hmul
  have :
      |Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
        - ((1 : ℝ) / 2)| < ε := by
    exact lt_of_le_of_lt hdist hlt
  simpa [Real.dist_eq] using this
