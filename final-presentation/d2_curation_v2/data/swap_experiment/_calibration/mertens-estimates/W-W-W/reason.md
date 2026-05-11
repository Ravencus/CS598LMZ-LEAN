By plan step 1, we take as given the standard asymptotic
\[
\sum_{n\le x}\frac{\Lambda(n)}{n}=\log x+O(1).
\]
This is the usual summatory estimate for \(\Lambda(n)/n\); in a formal proof one would invoke the standard prime-number-theorem-level bound for the weighted von Mangoldt sum, or an equivalent lemma giving a bounded error term after partial summation.

By plan step 2, we rewrite the left-hand side using the definition of the von Mangoldt function: \(\Lambda(n)=\log p\) if \(n=p^k\) is a prime power, and \(\Lambda(n)=0\) otherwise. Hence
\[
\sum_{n\le x}\frac{\Lambda(n)}{n}
=\sum_{p^k\le x}\frac{\log p}{p^k}.
\]
This is just a partition of the sum over \(n\) into prime powers, using the fact that the support of \(\Lambda\) is exactly the set of prime powers.

By plan step 3, we split the prime-power sum into the prime terms and the higher-power tail:
\[
\sum_{p^k\le x}\frac{\log p}{p^k}
=\sum_{p\le x}\frac{\log p}{p}+\sum_{\substack{k\ge2\\ p^k\le x}}\frac{\log p}{p^k}.
\]
For the tail, note that \(k\ge2\) implies \(p^k\ge p^2\), so each summand satisfies
\[
0\le \frac{\log p}{p^k}\le \frac{\log p}{p^2}.
\]
Therefore
\[
0\le \sum_{\substack{k\ge2\\ p^k\le x}}\frac{\log p}{p^k}
\le \sum_p \sum_{k\ge2}\frac{\log p}{p^k}
= \sum_p \frac{\log p}{p^2}\cdot \frac1{1-1/p},
\]
and the right-hand side is bounded by a constant independent of \(x\). Indeed, for \(p\ge2\), \(\frac1{1-1/p}\le2\), so it suffices to bound \(\sum_p \log p/p^2\), which converges by comparison with \(\sum_{n\ge2}\log n/n^2\), and the latter converges by the integral test. In Mathlib terms, this is a routine comparison with a known summable series, together with `Monotone`/`Summable` estimates.

By plan step 4, the higher-power tail is \(O(1)\), uniformly in \(x\). Hence
\[
\sum_{p\le x}\frac{\log p}{p}
=
\sum_{n\le x}\frac{\Lambda(n)}{n}
+O(1).
\]
Combining this with the asymptotic from plan step 1 gives
\[
\sum_{p\le x}\frac{\log p}{p}
=\log x+O(1),
\]
as required.