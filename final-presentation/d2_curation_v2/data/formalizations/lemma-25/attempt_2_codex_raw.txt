import Mathlib

open Filter

theorem subseries_diverges_of_positive_density
    (a : ℕ → ℝ) (S : Set ℕ) (δ : ℝ)
    [DecidablePred fun n => n ∈ S]
    (h_nonneg : ∀ n, 0 ≤ a n)
    (h_nonincreasing : Antitone a)
    (h_diverges : ¬ Summable (fun n : ℕ => a (n + 1)))
    (h_density :
      Tendsto
        (fun N : ℕ =>
          (((Finset.Icc 1 N).filter fun n => n ∈ S).card : ℝ) / (N : ℝ))
        atTop
        (nhds δ))
    (hδ : 0 < δ) :
    ¬ Summable (fun n : ℕ => if n + 1 ∈ S then a (n + 1) else 0) := by
  sorry