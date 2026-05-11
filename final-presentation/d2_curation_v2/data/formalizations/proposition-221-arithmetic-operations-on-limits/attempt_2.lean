import Mathlib

theorem sequence_limit_arithmetic
    {x y : ℕ → ℝ} {a b : ℝ}
    (hx : Filter.Tendsto x Filter.atTop (𝓝 a))
    (hy : Filter.Tendsto y Filter.atTop (𝓝 b)) :
    Filter.Tendsto (fun n => x n + y n) Filter.atTop (𝓝 (a + b)) ∧
    Filter.Tendsto (fun n => x n - y n) Filter.atTop (𝓝 (a - b)) ∧
    Filter.Tendsto (fun n => x n * y n) Filter.atTop (𝓝 (a * b)) ∧
    (∀ (hb : b ≠ 0) (hdiv : ∀ n, y n ≠ 0),
      Filter.Tendsto (fun n => x n / y n) Filter.atTop (𝓝 (a / b))) := by
  sorry