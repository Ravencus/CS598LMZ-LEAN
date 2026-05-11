import Mathlib

theorem convolution_average_tendsto_mul
    (x y : ℕ → ℝ) (A B : ℝ)
    (hx : Filter.Tendsto x Filter.atTop (nhds A))
    (hy : Filter.Tendsto y Filter.atTop (nhds B)) :
    Filter.Tendsto
      (fun n : ℕ =>
        (Finset.sum (Finset.range (n + 1)) (fun k => x k * y (n - k))) / ((n + 1 : ℕ) : ℝ))
      Filter.atTop
      (nhds (A * B)) := by
  let u : ℕ → ℝ := fun n => x n - A
  let v : ℕ → ℝ := fun n => y n - B
  have hconstA : Filter.Tendsto (fun _ : ℕ => A) Filter.atTop (nhds A) := tendsto_const_nhds
  have hconstB : Filter.Tendsto (fun _ : ℕ => B) Filter.atTop (nhds B) := tendsto_const_nhds
  have hu : Filter.Tendsto u Filter.atTop (nhds 0) := by
    simpa [u, sub_eq_add_neg] using hx.sub hconstA
  have hv : Filter.Tendsto v Filter.atTop (nhds 0) := by
    simpa [v, sub_eq_add_neg] using hy.sub hconstB
  have hu_avg :
      Filter.Tendsto
        (fun n : ℕ => (Finset.sum (Finset.range (n + 1)) (fun k => u k)) / ((n + 1 : ℕ) : ℝ))
        Filter.atTop
        (nhds 0) := by
    have h := hu.cesaro.comp (Filter.tendsto_add_atTop_nat 1)
    change Filter.Tendsto
      (fun n : ℕ => ((n + 1 : ℕ) : ℝ)⁻¹ * Finset.sum (Finset.range (n + 1)) (fun k => u k))
      Filter.atTop
      (nhds 0) at h
    simpa [u, div_eq_mul_inv, mul_comm] using h
  have hv_avg :
      Filter.Tendsto
        (fun n : ℕ => (Finset.sum (Finset.range (n + 1)) (fun k => v (n - k))) / ((n + 1 : ℕ) : ℝ))
        Filter.atTop
        (nhds 0) := by
    have h := hv.cesaro.comp (Filter.tendsto_add_atTop_nat 1)
    change Filter.Tendsto
      (fun n : ℕ => ((n + 1 : ℕ) : ℝ)⁻¹ * Finset.sum (Finset.range (n + 1)) (fun k => v k))
      Filter.atTop
      (nhds 0) at h
    simpa [v, div_eq_mul_inv, mul_comm, Finset.sum_range_reflect] using h
  have hMuBdd : BddAbove (Set.range (fun n => ‖u n‖)) := (hu.norm).bddAbove_range
  have hMvBdd : BddAbove (Set.range (fun n => ‖v n‖)) := (hv.norm).bddAbove_range
  rcases hMuBdd with ⟨Mu, hMu⟩
  rcases hMvBdd with ⟨Mv, hMv⟩
  have hMu_nonneg : 0 ≤ Mu := by
    have h := hMu (show ‖u 0‖ ∈ Set.range (fun n => ‖u n‖) from ⟨0, rfl⟩)
    exact le_trans (abs_nonneg (u 0)) h
  have hMv_nonneg : 0 ≤ Mv := by
    have h := hMv (show ‖v 0‖ ∈ Set.range (fun n => ‖v n‖) from ⟨0, rfl⟩)
    exact le_trans (abs_nonneg (v 0)) h
  have hcross :
      Filter.Tendsto
        (fun n : ℕ =>
          (Finset.sum (Finset.range (n + 1)) (fun k => u k * v (n - k))) / ((n + 1 : ℕ) : ℝ))
        Filter.atTop
        (nhds 0) := by
    refine Metric.tendsto_nhds.2 ?_
    intro ε hε
    let δ : ℝ := ε / (2 * (Mu + Mv + 1))
    have hδpos : 0 < δ := by
      dsimp [δ]
      positivity
    have hu_small : ∀ᶠ n in Filter.atTop, ‖u n‖ < δ :=
      (hu.norm.eventually_lt tendsto_const_nhds (show ‖(0 : ℝ)‖ < δ by simpa using hδpos))
    have hv_small : ∀ᶠ n in Filter.atTop, ‖v n‖ < δ :=
      (hv.norm.eventually_lt tendsto_const_nhds (show ‖(0 : ℝ)‖ < δ by simpa using hδpos))
    have hsmall : ∀ᶠ n in Filter.atTop, ‖u n‖ < δ ∧ ‖v n‖ < δ := hu_small.and hv_small
    rcases Filter.eventually_atTop.1 hsmall with ⟨N, hN⟩
    have hNbig : ∀ᶠ n in Filter.atTop, N ≤ n := Filter.eventually_ge_atTop N
    filter_upwards [hNbig] with n hn
    have hNle_n1 : N ≤ n + 1 := by omega
    let p1 : ℝ := Finset.sum (Finset.range N) (fun k => u k * v (n - k))
    let q : ℝ := Finset.sum (Finset.range (n + 1 - N)) (fun k => u (N + k) * v (n - (N + k)))
    have hdecomp :
        (Finset.sum (Finset.range (n + 1)) (fun k => u k * v (n - k))) = p1 + q := by
      subst p1 q
      rw [show n + 1 = N + (n + 1 - N) by omega, Finset.sum_range_add]
    have hp1 : |p1| ≤ N * Mu * δ := by
      subst p1
      calc
        |∑ k ∈ Finset.range N, u k * v (n - k)| ≤ ∑ k ∈ Finset.range N, |u k * v (n - k)| := by
          simpa using (Finset.abs_sum_le_sum_abs (s := Finset.range N) (f := fun k => u k * v (n - k)))
        _ ≤ ∑ k ∈ Finset.range N, Mu * δ := by
          refine Finset.sum_le_sum ?_
          intro k hk
          have hkN : k < N := Finset.mem_range.1 hk
          have hku : ‖u k‖ ≤ Mu := hMu (show ‖u k‖ ∈ Set.range (fun n => ‖u n‖) from ⟨k, rfl⟩)
          have hnv : N ≤ n - k := by omega
          have hvk : ‖v (n - k)‖ < δ := (hN (n - k) hnv).2
          have hterm : |u k * v (n - k)| ≤ Mu * δ := by
            simp [abs_mul]
            gcongr
            · exact hku
            · exact le_of_lt hvk
          exact hterm
        _ = N * Mu * δ := by
          simp [mul_assoc, mul_left_comm, mul_comm]
    have hq : |q| ≤ (n + 1 - N) * (δ * Mv) := by
      subst q
      calc
        |∑ k ∈ Finset.range (n + 1 - N), u (N + k) * v (n - (N + k))| ≤
            ∑ k ∈ Finset.range (n + 1 - N), |u (N + k) * v (n - (N + k))| := by
          simpa using (Finset.abs_sum_le_sum_abs
            (s := Finset.range (n + 1 - N))
            (f := fun k => u (N + k) * v (n - (N + k))))
        _ ≤ ∑ k ∈ Finset.range (n + 1 - N), δ * Mv := by
          refine Finset.sum_le_sum ?_
          intro k hk
          have hnu : N ≤ N + k := by omega
          have huk : ‖u (N + k)‖ < δ := (hN (N + k) hnu).1
          have hmvk : ‖v (n - (N + k))‖ ≤ Mv := hMv (show ‖v (n - (N + k))‖ ∈ Set.range (fun n => ‖v n‖) from ⟨n - (N + k), rfl⟩)
          have hterm : |u (N + k) * v (n - (N + k))| ≤ δ * Mv := by
            simp [abs_mul]
            gcongr
            · exact le_of_lt huk
            · exact hmvk
          exact hterm
        _ = (n + 1 - N) * (δ * Mv) := by
          simp [mul_assoc, mul_left_comm, mul_comm]
    have hsumabs :
        |Finset.sum (Finset.range (n + 1)) (fun k => u k * v (n - k))| ≤
          N * Mu * δ + (n + 1 - N) * (δ * Mv) := by
      rw [hdecomp]
      have htri : |p1 + q| ≤ |p1| + |q| := by
        simpa using abs_add_le p1 q
      nlinarith [htri, hp1, hq]
    have hsumavg :
        |Finset.sum (Finset.range (n + 1)) (fun k => u k * v (n - k))| /
            ((n + 1 : ℕ) : ℝ) ≤ Mu * δ + Mv * δ := by
      have hpos : 0 < ((n + 1 : ℕ) : ℝ) := by positivity
      have hbound :
          |Finset.sum (Finset.range (n + 1)) (fun k => u k * v (n - k))| ≤
            ((n + 1 : ℕ) : ℝ) * (Mu * δ + Mv * δ) := by
        field_simp [hpos.ne']
        nlinarith [hsumabs, hNle_n1, hMu_nonneg, hMv_nonneg, le_of_lt hδpos]
      exact (le_div_iff₀ hpos).2 hbound
    have hfinal :
        |Finset.sum (Finset.range (n + 1)) (fun k => u k * v (n - k))| /
            ((n + 1 : ℕ) : ℝ) < ε := by
      have hCpos : 0 < (2 * (Mu + Mv + 1) : ℝ) := by
        nlinarith [hMu_nonneg, hMv_nonneg]
      have hmul : (Mu * δ + Mv * δ) < ε := by
        dsimp [δ]
        have htmp : (Mu + Mv) * (ε / (2 * (Mu + Mv + 1))) < ε := by
          field_simp [hCpos.ne']
          nlinarith [hMu_nonneg, hMv_nonneg]
        simpa [mul_add, add_mul, add_comm, add_left_comm, add_assoc, mul_comm, mul_left_comm,
          mul_assoc] using htmp
      exact lt_of_le_of_lt hsumavg hmul
    simpa [Real.norm_eq_abs] using hfinal
  have hAB : Filter.Tendsto (fun _ : ℕ => (A * B : ℝ)) Filter.atTop (nhds (A * B)) := tendsto_const_nhds
  have hcombo :
      Filter.Tendsto
        (fun n : ℕ =>
          (A * B : ℝ) +
            B * ((Finset.sum (Finset.range (n + 1)) (fun k => u k)) / ((n + 1 : ℕ) : ℝ)) +
            A * ((Finset.sum (Finset.range (n + 1)) (fun k => v (n - k))) / ((n + 1 : ℕ) : ℝ)) +
            (Finset.sum (Finset.range (n + 1)) (fun k => u k * v (n - k))) / ((n + 1 : ℕ) : ℝ))
        Filter.atTop
        (nhds (A * B)) := by
    simpa [add_assoc, add_left_comm, add_comm] using
      hAB.add ((hu_avg.mul_const B).add ((hv_avg.const_mul A).add hcross))
  have hrewrite :
      (fun n : ℕ =>
        (Finset.sum (Finset.range (n + 1)) (fun k => x k * y (n - k))) / ((n + 1 : ℕ) : ℝ)) =
      (fun n : ℕ =>
        (A * B : ℝ) +
          B * ((Finset.sum (Finset.range (n + 1)) (fun k => u k)) / ((n + 1 : ℕ) : ℝ)) +
          A * ((Finset.sum (Finset.range (n + 1)) (fun k => v (n - k))) / ((n + 1 : ℕ) : ℝ)) +
          (Finset.sum (Finset.range (n + 1)) (fun k => u k * v (n - k))) / ((n + 1 : ℕ) : ℝ)) := by
    funext n
    subst u v
    simp [sub_eq_add_neg, mul_add, Finset.sum_add_distrib, add_assoc, add_left_comm,
      add_comm, mul_comm]
  simpa [hrewrite] using hcombo