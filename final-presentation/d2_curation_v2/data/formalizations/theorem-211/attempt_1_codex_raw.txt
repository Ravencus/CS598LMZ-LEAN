import Mathlib

theorem identity_theorem_zero_of_accumulation_point
    {U S : Set ℂ} {f : ℂ → ℂ}
    (hU_open : IsOpen U)
    (hU_connected : IsConnected U)
    (hhol : DifferentiableOn ℂ f U)
    (hSU : S ⊆ U)
    (hacc : ∃ z0 ∈ U, z0 ∈ closure (S \ ({z0} : Set ℂ)))
    (hzero : ∀ z ∈ S, f z = 0) :
    EqOn f (fun _ => 0) U := by
  sorry