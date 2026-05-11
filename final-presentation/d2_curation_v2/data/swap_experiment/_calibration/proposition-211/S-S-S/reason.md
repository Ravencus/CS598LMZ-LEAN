By plan step 1, fix a tail index \(N\). Write
\[
X_N:=\sup\{x_n:n\ge N\},\qquad Y_N:=\sup\{y_n:n\ge N\},
\]
and similarly
\[
I_N:=\inf\{x_n:n\ge N\},\qquad J_N:=\inf\{y_n:n\ge N\}.
\]
These suprema and infima exist because the sequences are bounded and nonnegative, so every tail is a nonempty bounded subset of \(\mathbb R\). For every \(n\ge N\), we have \(x_n\le X_N\) and \(y_n\le Y_N\); since all quantities are \(\ge 0\), multiplying preserves order, so
\[
x_ny_n\le X_NY_N
\]
(by monotonicity of multiplication on nonnegative reals, as in `mul_le_mul`). Thus \(X_NY_N\) is an upper bound for the tail \(\{x_ny_n:n\ge N\}\), hence
\[
\sup\{x_ny_n:n\ge N\}\le X_NY_N.
\]
Likewise, for every \(n\ge N\), \(I_N\le x_n\) and \(J_N\le y_n\), and again nonnegativity gives
\[
I_NJ_N\le x_ny_n.
\]
So \(I_NJ_N\) is a lower bound for the tail of \(x_ny_n\), hence
\[
\inf\{x_ny_n:n\ge N\}\ge I_NJ_N.
\]

By plan step 2, apply \(\inf_N\) to the first tail inequality. Since
\[
\seqLimsup(xy)=\inf_N \sup\{x_ny_n:n\ge N\},
\]
we get
\[
\seqLimsup(xy)\le \inf_N(X_NY_N).
\]
It remains to compare this infimum with the product of the two infima. Let
\[
a:=\inf_N X_N=\seqLimsup(x),\qquad b:=\inf_N Y_N=\seqLimsup(y).
\]
For every \(N\), \(a\le X_N\) and \(b\le Y_N\), and all terms are nonnegative, so \(ab\le X_NY_N\) by `mul_le_mul`. Hence \(ab\) is a lower bound for the set \(\{X_NY_N:N\in\mathbb N\}\), so
\[
ab\le \inf_N(X_NY_N).
\]
This inequality alone points the wrong way for the desired conclusion, so instead use the monotone-tail structure: given \(\varepsilon>0\), choose \(N_1,N_2\) with \(X_{N_1}<a+\varepsilon\) and \(Y_{N_2}<b+\varepsilon\) by the defining property of an infimum. For \(N=\max(N_1,N_2)\), the tail suprema decrease with \(N\), so \(X_N\le X_{N_1}<a+\varepsilon\) and \(Y_N\le Y_{N_2}<b+\varepsilon\). Therefore
\[
\inf_N(X_NY_N)\le X_NY_N\le (a+\varepsilon)(b+\varepsilon).
\]
Letting \(\varepsilon\to 0\) gives
\[
\inf_N(X_NY_N)\le ab,
\]
hence
\[
\seqLimsup(xy)\le \seqLimsup(x)\,\seqLimsup(y).
\]

By plan step 3, for any sequence \(u_n\) and any \(N\), the tail supremum is at least the tail infimum:
\[
\sup\{u_n:n\ge N\}\ge \inf\{u_n:n\ge N\},
\]
since every upper bound is above every lower bound. Taking \(\inf_N\) on the left and \(\sup_N\) on the right preserves this comparison, yielding
\[
\seqLimsup(u)=\inf_N\sup\{u_n:n\ge N\}\ge \sup_N\inf\{u_n:n\ge N\}=\seqLiminf(u).
\]
Applying this to \(u_n=x_ny_n\) gives
\[
\seqLimsup(xy)\ge \seqLiminf(xy).
\]

By plan step 4, apply \(\sup_N\) to the second tail inequality from step 1:
\[
\seqLiminf(xy)=\sup_N \inf\{x_ny_n:n\ge N\}\ge \sup_N(I_NJ_N).
\]
Let
\[
c:=\sup_N I_N=\seqLiminf(x),\qquad d:=\sup_N J_N=\seqLiminf(y).
\]
The tail infima \(I_N,J_N\) are increasing in \(N\). Given \(\varepsilon>0\), choose \(N_1,N_2\) with \(I_{N_1}>c-\varepsilon\) and \(J_{N_2}>d-\varepsilon\) by the defining property of a supremum. For \(N=\max(N_1,N_2)\), monotonicity gives \(I_N\ge I_{N_1}>c-\varepsilon\) and \(J_N\ge J_{N_2}>d-\varepsilon\), hence
\[
\sup_N(I_NJ_N)\ge I_NJ_N\ge (c-\varepsilon)(d-\varepsilon).
\]
Letting \(\varepsilon\to 0\) yields
\[
\sup_N(I_NJ_N)\ge cd,
\]
so
\[
\seqLiminf(xy)\ge \seqLiminf(x)\,\seqLiminf(y).
\]

By plan step 5, combining the inequalities proved in steps 2, 3, and 4 gives
\[
\seqLimsup(x)\,\seqLimsup(y)\ge \seqLimsup(xy)\ge \seqLiminf(xy)\ge \seqLiminf(x)\,\seqLiminf(y),
\]
which is exactly the claimed chain.