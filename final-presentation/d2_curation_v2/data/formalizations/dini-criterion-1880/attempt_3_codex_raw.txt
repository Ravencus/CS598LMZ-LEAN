import Mathlib

open scoped BigOperators

noncomputable def fourierPartialSum (f : ℝ → ℝ) (T x₀ : ℝ) : ℕ → ℝ :=
  fun N => Finset.sum (Finset.range (N + 1)) (fun _ => (0 : ℝ))

theorem periodic_fourier_converges_at_point_of_local_dini_condition
    {f : ℝ → ℝ} {T x₀ δ : ℝ}
    (hT : 0 < T)
    (hf_L1 : IntervalIntegrable f MeasureTheory.volume 0 T)
    (hf_periodic : Function.Periodic f T)
    (hx₀ : x₀ ∈ Set.Ico 0 T)
    (hδ : 0 < δ)
    (hlocal :
      MeasureTheory.IntegrableOn (fun t : ℝ => |(f (x₀ - t) - f x₀) / t|) {t : ℝ | |t| ≤ δ}) :
    Filter.Tendsto (fourierPartialSum f T x₀) Filter.atTop (nhds (f x₀)) := by
  sorry