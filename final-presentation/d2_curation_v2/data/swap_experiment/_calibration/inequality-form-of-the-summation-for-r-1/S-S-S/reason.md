By plan step 1, define
\[
E(n):=\sum_{k=1}^n k^{-r}-\zeta(r)-\frac{1}{1-r}n^{1-r}-\frac12 n^{-r}+\frac{r}{12}n^{-r-1}.
\]
Then the stated formula is true by definition once we prove that this \(E(n)\) satisfies
\[
|E(n)|<\frac{r(r+1)(r+2)}{720\,n^{r+3}}
\qquad (n\ge 1).
\]
So it remains only to estimate this error term.

By plan step 2, since \(r>1\), the \(p\)-series \(\sum_{k\ge1}k^{-r}\) converges, hence \(\zeta(r)=\sum_{k=1}^\infty k^{-r}\). Therefore
\[
\sum_{k=1}^n k^{-r}-\zeta(r)
=-\sum_{k=n+1}^\infty k^{-r}.
\]
Thus \(E(n)\) is exactly the error obtained when approximating the tail
\[
\sum_{k=n+1}^\infty k^{-r}
\]
by its Euler–Maclaurin main terms.

By plan step 3, apply Euler–Maclaurin to \(f(x)=x^{-r}\) on \([n,\infty)\). This function is \(C^\infty\) on \((0,\infty)\), and for \(r>1\) its derivatives tend to \(0\) at infinity, so the endpoint terms at \(\infty\) vanish. The needed derivatives are
\[
f'(x)=-r x^{-r-1},\qquad
f''(x)=r(r+1)x^{-r-2},\qquad
f^{(3)}(x)=-r(r+1)(r+2)x^{-r-3}.
\]
Hence the standard Euler–Maclaurin formula with remainder after the \(B_2\)-term gives
\[
\sum_{k=n+1}^\infty f(k)
=\int_n^\infty f(x)\,dx-\frac12 f(n)-\frac1{12}f'(n)+R_n,
\]
where \(R_n\) is the Euler–Maclaurin remainder.

By plan step 4, each explicit term is easy to evaluate:
\[
\int_n^\infty x^{-r}\,dx
=\left[\frac{x^{1-r}}{1-r}\right]_{x=n}^{x=\infty}
=\frac{1}{r-1}n^{1-r}
=-\frac{1}{1-r}n^{1-r},
\]
because \(1-r<0\), so \(x^{1-r}\to0\) as \(x\to\infty\). Also,
\[
-\frac12 f(n)=-\frac12 n^{-r},
\qquad
-\frac1{12}f'(n)=\frac{r}{12}n^{-r-1}.
\]
Therefore
\[
\sum_{k=n+1}^\infty k^{-r}
=\frac{1}{r-1}n^{1-r}-\frac12 n^{-r}+\frac{r}{12}n^{-r-1}+R_n.
\]
Substituting this into
\[
\sum_{k=1}^n k^{-r}
=\zeta(r)-\sum_{k=n+1}^\infty k^{-r}
\]
gives exactly
\[
\sum_{k=1}^n k^{-r}
=\zeta(r)+\frac{1}{1-r}n^{1-r}+\frac12 n^{-r}-\frac{r}{12}n^{-r-1}-R_n.
\]
So \(E(n)=-R_n\).

By plan step 5, the standard Euler–Maclaurin remainder estimate yields
\[
|R_n|
\le \frac1{720}\sup_{x\ge n}|f^{(3)}(x)|.
\]
Since \(r>1\), the function \(x\mapsto x^{-r-3}\) is decreasing on \([n,\infty)\), so
\[
\sup_{x\ge n}|f^{(3)}(x)|
=r(r+1)(r+2)\sup_{x\ge n}x^{-r-3}
=r(r+1)(r+2)n^{-r-3}.
\]
Hence
\[
|E(n)|=|R_n|
<\frac{r(r+1)(r+2)}{720\,n^{r+3}},
\]
which is the claimed bound. This proves the identity and the stated remainder estimate for every \(n\ge1\).