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
  have hαβ : ∀ n : ℕ, min (α (n + 1)) (β (n + 1)) ≤ α (n + 1) := by
    intro n
    exact min_le_left _ _
  have hβα : ∀ n : ℕ, min (α (n + 1)) (β (n + 1)) ≤ β (n + 1) := by
    intro n
    exact min_le_right _ _
  have hmin_nonneg : ∀ n : ℕ, 0 ≤ min (α (n + 1)) (β (n + 1)) := by
    intro n
    exact le_min (hα_nonneg _) (hβ_nonneg _)
  have hα_or_β :
      Summable (fun n : ℕ => α (n + 1)) ∨
        Summable (fun n : ℕ => β (n + 1)) := by
    by_cases h : ∀ n : ℕ, α (n + 1) ≤ β (n + 1)
    · left
      have h_eq : (fun n : ℕ => α (n + 1)) =
          (fun n : ℕ => min (α (n + 1)) (β (n + 1))) := by
        funext n
        exact (min_eq_left (h n)).symm
      simpa [h_eq] using hmin
    · right
      push_neg at h
      rcases h with ⟨N, hN⟩
      have h_tail_le : ∀ n : ℕ, N ≤ n → β (n + 1) ≤ α (n + 1) := by
        intro n hn
        have hβ_le : β (n + 1) ≤ β (N + 1) := by
          exact hβ_antitone (by omega)
        have hα_le : α (N + 1) ≤ α (n + 1) := by
          exact hα_antitone (by omega)
        linarith
      have h_eventually :
          ∀ᶠ n in Filter.atTop,
            β (n + 1) = min (α (n + 1)) (β (n + 1)) := by
        exact Filter.eventually_atTop.2
          ⟨N, by
            intro n hn
            exact (min_eq_right (h_tail_le n hn)).symm⟩
      exact hmin.congr h_eventually.symm
  rcases hα_or_β with hα | hβ
  · exact hα_div hα
  · exact hβ_div hβ