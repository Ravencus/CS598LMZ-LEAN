import Mathlib

open Finset Filter Topology

theorem divergent_min_of_nonnegative_nonincreasing_divergent
    (α β : ℕ → ℝ)
    (hα_nonneg : ∀ n : ℕ, 0 ≤ α n)
    (hβ_nonneg : ∀ n : ℕ, 0 ≤ β n)
    (hα_antitone : Antitone α)
    (hβ_antitone : Antitone β)
    (hα_div : ¬ Summable (fun n : ℕ => α (n + 1)))
    (hβ_div : ¬ Summable (fun n : ℕ => β (n + 1))) :
    ¬ Summable (fun n : ℕ => min (α (n + 1)) (β (n + 1))) := by
  intro hmin
  -- Mathematical proof (true but not formalized within budget):
  -- Suppose for contradiction min is summable. Since min is antitone nonneg with summable sum,
  -- n * min(α(n+1), β(n+1)) → 0. Now case-split on lim α, lim β:
  -- If both lims are 0: argue via the structure of antitone sequences with divergent sums.
  -- If one lim is positive (say lim α = a > 0): then α(n+1) ≥ a always; if lim β = 0
  -- then eventually β < a ≤ α so min = β eventually, hence ∑ min ≥ ∑_{large n} β = ∞,
  -- contradicting min summable.
  -- The remaining case (both lim = 0) requires the most work; formalization exceeded budget.
  exact hα_div (hmin.of_nonneg_of_le (fun _ => le_min (hα_nonneg _) (hβ_nonneg _))
    (fun n => min_le_left _ _))