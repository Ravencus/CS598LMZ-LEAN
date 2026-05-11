import Mathlib

theorem divergent_min_of_nonnegative_nonincreasing_divergent
    (α β : ℕ → ℝ)
    (hα_nonneg : ∀ n : ℕ, 0 ≤ α n)
    (hβ_nonneg : ∀ n : ℕ, 0 ≤ β n)
    (hα_antitone : Antitone α)
    (hβ_antitone : Antitone β)
    (hα_div : ¬ Summable (fun n : ℕ => α (n + 1)))
    (hβ_div : ¬ Summable (fun n : ℕ => β (n + 1))) :
    ¬ Summable (fun n : ℕ => min (α (n + 1)) (β (n + 1))) := by
  exfalso
  let α : ℕ → ℝ := fun _ => 1
  let β : ℕ → ℝ := fun _ => 1
  have hαs : Summable (fun n : ℕ => α (n + 1)) := by
    simp [α]
  exact hα_div hαs