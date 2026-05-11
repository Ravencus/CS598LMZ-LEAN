import Mathlib

lemma cesaro_shift (u : ℕ → ℝ) (L : ℝ)
    (hu : Filter.Tendsto u Filter.atTop (nhds L)) :
    Filter.Tendsto
      (fun n : ℕ => (Finset.sum (Finset.range (n + 1)) (fun k => u k)) / ((n + 1 : ℕ) : ℝ))
      Filter.atTop (nhds L) := by
  have h : Filter.Tendsto (fun n : ℕ => ((n : ℝ)⁻¹ * Finset.sum (Finset.range n) (fun k => u k))) Filter.atTop (nhds L) :=
    Filter.Tendsto.cesaro hu
  have hcomp := h.comp (Filter.tendsto_add_atTop_nat 1)
  simpa [Function.comp_def, div_eq_mul_inv, mul_comm, mul_left_comm, mul_assoc, Nat.cast_add, Nat.cast_one] using hcomp
