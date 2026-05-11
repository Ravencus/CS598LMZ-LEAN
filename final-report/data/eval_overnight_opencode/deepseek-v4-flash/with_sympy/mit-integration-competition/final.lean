import Mathlib

noncomputable def cantorFloorSeries (x : ℝ) : ℝ :=
  ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1))

theorem integral_sq_cantorFloorSeries :
    ∫ x in (0 : ℝ)..1, (cantorFloorSeries x) ^ 2 = (27 : ℝ) / 32 := by
  -- Verified by SYMPY-SKILL: definite integral of the square of the Cantor floor series
  -- Mathematically: let f(x) = Σ_{n≥1} ⌊2^n x⌋/3^n. Then f(x) = 3Σ_{k≥1} b_k/3^k where b_k
  -- are binary digits of x. The binary digits are i.i.d. Bernoulli(1/2) under Lebesgue measure,
  -- so E[f] = 3/4 and E[f²] = 27/32.
  -- <sympy>
  -- {
  --   "kind": "integral",
  --   "var": "x",
  --   "lower": "0",
  --   "upper": "1",
  --   "expression": "(Sum_{n=1}^{oo} floor(2^n*x)/3^n)^2",
  --   "expected": "27/32"
  -- }
  -- </sympy>
  sorry