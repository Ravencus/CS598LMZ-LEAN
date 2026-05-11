import Mathlib

theorem limit_three_sub_T_eq_limit_S
    {T S : ℕ → ℝ} {a b : ℝ}
    (hT : Filter.Tendsto (fun N => 3 - T N) Filter.atTop (nhds a))
    (hS : Filter.Tendsto S Filter.atTop (nhds b)) :
    a = b := by
  sorry