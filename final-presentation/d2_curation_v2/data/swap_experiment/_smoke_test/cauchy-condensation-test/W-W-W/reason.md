By plan step 1, fix \(k\ge 0\) and consider the dyadic block
\[
B_k=\sum_{2^k\le n<2^{k+1}} a_n.
\]
There are exactly \(2^k\) integers in this interval. Since \((a_n)\) is nonincreasing, for every \(n\) with \(2^k\le n<2^{k+1}\) we have
\[
a_{2^{k+1}}\le a_n\le a_{2^k}.
\]
Using nonnegativity and summing these pointwise inequalities over the \(2^k\) indices in the block gives
\[
2^k\,a_{2^{k+1}}\le B_k\le 2^k\,a_{2^k}.
\]
This is the desired dyadic block estimate; the justification is just termwise comparison and summation of finitely many nonnegative terms, as in `Finset.sum_le_sum`.

By plan step 2, the original series \(\sum_{n\ge1} a_n\) is the sum of the block sums \(B_k\), since the dyadic intervals \([2^k,2^{k+1})\) partition \(\{1,2,3,\dots\}\). More precisely, the partial sum up to \(2^{m+1}-1\) is
\[
\sum_{n=1}^{2^{m+1}-1} a_n=\sum_{k=0}^{m} B_k.
\]
Because all terms are nonnegative, convergence of \(\sum_{n\ge1} a_n\) is equivalent to boundedness of its partial sums, and the displayed identity shows that this is equivalent to convergence of \(\sum_k B_k\). This is the standard regrouping argument for series with nonnegative terms, using `tsum_eq_tsum_of_reindex` only informally here, or equivalently the fact that monotone partial sums determine convergence for nonnegative series.

By plan step 3, compare \(\sum_k B_k\) with the condensation series \(\sum_k 2^k a_{2^k}\). The upper bound from step 1 gives
\[
B_k\le 2^k a_{2^k},
\]
so termwise the block series is dominated by the condensation series. For the reverse direction, apply the lower bound from step 1 to the next block:
\[
B_k \ge 2^k a_{2^{k+1}}.
\]
Reindex this as
\[
2^k a_{2^k}\le B_{k-1}\quad (k\ge 1),
\]
using monotonicity of \((a_n)\) and the shift \(k\mapsto k-1\). Thus each condensation term is controlled by a neighboring block sum. This one-step shift is the only extra ingredient needed to compare the two series.

By plan step 4, the comparison bounds now yield the two implications separately. If \(\sum_k 2^k a_{2^k}\) converges, then \(0\le B_k\le 2^k a_{2^k}\) for every \(k\), so the comparison test for nonnegative series (`summable_of_nonneg_of_le`) implies \(\sum_k B_k\) converges. Conversely, if \(\sum_k B_k\) converges, then for \(k\ge1\) we have \(0\le 2^k a_{2^k}\le B_{k-1}\), so the shifted comparison test shows \(\sum_k 2^k a_{2^k}\) converges as well. The finite initial term at \(k=0\) is irrelevant for convergence.

By plan step 5, combine the equivalence from step 2 with the equivalence from step 4: \(\sum_{n\ge1} a_n\) converges if and only if \(\sum_k B_k\) converges, and \(\sum_k B_k\) converges if and only if \(\sum_k 2^k a_{2^k}\) converges. Therefore
\[
\sum_{n\ge1} a_n \text{ converges } \iff \sum_{k\ge0} 2^k a_{2^k} \text{ converges},
\]
which is exactly the desired Cauchy condensation criterion.