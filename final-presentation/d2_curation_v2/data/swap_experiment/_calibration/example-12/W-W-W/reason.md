By plan step 1, we use the standard density statement for the sequence \(n \mapsto n \bmod 2\pi\): since \(2\pi\) is irrationally related to \(1\), the set \(\{n \bmod 2\pi : n \in \mathbb N\}\) is dense in \([0,2\pi]\) (a Kronecker-type density theorem, in Mathlib style obtained from irrationality of \(2\pi\) and density of integer multiples modulo a period). Because \(\sin\) is continuous on \([0,2\pi]\) and its image there is exactly \([-1,1]\), the image of a dense set under \(\sin\) is dense in \([-1,1]\). In particular, every nonempty open subinterval of \((-1,1)\) contains some value \(\sin n\).

By plan step 2, to show that \(1\) is a cluster point, fix \(k\in\mathbb N\). The interval \((1-\tfrac1k,\,1)\) is a nonempty open subinterval of \((-1,1)\), so by density there exists \(n_k\) with
\[
1-\frac1k<\sin(n_k)<1.
\]
Thus \(\sin(n_k)\to 1\) from below, since \(0<1-\sin(n_k)<\frac1k\to 0\). Therefore \(1\) is a cluster point of \((\sin n)\).

By plan step 3, similarly, for each \(k\) the interval \((-1,\,-1+\tfrac1k)\) is a nonempty open subinterval of \((-1,1)\), so density gives some \(m_k\) such that
\[
-1<\sin(m_k)<-1+\frac1k.
\]
Hence \(0<\sin(m_k)+1<\frac1k\to 0\), so \(\sin(m_k)\to -1\). Therefore \(-1\) is also a cluster point.

By plan step 4, every cluster point of \((\sin n)\) lies in \([-1,1]\). Indeed, for every \(n\) we have the pointwise bound
\[
-1 \le \sin n \le 1,
\]
by the standard sine bounds (`Real.neg_one_le_sin` and `Real.sin_le_one` in Mathlib style). Since \([-1,1]\) is closed, any limit of a subsequence of \((\sin n)\) must also lie in \([-1,1]\).

By plan step 5, the cluster-point set is contained in \([-1,1]\) and contains both endpoints \(1\) and \(-1\). Therefore its supremum is \(1\) and its infimum is \(-1\). By the definitions of sequence limsup and liminf as the supremum and infimum of the set of cluster points, it follows that
\[
\operatorname{seqLimsup}(\sin n)=1,\qquad \operatorname{seqLiminf}(\sin n)=-1.
\]