1. Establish the standard summatory estimate for the von Mangoldt function: \(\sum_{n \le x}\frac{\Lambda(n)}{n} = \log x + O(1)\).

2. Rewrite \(\sum_{n \le x}\frac{\Lambda(n)}{n}\) as a sum over prime powers \(p^k \le x\), namely \(\sum_{p^k \le x}\frac{\log p}{p^k}\).

3. Split that prime-power sum into the prime term \(k=1\) and the higher-power tail \(k \ge 2\), and show the tail is bounded uniformly in \(x\).

4. Deduce that \(\sum_{p \le x}\frac{\log p}{p}\) differs from \(\sum_{n \le x}\frac{\Lambda(n)}{n}\) by \(O(1)\), so it inherits the same \(\log x + O(1)\) asymptotic.