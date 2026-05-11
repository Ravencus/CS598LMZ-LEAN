import Mathlib

theorem lp_convergence_implies_convergence_in_measure
    {α : Type*} [MeasurableSpace α] (μ : Measure α) (p : ℝ≥0∞)
    (f : α → ℝ) (fSeq : ℕ → α → ℝ)
    (hp : 0 < p)
    (hLp : Filter.Tendsto
      (fun n => eLpNorm (fun x => fSeq n x - f x) p μ)
      Filter.atTop
      (Filter.nhds (0 : ℝ≥0∞))) :
    ∀ ε : ℝ, 0 < ε →
      Filter.Tendsto
        (fun n => μ {x | ε ≤ ‖fSeq n x - f x‖})
        Filter.atTop
        (Filter.nhds (0 : ℝ≥0∞)) := by
  sorry