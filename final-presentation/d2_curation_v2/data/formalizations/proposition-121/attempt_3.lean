import Mathlib

theorem series_converges_exists_limit :
    let a : ℕ → ℝ :=
      fun n => 1 / ((((n : ℝ) + 1) * ((n : ℝ) + 2)) * (Nat.factorial (n + 2) : ℝ));
    let T : ℕ → ℝ :=
      fun N => ∑ n in Finset.range (N + 1), a n;
    ∃ l : ℝ, Filter.Tendsto T Filter.atTop (𝓝 l) := by
  sorry