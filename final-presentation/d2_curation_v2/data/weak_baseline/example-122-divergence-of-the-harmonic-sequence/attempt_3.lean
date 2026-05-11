import Mathlib

open Filter

noncomputable def harmonicSeq (n : ℕ) : ℝ :=
  Finset.sum (Finset.Icc 1 n) fun k => (1 : ℝ) / (k : ℝ)

theorem harmonic_sequence_diverges :
    ¬ ∃ l : ℝ, Tendsto harmonicSeq atTop (nhds l) := by
  intro h
  rcases h with ⟨l, hl⟩
  have h1 : Tendsto (fun n : ℕ => harmonicSeq n) atTop (nhds l) := by
    simpa [harmonicSeq] using hl
  have h2 : Tendsto (fun n : ℕ => harmonicSeq n) atTop atTop := by
    suffices Tendsto (fun n : ℕ => ∑ x ∈ Finset.range n, (↑x + 1 : ℝ)⁻¹) atTop atTop by
      simpa [harmonicSeq] using this
    simpa using Real.tendsto_sum_range_one_div_nat_succ_atTop
  exact not_tendsto_nhds_of_tendsto_atTop h2 h1