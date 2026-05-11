import Mathlib

noncomputable def limsupAtTop (f : ℝ → ℝ) : ℝ :=
  sInf { a : ℝ | ∀ᶠ x in Filter.atTop, f x < a }

noncomputable def liminfAtTop (f : ℝ → ℝ) : ℝ :=
  sSup { a : ℝ | ∀ᶠ x in Filter.atTop, a < f x }

theorem limsup_liminf_atTop_properties (f : ℝ → ℝ) :
    let U := limsupAtTop f
    let L := liminfAtTop f
    (∃ x y : ℕ → ℝ,
      Filter.Tendsto x Filter.atTop Filter.atTop ∧
      Filter.Tendsto y Filter.atTop Filter.atTop ∧
      Filter.Tendsto (fun n => f (x n)) Filter.atTop (nhds U) ∧
      Filter.Tendsto (fun n => f (y n)) Filter.atTop (nhds L)) ∧
    (∀ r : ℝ, U < r →
      ∃ R0 : ℝ, ∀ x : ℝ, R0 ≤ x → f x < r) ∧
    (∀ r : ℝ, r < U →
      ∀ R : ℝ, ∃ x : ℝ, R ≤ x ∧ r < f x) ∧
    (∀ r : ℝ, r < L →
      ∃ R0 : ℝ, ∀ x : ℝ, R0 ≤ x → r < f x) ∧
    (∀ r : ℝ, L < r →
      ∀ R : ℝ, ∃ x : ℝ, R ≤ x ∧ f x < r) := by
  sorry