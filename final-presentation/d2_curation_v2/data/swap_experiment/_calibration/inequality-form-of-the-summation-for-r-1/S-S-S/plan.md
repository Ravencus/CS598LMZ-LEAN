1. Define the error term by isolating the claimed main terms:
   \[
   E(n):=\sum_{k=1}^n k^{-r}-\zeta(r)-\frac{1}{1-r}n^{1-r}-\frac12 n^{-r}+\frac{r}{12}n^{-r-1},
   \]
   and reduce the goal to proving this choice of \(E(n)\) satisfies the stated identity and bound for every \(n\ge 1\).

2. Rewrite the finite sum against \(\zeta(r)\) as a tail:
   \[
   \sum_{k=1}^n k^{-r}-\zeta(r)=-\sum_{k=n+1}^\infty k^{-r},
   \]
   using convergence of \(\sum_{k\ge1} k^{-r}\) for \(r>1\), so the problem becomes an asymptotic expansion for the tail \(\sum_{k=n+1}^\infty k^{-r}\).

3. Apply the Euler–Maclaurin formula to \(f(x)=x^{-r}\) on \([n,\infty)\) (or equivalently to the tail starting at \(n+1\)), computing the needed derivatives
   \[
   f'(x)=-r x^{-r-1},\qquad f''(x)=r(r+1)x^{-r-2},\qquad f^{(3)}(x)=-r(r+1)(r+2)x^{-r-3},
   \]
   to obtain the expansion of the tail up to the \(f'(n)\) correction term.

4. Evaluate the explicit Euler–Maclaurin main terms for \(f(x)=x^{-r}\):
   \[
   \int_n^\infty x^{-r}\,dx=\frac{1}{r-1}n^{1-r}=-\frac{1}{1-r}n^{1-r},
   \]
   together with the endpoint correction \(\frac12 n^{-r}\) and the Bernoulli correction \(\frac{r}{12}n^{-r-1}\), and then translate these back to the stated formula for the partial sum.

5. Bound the Euler–Maclaurin remainder by the supremum/integral of \(|f^{(3)}(x)|\) on \([n,\infty)\), yielding
   \[
   |E(n)|<\frac{r(r+1)(r+2)}{720\,n^{r+3}},
   \]
   after simplifying the standard remainder constant and using \(n\ge1\) to justify all real-power terms.