import Mathlib

theorem lp_convergence_implies_convergence_in_measure
    {α : Type*} [MeasurableSpace α] (μ : Measure α) (p : ENNReal)
    (f : α → ℝ) (fSeq : ℕ → α → ℝ)
    (hp : 0 < p)
    (hLp : Filter.Tendsto
      (fun n : ℕ => eLpNorm (fun x : α => fSeq n x - f x) p μ)
      Filter.atTop
      (Filter.nhds (0 : ENNReal))) :
    ∀ ε : ℝ, 0 < ε →
      Filter.Tendsto
        (fun n : ℕ => μ {x : α | ε ≤ ‖fSeq n x - f x‖})
        Filter.atTop
        (Filter.nhds (0 : ENNReal)) := by
  sorry