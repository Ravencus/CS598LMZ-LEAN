import Mathlib

open Filter

def UniformlyDistributedModOne (u : ℕ → ℝ) : Prop :=
  ∀ a b : ℝ,
    0 ≤ a →
    a ≤ b →
    b ≤ 1 →
      Tendsto
        (fun N : ℕ =>
          ((∑ n in Finset.range N, (if Int.fract (u n) ∈ Set.Icc a b then (1 : ℝ) else 0)) : ℝ) /
            (N : ℝ))
        atTop
        (nhds (b - a))

theorem monotone_deriv_tends_uniformlyDistributedModOne
    {f : ℝ → ℝ}
    (hDiff : DifferentiableOn ℝ f (Set.Ici (1 : ℝ)))
    (hPos : ∀ ⦃x : ℝ⦄, x ∈ Set.Ici (1 : ℝ) → 0 < deriv f x)
    (hAnti : AntitoneOn (deriv f) (Set.Ici (1 : ℝ)))
    (hLim0 : Tendsto (fun x : ℝ => deriv f x) atTop (nhds (0 : ℝ)))
    (hLimTop : Tendsto (fun x : ℝ => x * deriv f x) atTop atTop) :
    UniformlyDistributedModOne (fun n : ℕ => f n) := by
  sorry