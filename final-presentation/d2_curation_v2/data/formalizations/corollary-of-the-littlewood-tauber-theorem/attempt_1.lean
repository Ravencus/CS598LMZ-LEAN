import Mathlib

open Filter Asymptotics

theorem arithmeticMeans_convergence_of_difference_bigO
    {y : ℕ → ℝ} {a : ℝ}
    (hmean :
      Tendsto
        (fun n : ℕ => ((n + 1 : ℝ)⁻¹) * ∑ k in Finset.range (n + 1), y k)
        atTop
        (nhds a))
    (hdiff :
      Asymptotics.IsBigO
        atTop
        (fun n : ℕ => y (n + 1) - y n)
        (fun n : ℕ => (n + 1 : ℝ)⁻¹)) :
    Tendsto y atTop (nhds a) := by
  sorry