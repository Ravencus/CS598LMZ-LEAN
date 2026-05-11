import Mathlib

open MeasureTheory

noncomputable def counterexampleFn (n : ℕ) (x : ℝ) : ℝ :=
  (x + 1 / ((n : ℝ) + 1)) ^ 2

theorem pointwiseButNotInMeasure_counterexample :
    (∀ x : ℝ,
      Filter.Tendsto (fun n : ℕ => counterexampleFn n x) Filter.atTop (Filter.nhds (x ^ 2))) ∧
    (∀ φ : ℕ → ℕ, StrictMono φ →
      ∀ x : ℝ,
        Filter.Tendsto (fun n : ℕ => counterexampleFn (φ n) x) Filter.atTop (Filter.nhds (x ^ 2))) ∧
    (∃ ε : ℝ, 0 < ε ∧
      ∀ n : ℕ,
        volume {x : ℝ | ε ≤ abs (counterexampleFn n x - x ^ 2)} = (∞ : ℝ≥0∞)) ∧
    ¬ (∀ ε : ℝ, 0 < ε →
      Filter.Tendsto
        (fun n : ℕ => volume {x : ℝ | ε ≤ abs (counterexampleFn n x - x ^ 2)})
        Filter.atTop
        (Filter.nhds (0 : ℝ≥0∞))) := by
  sorry