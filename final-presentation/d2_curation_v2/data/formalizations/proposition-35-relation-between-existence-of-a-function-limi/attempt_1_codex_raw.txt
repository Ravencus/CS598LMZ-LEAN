import Mathlib

theorem limsup_liminf_atTop_ereal {f : ℝ → EReal} {ℓ : EReal} :
    let U : EReal := Filter.limsup (Filter.map f Filter.atTop)
    let L : EReal := Filter.liminf (Filter.map f Filter.atTop)
    (Filter.Tendsto f Filter.atTop (nhds ℓ) → U = ℓ ∧ L = ℓ) ∧
      (U = ℓ ∧ L = ℓ → Filter.Tendsto f Filter.atTop (nhds ℓ)) := by
  sorry