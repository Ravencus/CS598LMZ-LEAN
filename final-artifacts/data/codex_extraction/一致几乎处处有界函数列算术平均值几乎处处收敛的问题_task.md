You are a mathematics knowledge extraction agent. Given a mathematics note written in Chinese, extract structured information.

## Output Format (JSON)
```json
{
  "note_title": "<title>",
  "classification": "<one of: problem, technique, theory, example_collection>",
  "summary_en": "<1-2 sentence English summary of what this note is about>",
  "problems": [
    {
      "id": "<note_title_short>-<number>",
      "statement_en": "<problem statement translated to English>",
      "statement_zh": "<original problem statement in Chinese>",
      "type": "<one of: theorem, lemma, exercise, example, counterexample, definition>",
      "difficulty": "<one of: easy, medium, hard>",
      "domain": "<math domain in English, e.g. real analysis, probability, number theory>",
      "key_techniques": ["<technique 1>", "<technique 2>"],
      "prerequisites": ["<prerequisite concept 1>"]
    }
  ],
  "key_techniques_discussed": ["<technique 1 in English>"],
  "connections_mentioned": ["<related topic 1>"]
}
```

## Rules
1. Extract ALL distinct problems, theorems, lemmas, and exercises from the note.
2. Translate mathematical statements accurately to English. Keep mathematical notation intact.
3. For technique notes (no specific problems), set classification to "technique" and list the techniques in key_techniques_discussed.
4. Be concise but precise in summaries and translations.
5. Output ONLY the JSON, no other text.

## Note Content
---
tags:
  - math
  - 实分析
  - 大学数学竞赛
---

> [!note] 命题0，CMC数学组高年级决赛题目
> $(X,\Omega,\mu)$是一个测度空间，$f_n$是$X$上一列几乎处处一致有界的可测函数列。令$A_N(x):=\frac{1}{N}\sum_{n\leq N} f_n(x)$那么$$\sum_{N\geq 1} \frac{1}{N}\int_X A_{N}^{2}(x)\,d\mu <\infty\implies A_N(x)\xrightarrow{a.e.}{0}$$

这个命题在形式上和Kolmogorov的强大数定律非常类似：

> [!note] Kolmogorov强大数定律
> 设$X_n$是概率空间上的一列独立的随机变量（不要求同分布），其期望为0，方差有限，并且额外满足$$\sum_{n\geq 1} \frac{V(X_n)}{n^2}<+\infty$$那么随机变量$\frac{X_1+\cdots+X_n}{n}$几乎处处收敛到0。

只要我们换一个角度来看待，我们就能发现二者的相似之处。令$$Y_n:=\frac{X_1+\cdots+X_n}{n}$$然后由于随机变量$X_n$的独立性$$\begin{aligned}\sum_{N\geq 1} \frac{1}{N}\int Y_N^2\,dP&= \sum_{N\geq 1} \frac{E(Y_N^2)}{N}\\&= \sum_{N\geq 1} \frac{V(Y_N)}{N}\\&=\sum_{N\geq 1} \frac{1}{N}\cdot \frac{1}{N^2}\sum_{n\leq N}V(X_n)\\&= \sum_{n\geq 1}\left(\sum_{N\geq n}\frac{1}{N^3}\right)V(X_n)\end{aligned}$$其中由于$\sum_{N\geq n}\frac{1}{N^3}\asymp \frac{1}{n^2}$于是$$\sum_{N\geq 1} \frac{1}{N}\int Y_N^2\,dP<\infty \iff \sum_{n\geq 1} \frac{V(X_n)}{n^2}<\infty$$

### 1. Borel-Cantelli引理的解决方案

