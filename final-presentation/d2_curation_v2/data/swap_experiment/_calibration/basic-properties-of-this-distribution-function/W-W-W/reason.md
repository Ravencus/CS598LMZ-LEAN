By plan step 1, fix \(a_1 \le a_2\). Then \(\{x:|f(x)|>a_2\}\subseteq \{x:|f(x)|>a_1\}\), since a larger threshold is harder to exceed. Taking measures gives \(\lambda_f(a_2)\le \lambda_f(a_1)\), so \(a\mapsto \lambda_f(a)\) is decreasing.

By plan step 2, let \(a_n\downarrow a\). The sets \(E_n:=\{x:|f(x)|>a_n\}\) form a decreasing family, and
\[
\bigcap_n E_n=\{x:|f(x)|>a\},
\]
because \(|f(x)|>a\) holds iff \(|f(x)|>a_n\) for every \(n\) when \(a_n\to a\) from above. By continuity of measure from above,
\[
\lambda_f(a_n)=\mu(E_n)\to \mu\!\left(\bigcap_n E_n\right)=\lambda_f(a),
\]
so \(\lambda_f\) is right-continuous.

By plan step 3, assume \(|f(x)|\le |g(x)|\) for all \(x\). Then for every \(a\),
\[
\{x:|f(x)|>a\}\subseteq \{x:|g(x)|>a\},
\]
because \(|f(x)|>a\) forces \(|g(x)|\ge |f(x)|>a\). Taking measures yields \(\lambda_f(a)\le \lambda_g(a)\).

By plan step 4, suppose \(|f_n(x)|\uparrow |f(x)|\) pointwise. Fix \(a\), and set \(E_n=\{x:|f_n(x)|>a\}\). Since \(|f_n|\) increases in \(n\), the sets \(E_n\) also increase. Moreover,
\[
\bigcup_n E_n=\{x:|f(x)|>a\},
\]
because if \(|f(x)|>a\), then the increasing sequence \(|f_n(x)|\) eventually exceeds \(a\); conversely, if some \(|f_n(x)|>a\), then \(|f(x)|\ge |f_n(x)|>a\). Hence by continuity of measure from below,
\[
\lambda_{f_n}(a)=\mu(E_n)\uparrow \mu\!\left(\bigcup_n E_n\right)=\lambda_f(a).
\]

By plan step 5, use the triangle inequality:
\[
|g(x)+h(x)|\le |g(x)|+|h(x)|.
\]
Therefore, if both \(|g(x)|\le a/2\) and \(|h(x)|\le a/2\), then \(|g(x)+h(x)|\le a\). Contrapositively,
\[
\{x:|g(x)+h(x)|>a\}\subseteq \{x:|g(x)|>a/2\}\cup \{x:|h(x)|>a/2\}.
\]
Taking measures and using subadditivity gives
\[
\lambda_f(a)\le \lambda_g(a/2)+\lambda_h(a/2).
\]

By plan step 6, similarly, if \(|g(x)|\le \sqrt{a/2}\) and \(|h(x)|\le \sqrt{a/2}\), then
\[
|g(x)h(x)|\le \sqrt{a/2}\cdot \sqrt{a/2}=a/2<a.
\]
So contrapositively,
\[
\{x:|g(x)h(x)|>a\}\subseteq \{x:|g(x)|>\sqrt{a/2}\}\cup \{x:|h(x)|>\sqrt{a/2}\}.
\]
Again by subadditivity,
\[
\lambda_f(a)\le \lambda_g(\sqrt{a/2})+\lambda_h(\sqrt{a/2}).
\]