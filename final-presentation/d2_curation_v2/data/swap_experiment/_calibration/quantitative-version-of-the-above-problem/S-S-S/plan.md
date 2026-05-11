1. Show that the prime reciprocal sum can be compared to the Stieltjes/partial-summation expression
   \[
   \sum_{p \le x}\frac1p \;=\; \frac{\pi(x)}{x} \;+\; \int_2^x \frac{\pi(t)}{t^2}\,dt \;+\; O(1),
   \]
   or an equivalent Abel summation formula reducing the problem to estimating an integral involving \(\pi(t)\).

2. Use the Prime Number Theorem in the form
   \[
   \pi(t)=\frac{t}{\log t}+O\!\left(\frac{t}{\log^2 t}\right)
   \]
   (for \(t\ge 2\)) to rewrite the integrand as
   \[
   \frac{\pi(t)}{t^2}=\frac{1}{t\log t}+O\!\left(\frac{1}{t\log^2 t}\right).
   \]

3. Prove that the main term integrates to the logarithmic main term:
   \[
   \int_2^x \frac{dt}{t\log t} = \log\log x - \log\log 2.
   \]

4. Prove that the error term is uniformly bounded:
   \[
   \int_2^x O\!\left(\frac{1}{t\log^2 t}\right)\,dt = O(1),
   \]
   and also that the boundary term \(\pi(x)/x\) is \(O(1/\log x)\), hence bounded for \(x\ge 2\).

5. Combine the previous steps to conclude that
   \[
   \sum_{p\le x}\frac1p - \log\log x
   \]
   stays within an absolute constant for all \(x\ge 2\).