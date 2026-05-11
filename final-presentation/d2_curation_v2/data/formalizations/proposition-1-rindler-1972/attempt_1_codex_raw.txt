import Mathlib

noncomputable section

def UniformDistributedModOne (x : ℕ → ℝ) : Prop :=
  ∀ (a b : ℝ), 0 ≤ a → a ≤ b → b ≤ 1 →
    Filter.Tendsto
      (fun N : ℕ =>
        (∑ n in Finset.range N, if (x n - Real.floor (x n) : ℝ) ∈ Set.Icc a b then (1 : ℝ) else 0) / N)
      Filter.atTop
      (nhds (b - a))

theorem uniformDistributedModOne_add_log
    (x : ℕ → ℝ)
    (hx : UniformDistributedModOne x) :
    UniformDistributedModOne (fun n => x n + Real.log (n : ℝ)) := by
  sorry