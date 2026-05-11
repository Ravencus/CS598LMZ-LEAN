By plan step 1, fix any \(y\in(-1,1)\). Write \(t=\arcsin(y)\), so \(t\in(-\pi/2,\pi/2)\) and \(\sin t=y\). Since \(2\pi\) is irrational, the orbit of the irrational rotation \(n\mapsto n \bmod 2\pi\) is dense in \([0,2\pi)\); equivalently, the set \(\{n-2\pi m:n,m\in\mathbb N\}\) comes arbitrarily close to any prescribed \(t\) modulo \(2\pi\). Hence for every \(k\ge1\) there exists \(n_k\in\mathbb N\) such that
\[
|n_k-(t+2\pi m_k)|<1/k
\]
for some integer \(m_k\). Therefore, using \(2\pi\)-periodicity of \(\sin\),
\[
|\sin(n_k)-y|
=|\sin(n_k)-\sin t|
\le |n_k-(t+2\pi m_k)|
<1/k,
\]
where the inequality is the standard Lipschitz estimate \(|\sin a-\sin b|\le |a-b|\), obtained for instance from the mean value theorem and \(|\cos|\le 1\). So \(\sin(n_k)\to y\). Thus every \(y\in(-1,1)\) is an accumulation point of the sequence \((\sin n)\), i.e. \(\{\sin n:n\in\mathbb N\}\) is dense in \((-1,1)\).

By plan step 2, if \(y\) is any accumulation point of \((\sin n)\), then there is a subsequence \(\sin(n_k)\to y\). But \(-1\le \sin(n_k)\le 1\) for every \(k\), since \(\sin\) takes values in \([-1,1]\). Passing to the limit in these inequalities gives \(-1\le y\le 1\). Thus every accumulation point lies in \([-1,1]\).

By plan step 3, for each \(k\ge2\), the number \(y_k:=1-\frac1k\) lies in \((-1,1)\), so by plan step 1 it is an accumulation point of \((\sin n)\). Also \(y_k\to 1\). The set of accumulation points of a sequence in \(\mathbb R\) is closed (equivalently: a limit of accumulation points is again an accumulation point, by a diagonal subsequence argument). Hence \(1\) is an accumulation point of \((\sin n)\).

By plan step 4, the same argument with \(z_k:=-1+\frac1k\in(-1,1)\) shows that each \(z_k\) is an accumulation point by plan step 1, that \(z_k\to -1\), and therefore that \(-1\) is an accumulation point as well.

By plan step 5, the set \(A\) of accumulation points of \((\sin n)\) is contained in \([-1,1]\) by plan step 2, and it contains both endpoints \(-1\) and \(1\) by plan steps 3 and 4. Therefore \(1\) is an upper bound for \(A\), and since \(1\in A\), it is the least upper bound: \(\sup A=1\). Similarly, \(-1\) is a lower bound for \(A\), and since \(-1\in A\), it is the greatest lower bound: \(\inf A=-1\).

By plan step 6, `seqLimsup` is by definition the supremum of the set of accumulation points, and `seqLiminf` is the infimum of that set. Applying this to \(x_n=\sin n\) and using plan step 5, we obtain
\[
\limsup_{n\to\infty}\sin n=1,
\qquad
\liminf_{n\to\infty}\sin n=-1.
\]
This is exactly the desired conclusion.