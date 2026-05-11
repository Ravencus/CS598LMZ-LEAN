import Mathlib

theorem ae_tendsto_of_summable_bad_sets
    {α : Type*} [MeasurableSpace α]
    (μ : MeasureTheory.Measure α)
    (fSeq : ℕ → α → ℝ) (f : α → ℝ) (ε : ℕ → ℝ)
    (hε_nonneg : ∀ n : ℕ, 0 ≤ ε n)
    (hε_antitone : Antitone ε)
    (hε_tendsto : Filter.Tendsto ε Filter.atTop (Filter.nhds 0))
    (hsummable :
      Summable (fun n : ℕ => (μ {x : α | |fSeq n x - f x| ≥ ε n}).toReal)) :
    let A : ℕ → Set α := fun n => {x : α | |fSeq n x - f x| ≥ ε n}
    ((∀ x : α,
        (¬ ∀ N : ℕ, ∃ n : ℕ, N < n ∧ x ∈ A n) →
          ∃ Nx : ℕ, ∀ n : ℕ, Nx < n → |fSeq n x - f x| < ε n) ∧
      (∀ x : α,
        (¬ ∀ N : ℕ, ∃ n : ℕ, N < n ∧ x ∈ A n) →
          Filter.Tendsto (fun n : ℕ => fSeq n x) Filter.atTop (Filter.nhds (f x))) ∧
      (∀ᵐ x ∂μ, Filter.Tendsto (fun n : ℕ => fSeq n x) Filter.atTop (Filter.nhds (f x)))) := by
  sorry