By plan step 1, apply the Euler–Maclaurin summation formula to \(f(x)=x^{-r}\) on the tail interval \([n,\infty)\). Since \(r>1\), the series \(\sum_{k\ge 1} կ^{-r}\) converges, so \(\zeta(r)\) is finite, and we may write
\[
\zeta(r)-\sum_{k=1}^n k^{-r}=\sum_{k=n+1}^\infty k^{-r}.
\]
Euler–Maclaurin expresses this tail as
\[
\sum_{k=n+1}^\infty k^{-r}
= \int_n^\infty x^{-r}\,dx+\frac12 n^{-r}-\frac1{12}f'(n)+R(n),
\]
with a remainder \(R(n)\) controlled by the fourth derivative; here \(f'(x)=-r x^{-r-1}\), so the Bernoulli correction is \(-\frac{r}{12}n^{-r-1}\).

By plan step 2, compute the explicit main terms. The integral is
\[
\int_n^\infty x^{-r}\,dx=\frac{n^{1-r}}{r-1}=-\frac{1}{1-r}n^{1-r},
\]
using \(r>1\). Therefore
\[
\sum_{k=n+1}^\infty k^{-r}
= -\frac{1}{1-r}n^{1-r}+\frac12 n^{-r}-\frac{r}{12}n^{-r-1}+R(n).
\]
Substituting this into \(\zeta(r)-\sum_{k=1}^n k^{-r}\) and rearranging gives
\[
\sum_{k=1}^n k^{-r}
=\zeta(r)+\frac{1}{1-r}n^{1-r}+\frac12 n^{-r}-\frac{r}{12}n^{-r-1}-R(n).
\]
This is exactly the displayed asymptotic form, with the remainder term absorbed into \(E_r(n)\).

By plan step 3, define
\[
E_r(n):=-R(n).
\]
Then the identity in the theorem holds by construction:
\[
\sum_{k=1}^n k^{-r}=\zeta(r)+\frac{1}{1-r}n^{1-r}+\frac12 n^{-r}-\frac{r}{12}n^{-r-1}+E_r(n).
\]

By plan step 4, bound the Euler–Maclaurin remainder. For \(f(x)=x^{-r}\),
\[
f^{(4)}(x)=r(r+1)(r+2)(r+3)x^{-r-4}.
\]
The standard remainder estimate gives
\[
|R(n)|\le \frac1{720}\int_n^\infty |f^{(4)}(x)|\,dx
= \frac{r(r+1)(r+2)(r+3)}{720}\int_n^\infty x^{-r-4}\,dx.
\]
Since \(r>1\), the integral converges, and
\[
\int_n^\infty x^{-r-4}\,dx=\frac{1}{r+3}n^{-r-3}.
\]
Hence
\[
|E_r(n)|=|R(n)|<\frac{r(r+1)(r+2)}{720\,n^{r+3}}.
\]
This is the required bound.