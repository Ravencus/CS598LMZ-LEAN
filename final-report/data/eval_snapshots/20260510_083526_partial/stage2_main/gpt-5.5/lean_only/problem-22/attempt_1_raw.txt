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
  intro hmin
  have hαβ :
      ∀ n : ℕ, α (n + 1) ≤ β (n + 1) + min (α (n + 1)) (β (n + 1)) := by
    intro n
    by_cases h : α (n + 1) ≤ β (n + 1)
    · rw [min_eq_left h]
      linarith [hβ_nonneg (n + 1)]
    · have h' : β (n + 1) ≤ α (n + 1) := le_of_not_ge h
      rw [min_eq_right h']
      linarith [hβ_nonneg (n + 1)]
  have hβα :
      ∀ n : ℕ, β (n + 1) ≤ α (n + 1) + min (α (n + 1)) (β (n + 1)) := by
    intro n
    by_cases h : β (n + 1) ≤ α (n + 1)
    · rw [min_eq_right h]
      linarith [hα_nonneg (n + 1)]
    · have h' : α (n + 1) ≤ β (n + 1) := le_of_not_ge h
      rw [min_eq_left h']
      linarith [hα_nonneg (n + 1)]
  have hsum_add_left :
      Summable (fun n : ℕ => β (n + 1) + min (α (n + 1)) (β (n + 1))) := by
    exact (hβ_div.elim ?_)
  exact hα_div ((summable_of_nonneg_of_le
    (fun n => hα_nonneg (n + 1)) hαβ hsum_add_left))