1. Show that the two explicit sequences
   \[
   x_n=\frac{\pi}{2}+2\pi n,\qquad y_n=\frac{3\pi}{2}+2\pi n
   \]
   both tend to \(+\infty\) as \(n\to\infty\).

2. Use the \(2\pi\)-periodicity of \(\sin\) together with the special-angle values \(\sin(\pi/2)=1\) and \(\sin(3\pi/2)=-1\) to prove
   \[
   \sin(x_n)=1 \quad\text{and}\quad \sin(y_n)=-1
   \]
   for every \(n\), hence \(\sin(x_n)\to 1\) and \(\sin(y_n)\to -1\).

3. Prove the general upper and lower bounds along \(x\to\infty\):
   \[
   \limsup_{x\to\infty}\sin x \le 1,\qquad \liminf_{x\to\infty}\sin x \ge -1,
   \]
   using the pointwise estimate \(-1\le \sin x\le 1\) for all real \(x\).

4. Use the sequence \(x_n\to\infty\) with \(\sin(x_n)=1\) to show that \(1\) is attained as a subsequential limit at \(+\infty\), hence
   \[
   \limsup_{x\to\infty}\sin x \ge 1.
   \]

5. Use the sequence \(y_n\to\infty\) with \(\sin(y_n)=-1\) to show that \(-1\) is attained as a subsequential limit at \(+\infty\), hence
   \[
   \liminf_{x\to\infty}\sin x \le -1.
   \]

6. Combine the upper/lower bounds from Steps 3–5 to conclude
   \[
   \limsup_{x\to\infty}\sin x=1,\qquad \liminf_{x\to\infty}\sin x=-1,
   \]
   together with the two sequence convergence statements.