> [!error] 1.1:直接尝试用Borel-Cantelli引理失败
> 关于这个问题我首先想到可以借助[[Borel-Cantelli lemma及其应用#1. 此lemma在序列的几乎处处收敛上的应用]],然后接合Chebyshev不等式来证明最后的几乎处处收敛。具体来说，令$$A_{n,\varepsilon}:=\{x:|A_n|\geq \varepsilon\}$$如果对任意的$\varepsilon>0$，我们可以证明$\sum_{n\geq 1}\mu(A_{n,\varepsilon})$收敛，那么问题就解决了。我们可以尝试用Chebyshev来估计$\mu(A_{n,\varepsilon})$的上界。一个简单的估计为$$\mu(A_{n,\varepsilon})\leq \frac{\int_X A_n^2(x)\,d\mu}{\varepsilon^2}$$也就是说我们只要证明，$\sum_n \int_X A_n^2(x)\,d\mu$收敛即可。但是很不巧，条件中给到的是$\sum_n \frac{\int_X A_n^2(x)\,d\mu}{n}$收敛。


> [!error] 1.2:一个天真的错误想法 
> 有没有可能对于非负序列$b_n$，如果$\sum_n \frac{b_n}{n}<+\infty$那么$\sum_{n}b_n<+\infty$呢？因为如果这样能成功的话，我们不妨假设$b_n:=\int_X A_n^2(x)\,d\mu$从而直接得到$\sum_n b_n<+\infty$从而实现"Borel-Cantelli引理+Chebyshev不等式"的路径，完成对$A_n(x)$几乎处处收敛到0的论证。
> 
> 但这是错误的，因为我们轻易可以给出反例：$b_n:=1_{n=2^k}$那么此时$$\sum_{n\geq 2}\frac{b_n}{n}=\sum_{k\geq 1}\frac{1}{2^k}<+\infty$$但是$$\sum_{n\geq 2} b_n =\sum_{k\geq 1}1=+\infty$$

所以“命题0”为什么是对的？因为命题当中还有一个条件：$$||f||_{L^{\infty}}\leq M$$这个给了$A_N(x):=\frac{1}{N}\sum_{n\leq N} f_n(x)$序列一个额外的性质，从而使得$A_n(x)$几乎处处收敛到0。

这个重要的额外条件就是，对于固定的$x$序列$A_n(x)$的差分的衰减速度为$O(\frac{1}{n})$：

> [!note] 引理1.3 
> 存在正实数$M$使得$$|A_{n+1}(x)-A_n(x)|\leq \frac{2M}{n+1}$$几乎处处成立。

* 由于$$A_{n+1}(x)=\frac{1}{n+1}\sum_{k\leq n+1}f_k(x)=\frac{n}{n+1}A_n(x)+\frac{1}{n+1}f_{n+1}(x)$$因此$$A_{n+1}(x)-A_n(x)=\frac{f_{n+1}(x)-A_n(x)}{n+1}$$由于函数列几乎处处一致有界的条件，$|f_n(x)|\leq M,|A_n(x)|\leq M$几乎处处成立，于是$$|A_{n+1}(x)-A_n(x)|\leq \frac{2M}{n+1}$$对几乎处处所有$x\in X$成立。

那么这种$A_n(x)$差分绝对值的衰减速度的信息能告诉我们什么呢？

* 下面的操作一定程度上受到了“Kolmogorov强大数定律”的启发。

> [!note] 引理1.4  
> 令$I_k:=[2^k,2^{k+1}),\Lambda_k(x):=\max_{n\in I_k}\{|A_n(x)|\}$以及$$G_k(x):=\frac{1}{|I_k|}\sum_{n\in I_k} A_n(x)^2 $$那么$$G_k(x)\geq \frac{1}{16 M} \Lambda_k(x)^3$$


> [!note] 引理1.5
> 在“命题0"的条件下$G_k(x)$几乎处处收敛到0。

这样的结果有什么意义呢？

如果我们可以证明$G_k(x)$几乎处处收敛到0，那么由于引理当中的控制关系，我们就可以得到$\Lambda_k(x)$也几乎处处收敛到0。而这便意味着$|A_n(x)|$也是几乎处处收敛到0的。

因为对于给定的$x$，假设在此点处$\Lambda_m(x)$收敛到0。那么对任意$\varepsilon>0$存在一个正整数$N_{\varepsilon}'$对于任意$m>N_{\varepsilon}'$都有$\Lambda_n(x)<\varepsilon$。现在我们令$N_{\varepsilon}:=2^{N_{\varepsilon}'+1}$，于是对任意$n>N_{\varepsilon}$都存在一个$k$使得$$2^k\leq n<2^{k+1}$$并且$k>N_{\varepsilon}'$。于是$$|A_n(x)|\leq \Lambda_k(x)<\varepsilon$$这表明如果$\Lambda_n(x)$几乎处处收敛到0，那么$|A_n(x)|$也几乎处处收敛到0，从而得到$A_n(x)$几乎处处收敛到0。

所以接下来只要能证明以上两个引理能成立，那么问题也就解决了。

---

首先我们来证明"引理1.5"。

我们依旧参考[[Borel-Cantelli lemma及其应用#1. 此lemma在序列的几乎处处收敛上的应用]]的思路，令$$B_{k,\varepsilon}:=\{x\in X:G_k(x)\geq \varepsilon\}$$于是借助Chebyshev不等式$$\mu(B_{k,\varepsilon})\leq \frac{1}{\varepsilon}\int G_k(x)\,d\mu$$然后为了能利用”命题0“当中的收敛条件，我们需要交换积分与和的次序。

* 比较容易想到的是利用Tonelli定理，但是这个结果需要假定测度空间是$\sigma-$finite，而"命题0"当中并没有对空间的这种假设。所以这里用Beppo-Levi的单调收敛定理更合适。（参考[[函数列Lp范数的怎样的衰减速度能保证函数列几乎处处收敛到0#^6d8874]])

利用单调收敛收敛定理$$\begin{aligned}\int G_k\,d\mu &= \int \frac{1}{2^k} \sum_{n\in I_k} A_n(x)^2\,d\mu\\&=\frac{1}{2^k}\sum_{n\in I_k} \int A_{n}(x)^2\,d\mu\\\end{aligned}$$那么$$\begin{aligned}\sum_{k\geq 1} \int G_k\,d\mu &= \sum_{k\geq 1} \frac{1}{2^k}\sum_{n\in I_k} \int A_{n}(x)^2\,d\mu\\&\leq \sum_{k\geq 1}\sum_{n\in I_k}\frac{2}{n}\int A_{n}(x)^2\,d\mu \\&=2\sum_{n\geq 2} \frac{1}{n}\int A_{n}(x)^2\,d\mu<\infty\end{aligned}$$于是我们知道$$\sum_{k\geq 1}\mu(B_{k,\varepsilon})<\infty$$对任意$\varepsilon>0$成立，因此$G_k(x)$几乎处处收敛到0。

---

现在来证明"引理1.4"。

对于固定的$x_0$，令$$A_n:=A_n(x_0),\lambda:=\Lambda_k(x_0)=A_{n_0},G_k:=G_k(x_0)$$根据“引理1.3”$A_n$满足$$|A_n|-\frac{2M}{n+1}\leq |A_{n+1}|\leq |A_n|+\frac{2M}{n+1}$$如果我们限定$n\in I_k$那么$$|A_n|-\frac{M}{2^{k-1}}\leq |A_{n+1}|\leq |A_n|+\frac{M}{2^k}$$这表明在区间$I_k$当中序列$A_n$不能从峰值$A_{n_0}=\lambda$过快地下降，因为序列从$n_0$向左或向右移动，至多下降$\delta_k:=\frac{M}{2^{k-1}}$。

> [!tip] 想法1.6
> 这个信息能对我们的目的，即制造$G_k$控制$\Lambda_k$的不等式，有什么意义？联想到[[函数p范数与无穷范数之间的关系]]当中下界不等式的估计，我们可以把$G_k=\frac{1}{|I_k|}\sum_{n\in I_k}|A_n|^2$理解为离散的$L^2$范数的平方，$\lambda$理解为离散的$L^\infty$范数。所以为了建立由$L^2$范数控制$L^{\infty}$范数的不等式，我们需要讨论集合$\{n\in I_k:|A_n|\geq \lambda - \varepsilon\}$这个集合的计数测度，也就是元素个数的下界估计。而这就可以结合$\lambda=|A_{n_0}|$不能快速下降的特性来完成。

这里不妨令$\varepsilon=\frac{1}{2}\lambda$，那么如果即便我们只是统计最大项$n_0$右边的项，那么按照每次至多下降$\delta_k$来计算，那么$$|E_k|:=\left|\left\{n\in I_k:|A_n|\geq \frac{\lambda}{2}\right\}\right|\geq \frac{\lambda}{2\delta_k}$$于是$$\begin{aligned}G_k&:=\frac{1}{|I_k|}\sum_{n\in I_k}|A_n|^2\\&\geq \frac{1}{2^k}\sum_{n\in E_k}|A_n|^2 \\&\geq \frac{1}{2^k}\cdot\frac{\lambda^2}{4}\cdot|E_k| \\&\geq \frac{1}{16M}\lambda^3\end{aligned}$$
这个估计对任意$x$都成立，于是$$G_k(x)\geq \frac{1}{16 M} \Lambda_k(x)^3$$

