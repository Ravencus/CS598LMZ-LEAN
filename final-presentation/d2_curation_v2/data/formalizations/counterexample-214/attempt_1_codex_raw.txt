import Mathlib

theorem disconnected_domain_piecewise_constant_holomorphic
    (A B : Set ℂ)
    (hA_open : IsOpen A)
    (hB_open : IsOpen B)
    (hAB_disj : Disjoint A B)
    (hA_nonempty : A.Nonempty)
    (hB_nonempty : B.Nonempty) :
    let U : Set ℂ := A ∪ B
    let f : ℂ → ℂ := fun z => if z ∈ A then 0 else if z ∈ B then 1 else 0
    DifferentiableOn ℂ f U ∧
      (∃ z ∈ U, f z ≠ 0) ∧
      (∃ z0 ∈ U, f z0 = 0 ∧
        ∀ ε : ℝ, 0 < ε → ∃ z ∈ U, z ≠ z0 ∧ ‖z - z0‖ < ε ∧ f z = 0) := by
  sorry