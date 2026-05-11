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
  classical
  have hx0 : Filter.Tendsto (fun n : ℕ => x n - A) Filter.atTop (nhds 0) := by
    simpa using hx.sub_const A
  have hy0 : Filter.Tendsto (fun n : ℕ => y n - B) Filter.atTop (nhds 0) := by
    simpa using hy.sub_const B
  have hxb : ∃ C : ℝ, 0 ≤ C ∧ ∀ n, |x n - A| ≤ C := by
    have h_event : ∀ᶠ n in Filter.atTop, |x n - A| ≤ 1 := by
      simpa [Real.dist_eq, abs_sub_comm, sub_eq_add_neg] using
        (Metric.tendsto_nhds.mp hx0) 1 (by norm_num)
    rcases (Filter.eventually_atTop.1 h_event) with ⟨N, hN⟩
    refine ⟨max 1 ((Finset.range N).sup' (if hN0 : (Finset.range N).Nonempty then hN0 else by simp at hN0) fun n => |x n - A|), ?_, ?_⟩
    · exact le_max_left _ _
    · intro n
      by_cases hn : n < N
      · have hnmem : n ∈ Finset.range N := Finset.mem_range.2 hn
        exact le_trans (Finset.le_sup' _ n hnmem) (le_max_right _ _)
      · exact le_trans (hN n (le_of_not_gt hn)) (le_max_left _ _)
  rcases hxb with ⟨C, hC0, hC⟩
  have h_cesaro_x :
      Filter.Tendsto
        (fun n : ℕ => (Finset.sum (Finset.range (n + 1)) (fun k => x k - A)) / ((n + 1 : ℕ) : ℝ))
        Filter.atTop (nhds 0) := by
    simpa using hx0.cesaro
  have h_cesaro_y :
      Filter.Tendsto
        (fun n : ℕ => (Finset.sum (Finset.range (n + 1)) (fun k => y k - B)) / ((n + 1 : ℕ) : ℝ))
        Filter.atTop (nhds 0) := by
    simpa using hy0.cesaro
  have h_cesaro_y_rev :
      Filter.Tendsto
        (fun n : ℕ => (Finset.sum (Finset.range (n + 1)) (fun k => y (n - k) - B)) / ((n + 1 : ℕ) : ℝ))
        Filter.atTop (nhds 0) := by
    convert h_cesaro_y using 1
    ext n
    congr 1
    refine Finset.sum_bij (fun k _ => n - k) ?_ ?_ ?_ ?_
    · intro k hk
      exact Finset.mem_range.2 (Nat.lt_succ_iff.2 (Nat.sub_le n k))
    · intro a _ b _ hab
      omega
    · intro k hk
      refine ⟨n - k, Finset.mem_range.2 (Nat.lt_succ_iff.2 (Nat.sub_le n k)), ?_⟩
      have hk' : k ≤ n := Nat.lt_succ_iff.1 (Finset.mem_range.1 hk)
      simp [Nat.sub_sub_self hk']
    · intro k hk
      have hk' : k ≤ n := Nat.lt_succ_iff.1 (Finset.mem_range.1 hk)
      simp [Nat.sub_sub_self hk']
  have h_prod0 :
      Filter.Tendsto
        (fun n : ℕ =>
          (Finset.sum (Finset.range (n + 1)) (fun k => (x k - A) * (y (n - k) - B))) /
            ((n + 1 : ℕ) : ℝ))
        Filter.atTop (nhds 0) := by
    rw [Metric.tendsto_nhds]
    intro eps heps
    have hCeps : 0 < eps / (C + 1) := by positivity
    have h_event : ∀ᶠ n in Filter.atTop, |y n - B| < eps / (C + 1) := by
      simpa [Real.dist_eq, abs_sub_comm, sub_eq_add_neg] using
        (Metric.tendsto_nhds.mp hy0) (eps / (C + 1)) hCeps
    rcases (Filter.eventually_atTop.1 h_event) with ⟨N, hN⟩
    refine Filter.eventually_atTop.2 ⟨N, ?_⟩
    intro n hn
    have hden : 0 < ((n + 1 : ℕ) : ℝ) := by positivity
    have h_abs_sum :
        |Finset.sum (Finset.range (n + 1)) (fun k => (x k - A) * (y (n - k) - B))|
          ≤ Finset.sum (Finset.range (n + 1)) (fun k => C * (eps / (C + 1))) := by
      refine le_trans (abs_sum_le_sum_abs _ _) (Finset.sum_le_sum ?_)
      intro k hk
      have hkx : |x k - A| ≤ C := hC k
      have hky : |y (n - k) - B| < eps / (C + 1) := by
        exact hN (n - k) (by omega)
      calc
        |(x k - A) * (y (n - k) - B)| = |x k - A| * |y (n - k) - B| := abs_mul _ _
        _ ≤ C * (eps / (C + 1)) := by
          exact mul_le_mul hkx (le_of_lt hky) (abs_nonneg _) hC0
    have hmain :
        |(Finset.sum (Finset.range (n + 1)) (fun k => (x k - A) * (y (n - k) - B))) /
            ((n + 1 : ℕ) : ℝ)|
          ≤ C * (eps / (C + 1)) := by
      rw [abs_div]
      calc
        |Finset.sum (Finset.range (n + 1)) (fun k => (x k - A) * (y (n - k) - B))| /
            |((n + 1 : ℕ) : ℝ)|
            ≤ (Finset.sum (Finset.range (n + 1)) (fun k => C * (eps / (C + 1)))) /
                ((n + 1 : ℕ) : ℝ) := by
              rw [abs_of_pos hden]
              exact div_le_div_of_nonneg_right h_abs_sum (le_of_lt hden)
        _ = C * (eps / (C + 1)) := by
          simp [hden.ne']
    have hlt : C * (eps / (C + 1)) < eps := by
      have hpos : 0 < C + 1 := by positivity
      nlinarith [hC0, div_mul_cancel₀ eps (ne_of_gt hpos)]
    simpa [Real.dist_eq, sub_zero] using lt_of_le_of_lt hmain hlt
  have hsum :
      Filter.Tendsto
        (fun n : ℕ =>
          ((Finset.sum (Finset.range (n + 1)) (fun k => (x k - A) * (y (n - k) - B))) /
              ((n + 1 : ℕ) : ℝ)) +
            A *
              ((Finset.sum (Finset.range (n + 1)) (fun k => y (n - k) - B)) /
                ((n + 1 : ℕ) : ℝ)) +
            B *
              ((Finset.sum (Finset.range (n + 1)) (fun k => x k - A)) /
                ((n + 1 : ℕ) : ℝ)))
        Filter.atTop (nhds (0 + A * 0 + B * 0)) := by
    exact (h_prod0.add (h_cesaro_y_rev.const_mul A)).add (h_cesaro_x.const_mul B)
  convert hsum using 1
  · ext n
    field_simp
    rw [← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
    congr 1
    ext k
    ring
  · ring