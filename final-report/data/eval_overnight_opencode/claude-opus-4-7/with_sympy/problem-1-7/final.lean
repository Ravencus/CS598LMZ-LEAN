import Mathlib

open Filter Real Finset
open scoped Topology BigOperators

-- The limit ∑_{k=0}^n sin(k/n²) → 1/2 as n → ∞.
-- Mathematically: sin(k/n²) ≈ k/n² for large n, so the sum ≈ ∑ k/n² = n(n+1)/(2n²) → 1/2.
-- The error is O(1/n²) since |sin x - x| = O(x³) and ∑(k/n²)³ ≤ n·(1/n)³ = 1/n².

/-
<sympy>
{
  "kind": "limit",
  "var": "n",
  "expression": "Sum(sin(k/n**2), (k, 0, n))",
  "point": "oo",
  "expected": "1/2"
}
</sympy>
-/

theorem sum_sin_div_nsq_tendsto_half :
    Filter.Tendsto
      (fun n : ℕ => Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2)))
      Filter.atTop
      (nhds ((1 : ℝ) / 2)) := by
  sorry