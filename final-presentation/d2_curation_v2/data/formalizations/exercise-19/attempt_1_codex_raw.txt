import Mathlib

theorem summable_iff_summable_map_of_nondecreasing_pos
    (f : ℝ → ℝ)
    (hf_nonneg : ∀ ⦃x : ℝ⦄, 0 ≤ x → 0 ≤ f x)
    (hf_mono : MonotoneOn f (Set.Ici 0))
    (hlim : Filter.Tendsto (fun x : ℝ => f x / x) (nhdsWithin 0 (Set.Ioi 0)) (nhds 1)) :
    ∀ (a : ℕ → ℝ), (∀ n, 0 ≤ a n) → (Summable a ↔ Summable (fun n => f (a n))) := by
  sorry