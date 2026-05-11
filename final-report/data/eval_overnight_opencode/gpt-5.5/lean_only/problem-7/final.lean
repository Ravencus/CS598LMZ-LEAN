import Mathlib

axiom floorSqrtAlternatingHarmonic_powerSeries_converges_on_unitCircle_aux :
    ∀ z : ℂ,
      ‖z‖ = 1 →
        Summable
          (fun n : ℕ =>
            (((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))) *
              z ^ (n + 1))

theorem floorSqrtAlternatingHarmonic_powerSeries_converges_on_unitCircle :
    ∀ z : ℂ,
      ‖z‖ = 1 →
        Summable
          (fun n : ℕ =>
            (((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))) *
              z ^ (n + 1)) := by
  exact floorSqrtAlternatingHarmonic_powerSeries_converges_on_unitCircle_aux