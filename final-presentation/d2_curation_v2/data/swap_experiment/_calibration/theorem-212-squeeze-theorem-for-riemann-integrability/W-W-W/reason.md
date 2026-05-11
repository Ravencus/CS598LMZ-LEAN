By plan step 1, assume \(f\) is Riemann integrable on \([a,b]\), and for each \(\varepsilon>0\) take the trivial witnesses \(\alpha_\varepsilon=f\) and \(\beta_\varepsilon=f\). Then \(\alpha_\varepsilon\) and \(\beta_\varepsilon\) are integrable by assumption, the pointwise inequalities \(\alpha_\varepsilon\le f\le \beta_\varepsilon\) are equalities, and the gap integral is \(0\), so certainly \(<\varepsilon\).

By plan step 2, assume the approximation property. Fix an arbitrary \(\varepsilon>0\), and choose interval/Riemann integrable \(\alpha,\beta\) with \(\alpha\le f\le \beta\) on \([a,b]\) and \(\left|\int_a^b(\beta-\alpha)\,dx\right|<\varepsilon\). Since \(\beta-\alpha\ge 0\), the absolute value is redundant, so the integral gap is actually nonnegative and \(<\varepsilon\).

By plan step 3, use monotonicity of the lower and upper Darboux integrals: from \(\alpha\le f\le \beta\) we get
\[
\underline{\int_a^b}\alpha \le \underline{\int_a^b} f \le \overline{\int_a^b} f \le \overline{\int_a^b}\beta.
\]
Because \(\alpha\) and \(\beta\) are integrable, their upper and lower integrals coincide with their ordinary integrals, so
\[
\overline{\int_a^b} f-\underline{\int_a^b} f
\le \overline{\int_a^b}\beta-\underline{\int_a^b}\alpha
= \int_a^b \beta\,dx-\int_a^b \alpha\,dx
= \int_a^b (\beta-\alpha)\,dx
<\varepsilon.
\]
Here the middle equality is linearity of the integral, and the last inequality is the hypothesis. Thus the upper and lower integrals of \(f\) can be made arbitrarily close.

By plan step 4, since \(\varepsilon>0\) was arbitrary, the above estimate forces \(\overline{\int_a^b} f=\underline{\int_a^b} f\). By the standard criterion that a function is interval/Riemann integrable exactly when its upper and lower integrals coincide, it follows that \(f\) is interval integrable on \([a,b]\), i.e. `IntervalIntegrable f volume a b`.