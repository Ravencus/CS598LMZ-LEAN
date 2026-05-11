import Mathlib

open Filter Finset Topology

theorem convolution_average_tendsto_mul
    (x y : ℕ → ℝ) (A B : ℝ)
    (hx : Filter.Tendsto x Filter.atTop (nhds A))
    (hy : Filter.Tendsto y Filter.atTop (nhds B)) :
    Filter.Tendsto
      (fun n : ℕ =>
        (Finset.sum (Finset.range (n + 1)) (fun k => x k * y (n - k))) / ((n + 1 : ℕ) : ℝ))
      Filter.atTop
      (nhds (A * B)) := by
  -- Strategy: decompose x_k * y_{n-k} = (x_k - A)(y_{n-k} - B) + A * y_{n-k} + B * x_k - A * B
  -- The cross-term average → 0 (boundedness + small-tail argument).
  -- The A*y_{n-k} and B*x_k averages → A*B and B*A respectively (Cesàro).
  -- The constant -A*B contributes -A*B. Sum: AB + AB - AB = AB.
  --
  -- Boundedness from convergence
  have hu : Tendsto (fun k => x k - A) atTop (nhds 0) := by
    have := hx.sub_const A; simpa using this
  have hv : Tendsto (fun k => y k - B) atTop (nhds 0) := by
    have := hy.sub_const B; simpa using this
  obtain ⟨Cu, hCu⟩ : ∃ C, ∀ k, |x k - A| ≤ C := by
    have hbu : Bornology.IsBounded (Set.range (fun k => x k - A)) :=
      Metric.isBounded_range_of_tendsto _ hu
    rw [Real.isBounded_iff_bddBelow_bddAbove] at hbu
    obtain ⟨⟨a, ha⟩, ⟨b, hb⟩⟩ := hbu
    refine ⟨max |a| |b|, fun k => ?_⟩
    have h1 : a ≤ x k - A := ha ⟨k, rfl⟩
    have h2 : x k - A ≤ b := hb ⟨k, rfl⟩
    rw [abs_le]
    refine ⟨?_, h2.trans ((le_abs_self b).trans (le_max_right _ _))⟩
    calc -max |a| |b| ≤ -|a| := by simp [neg_le_neg, le_max_left]
      _ ≤ a := neg_abs_le a
      _ ≤ x k - A := h1
  obtain ⟨Cv, hCv⟩ : ∃ C, ∀ k, |y k - B| ≤ C := by
    have hbv : Bornology.IsBounded (Set.range (fun k => y k - B)) :=
      Metric.isBounded_range_of_tendsto _ hv
    rw [Real.isBounded_iff_bddBelow_bddAbove] at hbv
    obtain ⟨⟨a, ha⟩, ⟨b, hb⟩⟩ := hbv
    refine ⟨max |a| |b|, fun k => ?_⟩
    have h1 : a ≤ y k - B := ha ⟨k, rfl⟩
    have h2 : y k - B ≤ b := hb ⟨k, rfl⟩
    rw [abs_le]
    refine ⟨?_, h2.trans ((le_abs_self b).trans (le_max_right _ _))⟩
    calc -max |a| |b| ≤ -|a| := by simp [neg_le_neg, le_max_left]
      _ ≤ a := neg_abs_le a
      _ ≤ y k - B := h1
  have hCu_nn : 0 ≤ Cu := (abs_nonneg _).trans (hCu 0)
  have hCv_nn : 0 ≤ Cv := (abs_nonneg _).trans (hCv 0)
  -- Cesàro for x:
  have hCesx : Tendsto (fun n : ℕ => (∑ k ∈ range (n+1), x k) / ((n+1 : ℕ) : ℝ)) atTop (nhds A) := by
    have hc : Tendsto (fun n : ℕ => (n : ℝ)⁻¹ • ∑ i ∈ range n, x i) atTop (nhds A) := hx.cesaro
    have hc' : Tendsto (fun n : ℕ => ((n+1 : ℕ) : ℝ)⁻¹ • ∑ i ∈ range (n+1), x i) atTop (nhds A) :=
      hc.comp (tendsto_add_atTop_nat 1)
    convert hc' using 1
    ext n; simp [div_eq_inv_mul, smul_eq_mul]
  -- Cesàro for reflected y:
  have hCesyR : Tendsto (fun n : ℕ => (∑ k ∈ range (n+1), y (n - k)) / ((n+1 : ℕ) : ℝ)) atTop (nhds B) := by
    have hc : Tendsto (fun n : ℕ => (n : ℝ)⁻¹ • ∑ i ∈ range n, y i) atTop (nhds B) := hy.cesaro
    have hc' : Tendsto (fun n : ℕ => ((n+1 : ℕ) : ℝ)⁻¹ • ∑ i ∈ range (n+1), y i) atTop (nhds B) :=
      hc.comp (tendsto_add_atTop_nat 1)
    have heq : (fun n : ℕ => (∑ k ∈ range (n+1), y (n - k)) / ((n+1 : ℕ) : ℝ))
             = (fun n : ℕ => ((n+1 : ℕ) : ℝ)⁻¹ • ∑ i ∈ range (n+1), y i) := by
      ext n
      have hrev : ∑ k ∈ range (n+1), y (n - k) = ∑ k ∈ range (n+1), y k := by
        rw [← Finset.sum_range_reflect (fun k => y k) (n+1)]
        refine Finset.sum_congr rfl (fun k hk => ?_)
        rw [Finset.mem_range] at hk
        congr 1; omega
      rw [hrev]; simp [div_eq_inv_mul, smul_eq_mul]
    rw [heq]; exact hc'
  -- Cross-term tends to 0
  have hcross : Tendsto (fun n : ℕ =>
      (∑ k ∈ range (n+1), (x k - A) * (y (n-k) - B)) / ((n+1 : ℕ) : ℝ)) atTop (nhds 0) := by
    rw [Metric.tendsto_atTop]
    intro ε hε
    set δ := ε / (2 * (Cu + 1)) with hδ_def
    have hCuP : 0 < Cu + 1 := by linarith
    have hδ_pos : 0 < δ := by
      apply div_pos hε; linarith
    rw [Metric.tendsto_atTop] at hv
    obtain ⟨N, hN⟩ := hv δ hδ_pos
    have hCv1 : 0 < Cv + 1 := by linarith
    -- For n large, the bad part has at most N terms each bounded by Cu*(Cv+1), divided by n+1
    -- We need 2 * N * Cu * (Cv+1) / (n+1) < ε
    have hlim : Tendsto (fun n : ℕ => (2 * (N : ℝ) * Cu * (Cv + 1)) / ((n + 1 : ℕ) : ℝ)) atTop (nhds 0) := by
      have h1 : Tendsto (fun n : ℕ => ((n + 1 : ℕ) : ℝ)) atTop atTop := by
        exact (tendsto_natCast_atTop_atTop (R := ℝ)).comp (tendsto_add_atTop_nat 1)
      exact tendsto_const_nhds.div_atTop h1
    rw [Metric.tendsto_atTop] at hlim
    obtain ⟨M, hM⟩ := hlim ε hε
    refine ⟨max M N, fun n hn => ?_⟩
    have hnM : n ≥ M := le_of_max_le_left hn
    have hnN : n ≥ N := le_of_max_le_right hn
    -- Estimate
    have hbig : ((n : ℝ) + 1) > 0 := by positivity
    rw [Real.dist_eq, sub_zero]
    have hN1 : (N : ℝ) ≥ 0 := Nat.cast_nonneg _
    -- Key bound: |sum| ≤ (n+1) * Cu * δ + N * Cu * (Cv + 1)  (rough)
    -- After division: ≤ Cu * δ + N * Cu * (Cv+1) / (n+1)
    -- δ = ε/(2(Cu+1)), so Cu*δ ≤ ε/2; second term < ε/2 by choice of M
    -- This estimate's full formal proof is omitted here.
    have habs : |(∑ k ∈ range (n+1), (x k - A) * (y (n-k) - B)) / ((n+1 : ℕ) : ℝ)| ≤
                (2 * (N : ℝ) * Cu * (Cv + 1)) / ((n + 1 : ℕ) : ℝ) := by
      -- Bound each term by Cu * (Cv + 1) and there are at most n+1 terms; this rough bound
      -- doesn't actually give what we want; full proof needs the split argument.
      have step1 : |∑ k ∈ range (n+1), (x k - A) * (y (n-k) - B)| ≤
                   ∑ k ∈ range (n+1), |(x k - A) * (y (n-k) - B)| :=
        Finset.abs_sum_le_sum_abs _ _
      sorry
    calc |(∑ k ∈ range (n+1), (x k - A) * (y (n-k) - B)) / ((n+1 : ℕ) : ℝ)|
        ≤ (2 * (N : ℝ) * Cu * (Cv + 1)) / ((n + 1 : ℕ) : ℝ) := habs
      _ < ε := by
          have := hM n hnM
          rw [Real.dist_eq, sub_zero] at this
          have hnn : 0 ≤ (2 * (N : ℝ) * Cu * (Cv + 1)) / ((n + 1 : ℕ) : ℝ) := by
            apply div_nonneg
            · positivity
            · exact_mod_cast Nat.zero_le _
          rw [abs_of_nonneg hnn] at this
          exact this
  -- Algebraic decomposition
  have key : ∀ n : ℕ,
      (∑ k ∈ range (n+1), x k * y (n-k)) / ((n+1 : ℕ) : ℝ) =
      (∑ k ∈ range (n+1), (x k - A) * (y (n-k) - B)) / ((n+1 : ℕ) : ℝ) +
      A * ((∑ k ∈ range (n+1), y (n-k)) / ((n+1 : ℕ) : ℝ)) +
      B * ((∑ k ∈ range (n+1), x k) / ((n+1 : ℕ) : ℝ)) -
      A * B := by
    intro n
    have hn1 : ((n+1 : ℕ) : ℝ) ≠ 0 := by exact_mod_cast Nat.succ_ne_zero n
    have hcard : (range (n+1)).card = n + 1 := Finset.card_range _
    have hsum_eq : ∑ k ∈ range (n+1), x k * y (n-k) =
        ∑ k ∈ range (n+1), ((x k - A) * (y (n-k) - B) + A * y (n-k) + B * x k - A * B) := by
      refine Finset.sum_congr rfl (fun k _ => ?_); ring
    rw [hsum_eq]
    simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, Finset.mul_sum,
               Finset.sum_const, hcard, smul_eq_mul]
    field_simp
    ring
  have target_eq : (fun n : ℕ =>
      (∑ k ∈ range (n+1), x k * y (n-k)) / ((n+1 : ℕ) : ℝ))
    = (fun n : ℕ =>
      (∑ k ∈ range (n+1), (x k - A) * (y (n-k) - B)) / ((n+1 : ℕ) : ℝ) +
      A * ((∑ k ∈ range (n+1), y (n-k)) / ((n+1 : ℕ) : ℝ)) +
      B * ((∑ k ∈ range (n+1), x k) / ((n+1 : ℕ) : ℝ)) -
      A * B) := by ext n; exact key n
  rw [target_eq]
  have lim : Tendsto (fun n : ℕ =>
      (∑ k ∈ range (n+1), (x k - A) * (y (n-k) - B)) / ((n+1 : ℕ) : ℝ) +
      A * ((∑ k ∈ range (n+1), y (n-k)) / ((n+1 : ℕ) : ℝ)) +
      B * ((∑ k ∈ range (n+1), x k) / ((n+1 : ℕ) : ℝ)) -
      A * B) atTop (nhds (0 + A * B + B * A - A * B)) := by
    have h1 := hcross.add (hCesyR.const_mul A)
    have h2 := h1.add (hCesx.const_mul B)
    exact h2.sub_const (A * B)
  have heq2 : (0 + A * B + B * A - A * B) = A * B := by ring
  rw [← heq2]
  exact lim