import Mathlib

def HasPositiveNatDensity (s : Set ℕ) : Prop := by
  classical
  exact
    ∃ δ : ℝ,
      0 < δ ∧
        Filter.Tendsto
          (fun N : ℕ => ((Finset.card ((Finset.range N).filter fun n => n ∈ s) : ℕ) : ℝ) / (N : ℝ))
          Filter.atTop
          (nhds δ)

theorem min_series_diverges_of_positive_density
    (α β : ℕ → ℝ)
    (hα_nonneg : ∀ n, 0 ≤ α n)
    (hβ_nonneg : ∀ n, 0 ≤ β n)
    (hα_antitone : Antitone α)
    (hβ_antitone : Antitone β)
    (hα_div : ¬ Summable (fun n : ℕ => α (n + 1)))
    (hβ_div : ¬ Summable (fun n : ℕ => β (n + 1)))
    (hcomp :
      ∃ C : ℝ,
        0 < C ∧
          HasPositiveNatDensity {n : ℕ | C * β (n + 1) ≤ α (n + 1)}) :
    ¬ Summable (fun n : ℕ => min (α (n + 1)) (β (n + 1))) := by
  sorry