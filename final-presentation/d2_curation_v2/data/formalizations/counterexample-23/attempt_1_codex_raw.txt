import Mathlib

noncomputable section

open scoped BigOperators

def F (k : ℕ) : ℝ :=
  if k % 2 = 1 then
    (2 : ℝ) ^ (-(((2 : ℕ) ^ k : ℤ)))
  else
    (2 : ℝ) ^ (-(((2 : ℕ) ^ (k + 1) : ℤ)))

def G (k : ℕ) : ℝ :=
  if k % 2 = 1 then
    (2 : ℝ) ^ (-(((2 : ℕ) ^ (k + 1) : ℤ)))
  else
    (2 : ℝ) ^ (-(((2 : ℕ) ^ k : ℤ)))

def L (k : ℕ) : ℝ :=
  (2 : ℝ) ^ ((2 : ℕ) ^ k)

theorem concrete_block_sequence_construction :
    ∃ α β : ℕ → ℝ,
      (¬ Summable α) ∧
      (¬ Summable β) ∧
      Summable (fun n : ℕ => min (α (n + 1)) (β (n + 1))) ∧
      (∑' n : ℕ, min (α (n + 1)) (β (n + 1))) =
        ∑' k : ℕ, L (k + 1) * min (F (k + 1)) (G (k + 1)) ∧
      (∑' k : ℕ, L (k + 1) * min (F (k + 1)) (G (k + 1))) =
        ∑' k : ℕ, (1 : ℝ) / (2 : ℝ) ^ ((2 : ℕ) ^ (k + 1)) ∧
      Summable (fun k : ℕ => (1 : ℝ) / (2 : ℝ) ^ ((2 : ℕ) ^ (k + 1))) := by
  sorry