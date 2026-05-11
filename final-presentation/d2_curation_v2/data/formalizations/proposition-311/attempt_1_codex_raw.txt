import Mathlib

theorem periodic_nonconstant_natSeq_no_limit
    {f : ℝ → ℝ} {T : ℝ}
    (hf_cont : Continuous f)
    (hf_periodic : Function.Periodic f T)
    (hT_pos : 0 < T)
    (hT_least : ∀ S : ℝ, 0 < S → Function.Periodic f S → T ≤ S)
    (h_nonconst : ¬ ∃ c : ℝ, ∀ n : ℕ, f n = c) :
    ¬ ∃ l : ℝ, Filter.Tendsto (fun n : ℕ => f n) Filter.atTop (nhds l) := by
  sorry