import Mathlib

noncomputable section

open scoped BigOperators

def harmonic (n : ℕ) : ℝ :=
  Finset.sum (Finset.Icc 1 n) fun k => (k : ℝ)⁻¹

def harmonicFrac (n : ℕ) : ℝ :=
  harmonic n - ((⌊harmonic n⌋ : ℤ) : ℝ)

theorem harmonic_fractional_parts_dense_in_unit_interval :
    ∀ x, x ∈ Set.Ico (0 : ℝ) 1 → ∀ ε > 0, ∃ n : ℕ, |harmonicFrac n - x| < ε := by
  sorry