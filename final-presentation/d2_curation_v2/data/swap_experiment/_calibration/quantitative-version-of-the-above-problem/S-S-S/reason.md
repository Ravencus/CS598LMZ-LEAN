By plan step 1, we first rewrite the prime reciprocal sum by Abel (partial) summation. If \(A(t):=\sum_{p\le t}1=\pi(t)\) and \(f(t)=1/t\), then the standard summation-by-parts formula gives
\[
\sum_{p\le x}\frac1p
= \pi(x)\frac1x-\pi(2)\frac12-\int_2^x \pi(t)\,f'(t)\,dt.
\]
Since \(f'(t)=-1/t^2\), this becomes
\[
\sum_{p\le x}\frac1p
= \frac{\pi(x)}{x}+\int_2^x \frac{\pi(t)}{t^2}\,dt+O(1),
\]
because the lower-end contribution \(-\pi(2)/2\) is an absolute constant. Thus the problem is reduced to estimating the integral involving \(\pi(t)\).

By plan step 2, we insert the Prime Number Theorem in the form
\[
\pi(t)=\frac{t}{\log t}+O\!\left(\frac{t}{\log^2 t}\right)
\qquad (t\ge 2).
\]
Dividing by \(t^2\) is legitimate since \(t>0\) on \([2,x]\) (compare `lt_of_lt_of_le` with `by positivity`, or analytically just \(t\ge2\)). Hence
\[
\frac{\pi(t)}{t^2}
=\frac{1}{t\log t}+O\!\left(\frac{1}{t\log^2 t}\right).
\]
Indeed, if \(\pi(t)=\frac{t}{\log t}+E(t)\) with \(|E(t)|\le C\, t/\log^2 t\), then
\[
\left|\frac{E(t)}{t^2}\right|\le \frac{C}{t\log^2 t}.
\]

By plan step 3, the main term integrates exactly. Since \(\log t>0\) for \(t\ge2\) (for instance because \(2>1\) and \(\log\) is increasing on \((0,\infty)\)), the function \(u=\log t\) is valid as a substitution, and
\[
\int_2^x \frac{dt}{t\log t}
= \int_{\log 2}^{\log x}\frac{du}{u}
= \log\log x-\log\log 2.
\]
Equivalently, one may differentiate \(\log\log t\) and use that
\[
\frac{d}{dt}\log\log t=\frac1{t\log t}
\]
for \(t>1\).

By plan step 4, the error term contributes only a bounded amount. Indeed,
\[
\int_2^x O\!\left(\frac1{t\log^2 t}\right)\,dt
=O\!\left(\int_2^x \frac{dt}{t\log^2 t}\right).
\]
But
\[
\frac{d}{dt}\Bigl(-\frac1{\log t}\Bigr)=\frac1{t\log^2 t},
\]
so
\[
\int_2^x \frac{dt}{t\log^2 t}
= \frac1{\log 2}-\frac1{\log x}
\le \frac1{\log 2}.
\]
Hence this integral is \(O(1)\), uniformly in \(x\ge2\). Also,
\[
\frac{\pi(x)}{x}
=\frac1{\log x}+O\!\left(\frac1{\log^2 x}\right)
=O\!\left(\frac1{\log x}\right),
\]
so in particular it is bounded for \(x\ge2\).

By plan step 5, combining the decomposition from step 1 with the estimates from steps 2–4 gives
\[
\sum_{p\le x}\frac1p
= \frac{\pi(x)}{x}
+ \int_2^x \frac{dt}{t\log t}
+ \int_2^x O\!\left(\frac1{t\log^2 t}\right)\,dt
+O(1).
\]
Therefore
\[
\sum_{p\le x}\frac1p
= \log\log x - \log\log 2 + O(1)+O(1/\log x),
\]
and since both \(-\log\log 2\) and \(O(1/\log x)\) are absorbed into \(O(1)\), we conclude
\[
\sum_{p\le x}\frac1p=\log\log x+O(1).
\]
Equivalently, \(\sum_{p\le x}\frac1p-\log\log x\) remains bounded by an absolute constant for all \(x\ge2\).