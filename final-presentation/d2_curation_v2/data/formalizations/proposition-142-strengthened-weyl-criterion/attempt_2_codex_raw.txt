import Mathlib

open scoped BigOperators Topology
open Filter

noncomputable section

def fracPart (x : ℝ) : ℝ :=
  x - Int.floor x

def UniformlyDistributedModOne (u : ℕ → ℝ) : Prop :=
  ∀ f : ℝ → ℝ,
    IntervalIntegrable f volume 0 1 →
      Tendsto
        (fun N : ℕ =>
          ((1 : ℝ) / N) * ∑ n in Finset.Icc 1 N, f (fracPart (u n)))
        atTop
        (nhds (∫ x in (0 : ℝ)..1, f x ∂volume))

theorem uniformlyDistributedModOne_iff_forall_riemann_integrable_average
    (u : ℕ → ℝ) :
    UniformlyDistributedModOne u ↔
      ∀ f : ℝ → ℝ,
        IntervalIntegrable f volume 0 1 →
          Tendsto
            (fun N : ℕ =>
              ((1 : ℝ) / N) * ∑ n in Finset.Icc 1 N, f (fracPart (u n)))
            atTop
            (nhds (∫ x in (0 : ℝ)..1, f x ∂volume)) := by
  sorry