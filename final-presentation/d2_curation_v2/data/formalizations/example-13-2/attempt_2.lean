import Mathlib

noncomputable section

open scoped BigOperators

def epsilonMod3 : ℕ → ℝ :=
  fun n => if n % 3 = 1 then 1 else -1

def harmonicWeight : ℕ → ℝ :=
  fun n => 1 / (n : ℝ)

def counterexampleA : ℕ → ℝ :=
  fun n => (Finset.sum (Finset.Icc 1 n) fun i => epsilonMod3 i) * harmonicWeight n

def counterexamplePartialSums : ℕ → ℝ :=
  fun N => Finset.sum (Finset.Icc 1 N) fun n => epsilonMod3 n * harmonicWeight n

theorem epsilonHarmonicCounterexampleDiverges :
    (∀ k : ℕ, counterexampleA (3 * (k + 1)) = -(1 / 3 : ℝ)) ∧
    ¬ Filter.Tendsto counterexampleA Filter.atTop (Filter.nhds (0 : ℝ)) ∧
    ¬ Summable (fun n : ℕ => epsilonMod3 (n + 1) * harmonicWeight (n + 1)) := by
  sorry