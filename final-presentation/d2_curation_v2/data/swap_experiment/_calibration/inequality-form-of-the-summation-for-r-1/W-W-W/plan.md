1. Specialize the Euler–Maclaurin summation formula to \(f(x)=x^{-r}\) on \([1,n]\), obtaining an expression for \(\sum_{k=1}^n k^{-r}\) as the corresponding integral plus endpoint corrections and a remainder term.

2. Compute the explicit main terms for \(f(x)=x^{-r}\): the integral \(\int_1^n x^{-r}\,dx\), the first endpoint correction \(\tfrac12(n^{-r}+1)\), and the next Bernoulli correction \(-\tfrac{r}{12}n^{-r-1}\), then rearrange them into the displayed form involving \(\zeta(r)\).

3. Isolate the leftover term as a function \(E(n)\) defined by the difference between the partial sum and the explicit main expansion, so that the required identity holds by construction.

4. Bound the Euler–Maclaurin remainder for \(f(x)=x^{-r}\) using the fourth derivative \(f^{(4)}(x)=r(r+1)(r+2)(r+3)x^{-r-4}\) together with \(n\ge 1\), yielding the estimate \(\lvert E(n)\rvert < \frac{r(r+1)(r+2)}{720\,n^{r+3}}\).