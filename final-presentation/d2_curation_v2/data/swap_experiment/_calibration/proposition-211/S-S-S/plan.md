1. For every tail index \(N\), prove the pointwise tail bounds
   \[
   sSup(x(\{n\ge N\}))\cdot sSup(y(\{n\ge N\})) \;\ge\; sSup((xy)(\{n\ge N\}))
   \]
   and
   \[
   sInf((xy)(\{n\ge N\})) \;\ge\; sInf(x(\{n\ge N\}))\cdot sInf(y(\{n\ge N\})),
   \]
   using nonnegativity and the fact that every tail of \(x\) and \(y\) is bounded.

2. Show that taking \(\inf_N\) of the first tail inequality yields
   \[
   \seqLimsup(xy)\le \seqLimsup(x)\,\seqLimsup(y).
   \]
   This requires comparing the infimum of the products of tail suprema with the product of the two infima.

3. Prove the general order fact for any sequence \(u_n\):
   \[
   \seqLimsup(u)\ge \seqLiminf(u),
   \]
   by showing for each \(N\) that the tail supremum is at least the tail infimum, and then passing to \(\inf_N\) and \(\sup_N\).

4. Show that taking \(\sup_N\) of the second tail inequality yields
   \[
   \seqLiminf(xy)\ge \seqLiminf(x)\,\seqLiminf(y).
   \]
   This requires comparing the supremum of the products of tail infima with the product of the two suprema.

5. Combine the three previously obtained inequalities in the required conjunction order:
   \[
   \seqLimsup x\,\seqLimsup y \ge \seqLimsup(xy),\qquad
   \seqLimsup(xy)\ge \seqLiminf(xy),\qquad
   \seqLiminf(xy)\ge \seqLiminf x\,\seqLiminf y.
   \]