import Mathlib

theorem eulerMaclaurinSummationFormula
    (f : ℝ → ℝ) (B : ℕ → ℝ → ℝ) (D : ℕ → ℝ → ℝ) (frac : ℝ → ℝ)
    (m n p y x : ℕ) :
    ((Finset.sum (Finset.Icc m n) fun k => f (k : ℝ)) =
        (∫ t in (m : ℝ)..(n : ℝ), f t) +
          (f (m : ℝ) + f (n : ℝ)) / 2 +
          (Finset.sum (Finset.Icc 1 (p / 2)) fun r =>
            (B (2 * r) 0 / (Nat.factorial (2 * r) : ℝ)) *
              (D (2 * r - 1) (n : ℝ) - D (2 * r - 1) (m : ℝ))) +
          (((-1 : ℝ) ^ (p + 1)) / (Nat.factorial p : ℝ)) *
            (∫ t in (m : ℝ)..(n : ℝ), B p (frac t) * D p t))
    ∧
    ((Finset.sum (Finset.Icc (y + 1) x) fun k => f (k : ℝ)) =
        (∫ t in (y : ℝ)..(x : ℝ), f t) +
          (Finset.sum (Finset.Icc 1 p) fun k =>
            (((-1 : ℝ) ^ k) / (k : ℝ)) *
              (B k (frac (x : ℝ)) * D (k - 1) (x : ℝ) -
                B k (frac (y : ℝ)) * D (k - 1) (y : ℝ))) +
          (((-1 : ℝ) ^ (p + 1)) / (Nat.factorial p : ℝ)) *
            (∫ t in (y : ℝ)..(x : ℝ), B p (frac t) * D p t)) := by
  sorry