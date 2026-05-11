import Mathlib

theorem floorSqrtAlternatingHarmonic_powerSeries_converges_on_unitCircle :
    ∀ z : ℂ,
      ‖z‖ = 1 →
        Summable
          (fun n : ℕ =>
            (((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))) *
              z ^ (n + 1)) := by
  -- NOTE: As stated, this theorem is mathematically FALSE.
  -- In Mathlib, `Summable f` for ℂ-valued `f` is equivalent to absolute
  -- summability: `Summable f ↔ Summable (fun n => ‖f n‖)`. At z = 1,
  -- the norm of the n-th term is 1/(n+1), and ∑ 1/(n+1) diverges (harmonic).
  -- Hence the conjunction `‖1‖ = 1 ∧ Summable …` cannot hold, so the
  -- universal statement is false.
  --
  -- The CLASSICAL theorem (that this power series converges on |z|=1)
  -- refers to convergence of the partial sums (Abel / Dirichlet test on
  -- the floor-sqrt blocks), not unconditional/absolute summability.
  -- A correct Lean statement would use
  --   `Filter.Tendsto (fun N => ∑ n ∈ Finset.range N, …) Filter.atTop (nhds L)`
  -- rather than `Summable`.
  --
  -- No valid Lean proof of the statement as written exists.
  intro z hz
  exact?