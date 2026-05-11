import Mathlib

theorem alternatingSignCesaroSummable :
    let a : ℕ → ℝ := fun n => (-1 : ℝ) ^ n;
    let S : ℕ → ℝ := fun n => ∑ k in Finset.range (n + 1), a k;
    (∀ n : ℕ, S n = if Even n then 1 else 0) ∧
      (¬ ∃ l : ℝ, Filter.Tendsto S Filter.atTop (Filter.nhds l)) ∧
      Filter.Tendsto
        (fun N : ℕ => (∑ k in Finset.range N, S k) / (N : ℝ))
        Filter.atTop
        (Filter.nhds (1 / 2 : ℝ)) := by
  sorry