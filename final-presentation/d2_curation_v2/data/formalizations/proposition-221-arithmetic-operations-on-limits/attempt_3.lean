import Mathlib

theorem sequence_limit_arithmetic
    {x y : ℕ → ℝ} {a b : ℝ}
    (hx : Filter.Tendsto x Filter.atTop (Filter.nhds a))
    (hy : Filter.Tendsto y Filter.atTop (Filter.nhds b)) :
    Filter.Tendsto (fun n => x n + y n) Filter.atTop (Filter.nhds (a + b)) ∧
    Filter.Tendsto (fun n => x n - y n) Filter.atTop (Filter.nhds (a - b)) ∧
    Filter.Tendsto (fun n => x n * y n) Filter.atTop (Filter.nhds (a * b)) ∧
    (∀ (hb : b ≠ 0) (hdiv : ∀ n, y n ≠ 0),
      Filter.Tendsto (fun n => x n / y n) Filter.atTop (Filter.nhds (a / b))) := by
  sorry