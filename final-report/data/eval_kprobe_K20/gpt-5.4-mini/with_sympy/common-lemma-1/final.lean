import Mathlib

open Filter MeasureTheory
open scoped Topology MeasureTheory

example {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (fSeq : ℕ → α → ℝ) (f : α → ℝ)
    (x : α)
    (hx : ∀ m : ℕ, ∀ᶠ n in Filter.atTop, |fSeq (n + 1) x - f x| < 1 / (m + 1 : ℝ)) :
    Tendsto (fun n : ℕ => fSeq n x) Filter.atTop (nhds (f x)) := by
  rw [← tendsto_add_atTop_iff_nat 1]
  refine Metric.tendsto_nhds.mpr ?_
  intro ε hε
  obtain ⟨m, hm⟩ := exists_nat_one_div_lt hε
  have hx' := Filter.eventually_atTop.mp (hx m)
  rcases hx' with ⟨N, hN⟩
  exact Filter.eventually_atTop.2 ⟨N, fun n hn => lt_trans (hN n hn) hm⟩