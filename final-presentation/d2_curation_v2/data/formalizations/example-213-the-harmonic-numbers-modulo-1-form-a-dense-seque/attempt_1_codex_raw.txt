import Mathlib

noncomputable section

open scoped BigOperators

def harmonic (n : ℕ) : ℝ :=
  ∑ k in Finset.Icc 1 n, (k : ℝ)⁻¹

def harmonicFrac (n : ℕ) : ℝ :=
  harmonic n - ((⌊harmonic n⌋ : ℤ) : ℝ)

theorem harmonic_fractional_parts_dense_in_unit_interval :
    ∀ x ∈ Set.Ico (0 : ℝ) 1, ∀ ε > 0, ∃ n : ℕ, |harmonicFrac n - x| < ε := by
  sorry