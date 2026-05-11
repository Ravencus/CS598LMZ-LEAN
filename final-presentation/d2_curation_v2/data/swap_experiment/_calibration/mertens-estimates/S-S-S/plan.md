1. Let \(\psi(x)=\sum_{n\le x}\Lambda(n)\). Prove the Chebyshev/PNT estimate \(\psi(x)=x+O\!\left(\frac{x}{\log x}\right)\) (or any comparable \(x+o(x)\) estimate strong enough for partial summation).

2. Apply partial summation to \(a_n=\Lambda(n)\) and \(A(t)=\psi(t)\) to reduce
   \[
   \sum_{n\le x}\frac{\Lambda(n)}{n}
   \]
   to an expression involving \(\psi(x)/x\) and \(\int_1^x \psi(t)\,t^{-2}\,dt\).

3. Insert the estimate for \(\psi(t)\) from the previous step and deduce
   \[
   \sum_{n\le x}\frac{\Lambda(n)}{n}=\log x+O(1).
   \]

4. Rewrite the von Mangoldt sum by prime powers:
   \[
   \sum_{n\le x}\frac{\Lambda(n)}{n}
   =
   \sum_{p\le x}\frac{\log p}{p}
   +
   \sum_{\substack{k\ge 2\\ p^k\le x}}\frac{\log p}{p^k},
   \]
   and show the prime-power tail
   \[
   \sum_{\substack{k\ge 2\\ p^k\le x}}\frac{\log p}{p^k}
   \]
   is uniformly bounded in \(x\) (equivalently, the full series over \(k\ge2\) converges absolutely).

5. Combine the first asymptotic with the boundedness of the prime-power tail to conclude
   \[
   \sum_{p\le x}\frac{\log p}{p}=\log x+O(1).
   \]