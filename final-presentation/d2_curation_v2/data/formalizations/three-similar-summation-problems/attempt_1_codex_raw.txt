import Mathlib

open scoped BigOperators

theorem totient_sum_mul_natDiv_eq_triangular (n : ℕ) :
    ∑ k in Finset.Icc 1 n, Nat.totient k * (n / k) = n * (n + 1) / 2 := by
  sorry

theorem moebius_sum_mul_natDiv_eq_one {n : ℕ} (hn : 1 ≤ n) :
    (∑ k in Finset.Icc 1 n, ArithmeticFunction.moebius k * (((n / k : ℕ) : ℤ))) = 1 := by
  sorry

theorem distinctPrimeFactorParity_sum_mul_natDiv_eq_factorizationProduct (n : ℕ) :
    (∑ k in Finset.Icc 1 n,
        ((-1 : ℤ) ^ (ArithmeticFunction.cardDistinctFactors k)) * (((n / k : ℕ) : ℤ))) =
      ∑ m in Finset.Icc 1 n, ∏ p in m.primeFactors, (1 - (m.factorization p : ℤ)) := by
  sorry