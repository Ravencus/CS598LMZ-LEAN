import Mathlib

open MeasureTheory

def counterexampleFn (n : ℕ) (x : ℝ) : ℝ :=
  (x + 1 / (n + 1 : ℝ)) ^ 2

theorem pointwiseButNotInMeasure_counterexample :
    (∀ x : ℝ,
      Filter.Tendsto (fun n : ℕ => counterexampleFn n x) Filter.atTop (nhds (x ^ 2))) ∧
    (∀ φ : ℕ → ℕ, StrictMono φ →
      ∀ x : ℝ,
        Filter.Tendsto (fun n : ℕ => counterexampleFn (φ n) x) Filter.atTop (nhds (x ^ 2))) ∧
    (∃ ε : ℝ, 0 < ε ∧
      ∀ n : ℕ, volume {x : ℝ | ε ≤ |counterexampleFn n x - x ^ 2|} = ⊤) ∧
    ¬ (∀ ε : ℝ, 0 < ε →
      Filter.Tendsto
        (fun n : ℕ => volume {x : ℝ | ε ≤ |counterexampleFn n x - x ^ 2|})
        Filter.atTop
        (nhds (0 : ℝ≥0∞))) := by
  sorry