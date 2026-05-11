import Mathlib

open Filter

noncomputable def harmonicSeq (n : ℕ) : ℝ :=
  Finset.sum (Finset.Icc 1 n) fun k => (1 : ℝ) / (k : ℝ)

theorem harmonic_sequence_diverges :
    ¬ ∃ l : ℝ, Tendsto harmonicSeq atTop (nhds l) := by
  intro h
  rcases h with ⟨l, hl⟩
  have hEq : harmonicSeq = fun n : ℕ => ∑ x ∈ Finset.range n, (↑x + 1 : ℝ)⁻¹ := by
    funext n
    rw [harmonicSeq]
    simpa using (Finset.sum_Icc_succ_top (f := fun k : ℕ => (1 : ℝ) / (k : ℝ)) (n := n))
  have h1 : Tendsto (fun n : ℕ => ∑ x ∈ Finset.range n, (↑x + 1 : ℝ)⁻¹) atTop (nhds l) := by
    simpa [hEq] using hl
  have h2 : Tendsto (fun n : ℕ => ∑ x ∈ Finset.range n, (↑x + 1 : ℝ)⁻¹) atTop atTop := by
    simpa using Real.tendsto_sum_range_one_div_nat_succ_atTop
  exact not_tendsto_nhds_of_tendsto_atTop h2 l h1