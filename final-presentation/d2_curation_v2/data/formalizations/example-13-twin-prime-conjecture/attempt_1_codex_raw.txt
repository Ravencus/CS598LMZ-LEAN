import Mathlib

def TwinPrimeConjecture : Prop :=
  Set.Infinite {p : ℕ | Nat.Prime p ∧ Nat.Prime (p + 2)}

def LiminfEqTwo (a : ℕ → ℕ) : Prop :=
  (∀ N : ℕ, ∃ n ≥ N, a n = 2) ∧ ∃ N : ℕ, ∀ n ≥ N, 2 ≤ a n

theorem twinPrimeConjecture_iff_liminf_primeGaps_eq_two
    (p : ℕ → ℕ)
    (hp_prime : ∀ n : ℕ, Nat.Prime (p n))
    (hp_strictMono : StrictMono p)
    (hp_enumerates : ∀ q : ℕ, Nat.Prime q ↔ ∃ n : ℕ, p n = q) :
    TwinPrimeConjecture ↔ LiminfEqTwo (fun n : ℕ => p (n + 1) - p n) := by
  sorry