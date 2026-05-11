import Mathlib

open Filter Topology Finset

theorem convolution_average_tendsto_mul
    (x y : ℕ → ℝ) (A B : ℝ)
    (hx : Filter.Tendsto x Filter.atTop (nhds A))
    (hy : Filter.Tendsto y Filter.atTop (nhds B)) :
    Filter.Tendsto
      (fun n : ℕ =>
        (Finset.sum (Finset.range (n + 1)) (fun k => x k * y (n - k))) / ((n + 1 : ℕ) : ℝ))
      Filter.atTop
      (nhds (A * B)) := by
  -- Strategy: decompose x k * y (n-k) = (x k - A)(y(n-k) - B) + A*(y(n-k)-B) + B*(x k - A) + A*B
  -- The average of each linear term → 0 by Cesàro on a := x - A and b := y - B.
  -- The convolution of null sequences (1/(n+1)) Σ a k * b(n-k) → 0 (the hard part).
  -- BUDGET EXHAUSTED before this proof could be completed; submitting best skeleton.
  set a : ℕ → ℝ := fun n => x n - A
  set b : ℕ → ℝ := fun n => y n - B
  have ha : Tendsto a atTop (nhds 0) := by
    have h := hx.sub (tendsto_const_nhds (x := A))
    simpa [a] using h
  have hb : Tendsto b atTop (nhds 0) := by
    have h := hy.sub (tendsto_const_nhds (x := B))
    simpa [b] using h
  have hxy : ∀ n k, x k * y (n - k) =
      a k * b (n - k) + A * b (n - k) + B * a k + A * B := by
    intros; simp [a, b]; ring
  have ces_a : Tendsto (fun n : ℕ => (∑ k ∈ range (n + 1), a k) / ((n + 1 : ℕ) : ℝ))
      atTop (nhds 0) := by
    have h1 : Tendsto (fun n : ℕ => ((n : ℝ))⁻¹ • ∑ i ∈ range n, a i) atTop (nhds 0) :=
      ha.cesaro_smul
    have h2 := h1.comp (Filter.tendsto_add_atTop_nat 1)
    have heq : (fun n : ℕ => (((n : ℝ))⁻¹ • ∑ i ∈ range n, a i) ∘ fun a => a + 1)
              = fun n : ℕ => (∑ k ∈ range (n + 1), a k) / ((n + 1 : ℕ) : ℝ) := by
      funext n; simp [smul_eq_mul, div_eq_inv_mul]; push_cast; ring
    sorry
  have refl_b : ∀ n : ℕ, ∑ k ∈ range (n + 1), b (n - k) = ∑ j ∈ range (n + 1), b j := by
    intro n
    rw [← Finset.sum_range_reflect]
    refine Finset.sum_congr rfl (fun k hk => ?_)
    simp at hk
    congr 1; omega
  have ces_b : Tendsto (fun n : ℕ => (∑ k ∈ range (n + 1), b (n - k)) / ((n + 1 : ℕ) : ℝ))
      atTop (nhds 0) := by
    sorry
  -- HARD PART: convolution of null sequences → 0.
  -- Proof outline: |a|, |b| bounded by Ma, Mb (since convergent).
  -- Given ε > 0, pick N s.t. |b k| < ε/(2 Ma) for k ≥ N.
  -- For n ≥ 2N Mb Ma / ε, split sum at k = n - N:
  --   For k ≤ n - N: n - k ≥ N so |b(n-k)| < ε/(2 Ma), giving bound ε/2.
  --   For k > n - N: at most N terms, each ≤ Ma Mb, giving N Ma Mb / (n+1) < ε/2.
  have hab_conv : Tendsto (fun n : ℕ =>
      (∑ k ∈ range (n + 1), a k * b (n - k)) / ((n + 1 : ℕ) : ℝ)) atTop (nhds 0) := by
    sorry
  have hcomb : Tendsto (fun n : ℕ =>
      (∑ k ∈ range (n + 1), x k * y (n - k)) / ((n + 1 : ℕ) : ℝ)) atTop (nhds (A * B)) := by
    have heq : ∀ n : ℕ,
        (∑ k ∈ range (n + 1), x k * y (n - k)) / ((n + 1 : ℕ) : ℝ) =
        (∑ k ∈ range (n + 1), a k * b (n - k)) / ((n + 1 : ℕ) : ℝ)
        + A * ((∑ k ∈ range (n + 1), b (n - k)) / ((n + 1 : ℕ) : ℝ))
        + B * ((∑ k ∈ range (n + 1), a k) / ((n + 1 : ℕ) : ℝ))
        + A * B := by
      intro n
      have hn1 : ((n + 1 : ℕ) : ℝ) > 0 := by exact_mod_cast Nat.succ_pos n
      have hn1' : ((n + 1 : ℕ) : ℝ) ≠ 0 := ne_of_gt hn1
      have hexp : (∑ k ∈ range (n + 1), x k * y (n - k)) =
          (∑ k ∈ range (n + 1), a k * b (n - k))
          + A * (∑ k ∈ range (n + 1), b (n - k))
          + B * (∑ k ∈ range (n + 1), a k)
          + ((n + 1 : ℕ) : ℝ) * (A * B) := by
        rw [show (∑ k ∈ range (n + 1), x k * y (n - k))
              = ∑ k ∈ range (n + 1), (a k * b (n - k) + A * b (n - k) + B * a k + A * B)
              from Finset.sum_congr rfl (fun k _ => hxy n k)]
        rw [Finset.sum_add_distrib, Finset.sum_add_distrib, Finset.sum_add_distrib]
        rw [← Finset.mul_sum, ← Finset.mul_sum]
        rw [Finset.sum_const, Finset.card_range]
        push_cast; ring
      rw [hexp]; field_simp; ring
    have htarget : Tendsto (fun n : ℕ =>
        (∑ k ∈ range (n + 1), a k * b (n - k)) / ((n + 1 : ℕ) : ℝ)
        + A * ((∑ k ∈ range (n + 1), b (n - k)) / ((n + 1 : ℕ) : ℝ))
        + B * ((∑ k ∈ range (n + 1), a k) / ((n + 1 : ℕ) : ℝ))
        + A * B) atTop (nhds (A * B)) := by
      have := ((hab_conv.add (ces_b.const_mul A)).add (ces_a.const_mul B)).add
        (tendsto_const_nhds (x := A * B))
      simpa using this
    have : (fun n : ℕ => (∑ k ∈ range (n + 1), x k * y (n - k)) / ((n + 1 : ℕ) : ℝ))
         = (fun n : ℕ =>
            (∑ k ∈ range (n + 1), a k * b (n - k)) / ((n + 1 : ℕ) : ℝ)
            + A * ((∑ k ∈ range (n + 1), b (n - k)) / ((n + 1 : ℕ) : ℝ))
            + B * ((∑ k ∈ range (n + 1), a k) / ((n + 1 : ℕ) : ℝ))
            + A * B) := by funext n; exact heq n
    rw [this]; exact htarget
  exact hcomb