import Mathlib

open MeasureTheory Filter

theorem bernoulliOneOverN_convergenceInProbability_not_ae
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (X : ℕ → Ω → ℝ)
    (h_meas : ∀ n : ℕ, Measurable (X n))
    (h_prob_one :
      ∀ n : ℕ, μ {ω | X (n + 1) ω = 1} = ENNReal.ofReal (1 / (n + 1 : ℝ)))
    (h_prob_zero :
      ∀ n : ℕ, μ {ω | X (n + 1) ω = 0} = 1 - ENNReal.ofReal (1 / (n + 1 : ℝ))) :
    (∀ ⦃ε : ℝ⦄, 0 < ε → ε < 1 →
      Filter.Tendsto
        (fun n : ℕ => μ {ω | ε ≤ |X (n + 1) ω|})
        Filter.atTop
        (nhds (0 : ℝ≥0∞))) ∧
    (¬ Summable (fun n : ℕ => ENNReal.ofReal (1 / (n + 1 : ℝ)))) ∧
    (∀ᵐ ω ∂μ, Set.Infinite {n : ℕ | X (n + 1) ω = 1}) ∧
    ¬ (∀ᵐ ω ∂μ, Filter.Tendsto (fun n : ℕ => X (n + 1) ω) Filter.atTop (nhds 0)) := by
  sorry