import Mathlib

theorem abel_summable_of_bigO_one_div_n
    (y : ℕ → ℝ) (a : ℝ)
    (hpow : ∀ x : ℝ, x ∈ Set.Iio 1 → Summable (fun n => y n * x ^ n))
    (habel :
      Filter.Tendsto
        (fun x : ℝ => ∑' n, y n * x ^ n)
        (nhdsWithin 1 (Set.Iio 1))
        (nhds a))
    (hO : ∃ C : ℝ, 0 ≤ C ∧ ∀ n : ℕ, 1 ≤ n → ‖y n‖ ≤ C / (n : ℝ)) :
    HasSum y a := by
  sorry