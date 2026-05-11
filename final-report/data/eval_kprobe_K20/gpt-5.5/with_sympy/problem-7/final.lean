import Mathlib

theorem not_floorSqrtAlternatingHarmonic_powerSeries_converges_on_unitCircle :
    ¬ (∀ z : ℂ,
      ‖z‖ = 1 →
        Summable
          (fun n : ℕ =>
            (((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))) *
              z ^ (n + 1))) := by
  intro h
  have hs : Summable
          (fun n : ℕ =>
            (((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))) *
              (1 : ℂ) ^ (n + 1)) := h 1 (by simp)
  have hs_norm : Summable (fun n : ℕ => ‖(((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))) *
              (1 : ℂ) ^ (n + 1)‖) := Summable.norm hs
  have hs_harm : Summable (fun n : ℕ => (1 : ℝ) / (n + 1)) := by
    simpa using hs_norm.congr (fun n => by
      rw [norm_mul, norm_div]
      simp
      simpa using Complex.norm_natCast (n + 1))
  have hnot : ¬ Summable (fun n : ℕ => (1 : ℝ) / (n + 1)) := by
    exact_mod_cast mt (_root_.summable_nat_add_iff 1).1 Real.not_summable_one_div_natCast
  exact hnot hs_harm