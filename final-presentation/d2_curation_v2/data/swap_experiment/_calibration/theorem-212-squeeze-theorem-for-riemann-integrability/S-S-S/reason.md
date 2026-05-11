By plan step 1, the forward implication is immediate. If \(f\) is Riemann integrable on \([a,b]\), then for any \(\varepsilon>0\) we may choose
\[
\alpha_\varepsilon=\beta_\varepsilon=f.
\]
These are Riemann integrable, satisfy \(\alpha_\varepsilon\le f\le \beta_\varepsilon\), and
\[
\int_a^b (\alpha_\varepsilon-\beta_\varepsilon)\,dx=\int_a^b 0\,dx=0,
\]
so
\[
\left|\int_a^b \alpha_\varepsilon(x)-\beta_\varepsilon(x)\,dx\right|=0<\varepsilon.
\]

For the converse, fix \(\varepsilon>0\) and suppose we are given Riemann integrable functions \(\alpha,\beta\) with \(\alpha\le f\le \beta\) on \([a,b]\). By plan step 2, since sums and scalar multiples of Riemann integrable functions are Riemann integrable, \(\beta-\alpha\) is Riemann integrable. Also \(\alpha(x)\le \beta(x)\) for every \(x\), so \((\beta-\alpha)(x)\ge 0\) pointwise on \([a,b]\).

By plan step 3, because \(\beta-\alpha\ge 0\), its integral is nonnegative; this is the standard monotonicity/positivity fact for the Riemann integral. Moreover,
\[
\alpha-\beta=-(\beta-\alpha),
\]
so by linearity,
\[
\int_a^b (\alpha-\beta)\,dx=-\int_a^b (\beta-\alpha)\,dx.
\]
Since the right-hand side is \(\le 0\), taking absolute values gives
\[
\left|\int_a^b (\alpha-\beta)\,dx\right|
=\int_a^b (\beta-\alpha)\,dx.
\]
Thus the hypothesis of the theorem is exactly saying that for every \(\varepsilon>0\) there are integrable bounds \(\alpha\le f\le \beta\) with arbitrarily small gap integral
\[
\int_a^b (\beta-\alpha)\,dx<\varepsilon.
\]

By plan step 4, we prove the key criterion. Assume that for every \(\varepsilon>0\) there exist Riemann integrable \(\alpha,\beta\) such that \(\alpha\le f\le \beta\) and
\[
\int_a^b(\beta-\alpha)\,dx<\varepsilon.
\]
Let \(\underline{\int_a^b} f\) and \(\overline{\int_a^b} f\) denote the lower and upper Riemann integrals of \(f\). From \(\alpha\le f\le \beta\), monotonicity of lower and upper integrals gives
\[
\int_a^b \alpha\,dx \le \underline{\int_a^b} f \le \overline{\int_a^b} f \le \int_a^b \beta\,dx,
\]
because \(\alpha\) and \(\beta\) are themselves Riemann integrable, so their lower and upper integrals equal their usual integrals. Hence
\[
0\le \overline{\int_a^b} f-\underline{\int_a^b} f
\le \int_a^b \beta\,dx-\int_a^b \alpha\,dx
= \int_a^b (\beta-\alpha)\,dx
<\varepsilon,
\]
using linearity of the Riemann integral. Since this holds for every \(\varepsilon>0\), we must have
\[
\overline{\int_a^b} f-\underline{\int_a^b} f=0,
\]
so the upper and lower Riemann integrals coincide. Therefore \(f\) is Riemann integrable.

Finally, by plan step 5, the theorem’s hypothesis provides exactly the bounds required in the criterion of plan step 4, thanks to plan steps 2 and 3 turning
\[
\left|\int_a^b (\alpha-\beta)\,dx\right|<\varepsilon
\]
into
\[
\int_a^b (\beta-\alpha)\,dx<\varepsilon.
\]
Applying the criterion, \(f\) is Riemann integrable. This proves the reverse implication, and hence the equivalence.