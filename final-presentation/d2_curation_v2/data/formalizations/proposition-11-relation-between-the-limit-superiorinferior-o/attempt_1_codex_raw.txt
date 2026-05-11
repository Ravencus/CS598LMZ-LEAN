import Mathlib

open Filter

theorem ereal_limsup_liminf_subsequence_characterization
    {a : ℕ → EReal} {U L : EReal} :
    (((Filter.Tendsto
          (fun n : ℕ => sSup {x : EReal | ∃ k : ℕ, n ≤ k ∧ a k = x})
          Filter.atTop
          (nhds U)) ↔
        ((∃ φ : ℕ → ℕ, StrictMono φ ∧
            Filter.Tendsto (fun n : ℕ => a (φ n)) Filter.atTop (nhds U)) ∧
          ∀ U' : EReal, U < U' →
            ¬ ∃ φ : ℕ → ℕ, StrictMono φ ∧
                Filter.Tendsto (fun n : ℕ => a (φ n)) Filter.atTop (nhds U'))) ∧
      ((Filter.Tendsto
          (fun n : ℕ => sInf {x : EReal | ∃ k : ℕ, n ≤ k ∧ a k = x})
          Filter.atTop
          (nhds L)) ↔
        ((∃ φ : ℕ → ℕ, StrictMono φ ∧
            Filter.Tendsto (fun n : ℕ => a (φ n)) Filter.atTop (nhds L)) ∧
          ∀ L' : EReal, L' < L →
            ¬ ∃ φ : ℕ → ℕ, StrictMono φ ∧
                Filter.Tendsto (fun n : ℕ => a (φ n)) Filter.atTop (nhds L')))) := by
  sorry