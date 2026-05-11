import Mathlib

noncomputable section

abbrev L1 (G : Type*) := G → ℂ
abbrev C0 (Ghat : Type*) := Ghat → ℂ

theorem fourierTransform_linear_map
    (G Ghat : Type*) :
    ∃ 𝓕 : L1 G →ₗ[ℂ] C0 Ghat, True := by
  sorry