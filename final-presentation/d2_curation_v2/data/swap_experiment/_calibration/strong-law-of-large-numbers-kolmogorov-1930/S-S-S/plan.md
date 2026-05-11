1. Define the centered variables \(Y_i := X_i - \mu\), and show that \((Y_i)\) is still i.i.d., integrable, and has mean \(E(Y_1)=0\).

2. Prove the zero-mean strong law for the centered sequence: for almost every \(\omega\),
   \[
   \frac{1}{n}\sum_{k=1}^n Y_k(\omega)\to 0.
   \]

3. Relate the centered partial sums to the original ones by the identity
   \[
   \sum_{k=1}^n Y_k = \sum_{k=1}^n X_k - n\mu,
   \]
   hence
   \[
   \frac{1}{n}\sum_{k=1}^n Y_k = \frac{S_n}{n}-\mu.
   \]

4. Deduce from the convergence in Step 2 and the identity in Step 3 that for almost every \(\omega\),
   \[
   \frac{S_n(\omega)}{n}\to \mu.
   \]

5. Reconcile the indexing convention in the formal statement, namely that
   \[
   \text{partialSums }X\,(n+1)=\sum_{k=1}^{n+1}X_k,
   \]
   so the almost-everywhere limit above is exactly the asserted convergence of
   \[
   \frac{\text{partialSums }X\,(n+1)}{n+1}.
   \]