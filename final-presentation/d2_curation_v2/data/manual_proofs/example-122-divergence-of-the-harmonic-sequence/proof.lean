import Mathlib

open Filter

noncomputable def harmonicSeq (n : ℕ) : ℝ :=
  Finset.sum (Finset.Icc 1 n) fun k => (1 : ℝ) / (k : ℝ)

theorem harmonic_sequence_diverges :
    ¬ ∃ l : ℝ, Tendsto harmonicSeq atTop (nhds l) := by
  -- Strategy: harmonicSeq tends to atTop, so it can't tend to a finite l.
  -- Mathlib has `Real.tendsto_sum_range_one_div_nat_succ_atTop` for `∑ i ∈ range n, 1/(i+1)`.
  -- Need to bridge our `Finset.Icc 1 n` form to `Finset.range n` form.
  intro ⟨l, hl⟩
  -- Show harmonicSeq tends to atTop
  have htop : Tendsto harmonicSeq atTop atTop := by
    -- Use the fact that ∑ k in Icc 1 n, 1/k = ∑ k in range n, 1/(k+1)
    have heq : ∀ n, harmonicSeq n = ∑ k ∈ Finset.range n, (1 : ℝ) / (k + 1) := by
      intro n
      unfold harmonicSeq
      induction n with
      | zero => simp
      | succ n ih =>
        rw [Finset.sum_Icc_succ_top (by omega : 1 ≤ n + 1)]
        rw [Finset.sum_range_succ]
        rw [ih]
        push_cast
        ring
    have hfunc : harmonicSeq = (fun n => ∑ k ∈ Finset.range n, (1 : ℝ) / (k + 1)) := funext heq
    rw [hfunc]
    exact Real.tendsto_sum_range_one_div_nat_succ_atTop
  -- Now derive contradiction from `Tendsto _ atTop atTop` and `Tendsto _ atTop (nhds l)`
  exact not_tendsto_nhds_of_tendsto_atTop htop l hl
