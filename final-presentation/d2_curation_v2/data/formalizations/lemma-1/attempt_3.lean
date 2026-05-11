import Mathlib

theorem ae_Tn_div_n_sub_Sn_div_n_tendsto_zero
    {Ω : Type*} [MeasurableSpace Ω] {μ : MeasureTheory.Measure Ω}
    (Y S T : ℕ → Ω → ℝ)
    (hT : ∀ n, T n = fun ω => Finset.sum (Finset.range (n + 1)) (fun i => Y i ω)) :
    ∀ᵐ ω ∂μ, Filter.Tendsto
      (fun n : ℕ => T n ω / (n : ℝ) - S n ω / (n : ℝ))
      Filter.atTop
      (nhds 0) := by
  sorry