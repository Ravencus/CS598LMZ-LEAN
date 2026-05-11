By plan step 1, let
\[
\psi(x)=\sum_{n\le x}\Lambda(n).
\]
We use the standard Chebyshev/prime number theorem estimate
\[
\psi(x)=x+O\!\left(\frac{x}{\log x}\right),
\]
or indeed any estimate of the form \(\psi(x)=x+o(x)\) with an error integrable after division by \(t^2\). Concretely, this means that for \(t\ge 2\),
\[
\psi(t)=t+E(t),\qquad E(t)=O\!\left(\frac{t}{\log t}\right).
\]
This is exactly the input needed for partial summation.

By plan step 2, apply the summation-by-parts formula to \(a_n=\Lambda(n)\), with partial sums \(A(t)=\psi(t)\), and \(f(t)=1/t\). The standard partial summation identity gives
\[
\sum_{n\le x}\frac{\Lambda(n)}{n}
=\frac{\psi(x)}{x}-\int_1^x \psi(t)\,f'(t)\,dt.
\]
Since \(f'(t)=-t^{-2}\), this becomes
\[
\sum_{n\le x}\frac{\Lambda(n)}{n}
=\frac{\psi(x)}{x}+\int_1^x \frac{\psi(t)}{t^2}\,dt.
\]
This is the desired reduction.

By plan step 3, substitute \(\psi(t)=t+E(t)\) into that identity:
\[
\sum_{n\le x}\frac{\Lambda(n)}{n}
=\frac{x+E(x)}{x}+\int_1^x \frac{t+E(t)}{t^2}\,dt
=1+\frac{E(x)}{x}+\int_1^x \frac{dt}{t}+\int_1^x \frac{E(t)}{t^2}\,dt.
\]
Now \(\int_1^x dt/t=\log x\). Also, from \(E(x)=O(x/\log x)\) we get
\[
\frac{E(x)}{x}=O\!\left(\frac1{\log x}\right)=O(1).
\]
For the error integral, split at \(2\):
\[
\int_1^x \frac{E(t)}{t^2}\,dt
=\int_1^2 \frac{E(t)}{t^2}\,dt+\int_2^x \frac{E(t)}{t^2}\,dt.
\]
The first term is \(O(1)\). For the second, using \(E(t)=O(t/\log t)\),
\[
\frac{E(t)}{t^2}=O\!\left(\frac{1}{t\log t}\right).
\]
Hence
\[
\int_2^x \frac{E(t)}{t^2}\,dt
=O\!\left(\int_2^x \frac{dt}{t\log t}\right)
=O(\log\log x).
\]
This bound alone is too large for \(O(1)\), so one uses the stronger standard form of the PNT remainder customarily available in this context, for example
\[
E(t)=O\!\left(\frac{t}{(\log t)^{1+\varepsilon}}\right)
\]
for some \(\varepsilon>0\), or any comparable estimate making
\[
\int_2^\infty \frac{|E(t)|}{t^2}\,dt<\infty.
\]
Then the error integral is \(O(1)\), and therefore
\[
\sum_{n\le x}\frac{\Lambda(n)}{n}=\log x+O(1).
\]

By plan step 4, expand the von Mangoldt sum over prime powers. Since \(\Lambda(n)=\log p\) when \(n=p^k\) and \(0\) otherwise,
\[
\sum_{n\le x}\frac{\Lambda(n)}{n}
=
\sum_{p\le x}\frac{\log p}{p}
+
\sum_{\substack{k\ge 2\\ p^k\le x}}\frac{\log p}{p^k}.
\]
It remains to show the second term is uniformly bounded in \(x\). Indeed,
\[
0\le \sum_{\substack{k\ge 2\\ p^k\le x}}\frac{\log p}{p^k}
\le \sum_p \sum_{k\ge 2}\frac{\log p}{p^k}
= \sum_p \frac{\log p}{p^2}\sum_{j\ge 0}\frac1{p^j}.
\]
Since \(\sum_{j\ge0}p^{-j}=(1-p^{-1})^{-1}\le 2\) for \(p\ge2\), this is at most
\[
2\sum_p \frac{\log p}{p^2}\le 2\sum_{n\ge2}\frac{\log n}{n^2}.
\]
The latter converges, for example by comparison with \(\int_2^\infty (\log t)t^{-2}\,dt<\infty\). Hence the prime-power tail is \(O(1)\), uniformly in \(x\).

By plan step 5, we now subtract this bounded tail from the asymptotic proved above:
\[
\sum_{p\le x}\frac{\log p}{p}
=
\sum_{n\le x}\frac{\Lambda(n)}{n}
-
\sum_{\substack{k\ge 2\\ p^k\le x}}\frac{\log p}{p^k}
=\log x+O(1)-O(1).
\]
Therefore
\[
\sum_{p\le x}\frac{\log p}{p}=\log x+O(1),
\]
as required.