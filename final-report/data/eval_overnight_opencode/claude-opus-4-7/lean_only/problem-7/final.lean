import Mathlib

theorem floorSqrtAlternatingHarmonic_powerSeries_converges_on_unitCircle :
    ∀ z : ℂ,
      ‖z‖ = 1 →
        Summable
          (fun n : ℕ =>
            (((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))) *
              z ^ (n + 1)) := by
  -- NOTE: As stated, this theorem is mathematically FALSE in Mathlib's sense of `Summable`.
  -- Mathlib's `Summable` denotes UNCONDITIONAL summability (the net of finite partial sums
  -- converges along the `Filter.atTop` of `Finset ℂ`). For complex-valued series this is
  -- equivalent to absolute convergence (`Summable fun n => ‖f n‖`).
  --
  -- For z = 1, the term reduces to (-1)^⌊√(n+1)⌋ / (n+1), whose absolute values are 1/(n+1),
  -- and ∑ 1/(n+1) diverges. Hence the series is NOT `Summable` in Mathlib at z = 1, even
  -- though it converges conditionally (in the sense ∑_{n=1}^N → limit as N → ∞).
  -- See Mathlib's own docstring for `HasSum` which explicitly cites `(-1)^n / (n+1)`
  -- as an example that is NOT `Summable`.
  --
  -- A faithful Lean formulation would replace `Summable (...)` with, e.g.,
  --   ∃ s : ℂ, Tendsto (fun N => ∑ n ∈ Finset.range N, ...) atTop (𝓝 s)
  -- which is the conditional/sequential sense intended by the original math problem.
  --
  -- Because the rules forbid `sorry`, no honest proof exists; we mark the impossible step:
  sorry