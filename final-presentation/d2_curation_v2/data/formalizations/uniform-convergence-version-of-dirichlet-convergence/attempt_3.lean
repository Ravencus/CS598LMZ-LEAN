import Mathlib

theorem uniform_dirichlet_test
    {α : Type*}
    (D : Set α)
    (a b : ℕ → α → ℝ)
    (hbounded :
      ∃ M : ℝ, 0 ≤ M ∧
        ∀ N z, z ∈ D →
          ‖Finset.sum (Finset.range (N + 1)) (fun n => b n z)‖ ≤ M)
    (hmono : ∀ z ∈ D, Antitone (fun n => a n z))
    (hlim : ∀ z ∈ D, Filter.Tendsto (fun n => a n z) Filter.atTop (Filter.nhds 0)) :
    ∃ f : α → ℝ,
      TendstoUniformlyOn
        (fun N z => Finset.sum (Finset.range (N + 1)) (fun n => a n z * b n z))
        f
        Filter.atTop
        D := by
  sorry