1. For a fixed \(f\), show the superlevel sets \(E_a:=\{x: |f(x)|>a\}\) are nested in \(a\): if \(a\le b\), then \(E_b\subseteq E_a\); deduce that \(\lambda_f(a)=\mu(E_a)\) is decreasing.

2. For a fixed \(f\) and \(a\in\mathbb R\), identify \(E_a\) as the decreasing intersection of the sets \(E_t\) with \(t>a\) and \(t\downarrow a\), namely
   \[
   E_a=\bigcap_{n}\{x:|f(x)|>a+\varepsilon_n\}
   \]
   for any \(\varepsilon_n\downarrow 0\); then use continuity from above of measure to get right-continuity of \(\lambda_f\) on \([a,\infty)\).

3. Show pointwise domination of absolute values gives inclusion of superlevel sets: if \(|f(x)|\le |g(x)|\) for all \(x\), then for every \(a\),
   \[
   \{x:|f(x)|>a\}\subseteq \{x:|g(x)|>a\},
   \]
   hence \(\lambda_f(a)\le \lambda_g(a)\).

4. For \(|f_n|\uparrow |f|\), prove that for each \(a\), the sets
   \[
   E_n(a):=\{x:|f_n(x)|>a\}
   \]
   are increasing in \(n\), and that
   \[
   \bigcup_n E_n(a)=\{x:|f(x)|>a\};
   \]
   then apply continuity from below of measure to obtain \(\lambda_{f_n}(a)\uparrow \lambda_f(a)\).

5. For \(f=g+h\), prove the set inclusion
   \[
   \{x:|f(x)|>a\}\subseteq \{x:|g(x)|>a/2\}\cup \{x:|h(x)|>a/2\}
   \]
   using the triangle inequality; then take measures and use subadditivity.

6. For \(f=gh\), prove the set inclusion
   \[
   \{x:|f(x)|>a\}\subseteq \{x:|g(x)|>\sqrt{a/2}\}\cup \{x:|h(x)|>\sqrt{a/2}\}
   \]
   by showing that if both \(|g(x)|\le \sqrt{a/2}\) and \(|h(x)|\le \sqrt{a/2}\), then \(|g(x)h(x)|\le a/2\); then take measures and use subadditivity.