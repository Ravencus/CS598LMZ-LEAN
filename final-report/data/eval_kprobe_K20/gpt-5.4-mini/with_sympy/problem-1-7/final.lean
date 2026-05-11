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

  have hsum2 :
      (Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ))) * 2
        = (n + 1 : ℝ) * n := by
    exact_mod_cast (Finset.sum_range_id_mul_two (n + 1))

  have hsum :
      Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ))
        = ((n : ℝ) * (n + 1 : ℝ)) / 2 := by
    nlinarith [hsum2]

  have hterm :
      |Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
          - Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2)|
        ≤ (1 : ℝ) / (n + 1 : ℝ) := by
    have h1 :
        |Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
            - Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2)|
          ≤ Finset.sum (Finset.range (n + 1))
              (fun k => |Real.sin ((k : ℝ) / (n : ℝ) ^ 2) - (k : ℝ) / (n : ℝ) ^ 2|) := by
      simpa [Finset.sum_sub_distrib, abs_sub_comm] using
        (Finset.abs_sum_le_sum_abs
          (f := fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2) - (k : ℝ) / (n : ℝ) ^ 2)
          (s := Finset.range (n + 1)))
    have h2 :
        Finset.sum (Finset.range (n + 1))
          (fun k => |Real.sin ((k : ℝ) / (n : ℝ) ^ 2) - (k : ℝ) / (n : ℝ) ^ 2|)
        ≤ (n + 1 : ℝ) / (6 * (n : ℝ) ^ 3) := by
      have h2' :
          Finset.sum (Finset.range (n + 1))
            (fun k => |Real.sin ((k : ℝ) / (n : ℝ) ^ 2) - (k : ℝ) / (n : ℝ) ^ 2|)
          ≤ Finset.sum (Finset.range (n + 1))
              (fun _ => (1 : ℝ) / (6 * (n : ℝ) ^ 3)) := by
        refine Finset.sum_le_sum ?_
        intro k hk
        have hk_le : (k : ℝ) ≤ n := by
          have hk_lt : k < n + 1 := Finset.mem_range.mp hk
          omega
        have hsq : (0 : ℝ) < (n : ℝ) ^ 2 := by positivity
        have hk' : (k : ℝ) / (n : ℝ) ^ 2 ≤ (1 : ℝ) / n := by
          have hdiv := div_le_div_right₀ hsq hk_le
          nlinarith
        have hnonneg : 0 ≤ (k : ℝ) / (n : ℝ) ^ 2 := by positivity
        have hpow :
            ((k : ℝ) / (n : ℝ) ^ 2) ^ 3 ≤ (1 : ℝ) / (n : ℝ) ^ 3 := by
          exact pow_le_pow_right₀ hnonneg hk'
        have hsin :
            |Real.sin ((k : ℝ) / (n : ℝ) ^ 2) - (k : ℝ) / (n : ℝ) ^ 2|
              ≤ ((k : ℝ) / (n : ℝ) ^ 2) ^ 3 / 6 := by
          simpa [abs_sub_comm] using
            (Real.abs_sub_sin_le ((k : ℝ) / (n : ℝ) ^ 2))
        nlinarith
      simpa using h2'
    have haux : (n + 1 : ℝ) / (6 * (n : ℝ) ^ 3) ≤ (1 : ℝ) / (n + 1 : ℝ) := by
      nlinarith [hn1]
    exact le_trans h2 haux

  have hhalf :
      |Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2) - ((1 : ℝ) / 2)|
        = (1 : ℝ) / (2 * (n : ℝ)) := by
    have hsum' :
        Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2)
          = ((n : ℝ) * (n + 1 : ℝ)) / (2 * (n : ℝ) ^ 2) := by
      have hnz : (n : ℝ) ^ 2 ≠ 0 := by positivity
      rw [show (fun k : ℕ => (k : ℝ) / (n : ℝ) ^ 2) =
          fun k => (k : ℝ) * ((n : ℝ) ^ 2)⁻¹ by
            funext k
            field_simp [pow_two]]
      rw [Finset.sum_mul, Finset.sum_range_id]
      field_simp [hnz]
      ring
    have hdiff :
        Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2) - ((1 : ℝ) / 2)
          = (1 : ℝ) / (2 * (n : ℝ)) := by
      nlinarith [hsum']
    have hnonneg :
        0 ≤ Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2) - ((1 : ℝ) / 2) := by
      nlinarith [hdiff, hn1]
    rw [abs_of_nonneg hnonneg]
    exact hdiff

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
    have hhalf' :
        |Finset.sum (Finset.range (n + 1)) (fun k => (k : ℝ) / (n : ℝ) ^ 2) - ((1 : ℝ) / 2)|
          ≤ (1 : ℝ) / (2 * (n : ℝ)) := by
      rw [hhalf]
      positivity
    nlinarith [htri, hterm, hhalf']

  have hlt : (2 : ℝ) / (n + 1 : ℝ) < ε := by
    have h2lt : (2 : ℝ) / ε < (n : ℝ) + 1 := by
      have hnN : (N : ℝ) ≤ n := by exact_mod_cast hn
      have : (2 : ℝ) / ε < (n : ℝ) := lt_of_lt_of_le hN2 hnN
      nlinarith
    have hposden : (0 : ℝ) < (n : ℝ) + 1 := by positivity
    rw [div_lt_iff₀ hposden]
    nlinarith [h2lt, hε]

  have :
      |Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2))
        - ((1 : ℝ) / 2)| < ε := by
    exact lt_of_le_of_lt hdist hlt
  simpa [Real.dist_eq] using this