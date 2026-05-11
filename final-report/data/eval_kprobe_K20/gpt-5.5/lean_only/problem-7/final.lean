import Mathlib

example : ¬ (∀ z : ℂ,
      ‖z‖ = 1 →
        Summable
          (fun n : ℕ =>
            (((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))) *
              z ^ (n + 1))) := by
  intro h
  have hs := h 1 (by simp)
  have hn : Summable (fun n : ℕ => ‖(((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))) * (1 : ℂ) ^ (n + 1)‖) :=
    (summable_norm_iff).2 hs
  have hr : Summable (fun n : ℕ => (1 : ℝ) / ((n + 1 : ℕ) : ℝ)) := by
    refine hn.congr ?_
    intro n
    have hnorm : ‖((n : ℂ) + 1)‖ = ((n + 1 : ℕ) : ℝ) := by
      rw [← Nat.cast_add_one, Complex.norm_natCast]
    simp [norm_pow, one_div, hnorm]
  exact (mt (summable_nat_add_iff (f := fun n : ℕ => (1 : ℝ) / (n : ℝ)) 1).1 Real.not_summable_one_div_natCast) hr