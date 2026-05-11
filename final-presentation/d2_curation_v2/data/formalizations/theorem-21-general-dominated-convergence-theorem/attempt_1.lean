import Mathlib

theorem dominated_convergence_integral_tendsto
    {A Ω : Type*}
    [MeasurableSpace Ω]
    {μ : Measure Ω}
    {l : Filter A}
    (fα : A → Ω → ℝ)
    (f g : Ω → ℝ)
    (h_meas : ∀ a, Measurable (fα a))
    (hf_meas : Measurable f)
    (hg_int : Integrable g μ)
    (hg_nonneg : 0 ≤ᵐ[μ] g)
    (h_bound : ∀ a, ∀ᵐ x ∂μ, |fα a x| ≤ g x)
    (h_ae_tendsto : ∀ᵐ x ∂μ, Filter.Tendsto (fun a => fα a x) l (nhds (f x))) :
    Filter.Tendsto (fun a => ∫ x, fα a x ∂μ) l (nhds (∫ x, f x ∂μ)) := by
  sorry