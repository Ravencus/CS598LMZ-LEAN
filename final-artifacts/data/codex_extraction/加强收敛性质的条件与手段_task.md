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
  - tool_idea
---
### 1. 利用Borel-Cantelli引理来把依测度收敛加强到几乎处处收敛

> [!tip] 借助Borel Cantelli引理来加强收敛性的想法
> 如果我们得到$f_n \xrightarrow{\mu} f$，亦或者依照某种范数收敛，然后我们想要根据一个额外的条件$\text{Cond}$去把这个结果加强为几乎处处收敛。我们想到可以借助[[Borel-Cantelli lemma及其应用]]当中其中一个版本的引理(常用引理1)，得到关于$A_{n,\varepsilon}:=\{x:|f_n(x)-f(x)|\geq\varepsilon\}$的级数收敛的信息$$\sum_{n\geq1}\mu(A_{n,\varepsilon})<\infty,\forall \varepsilon>0$$的结论，我们就可以导出$\mu\left(\limsup_{n\to\infty}A_{n,\varepsilon}\right)=0$的结论从而得到几乎处处收敛。因此实现这一点的关键是对$\mu(A_{n,\varepsilon})$做估计。
> 1. 如果cond涉及$f_n$的范数的大小信息(概率论中，方差期望，moment一类的也算是这种信息)，那么我们可以考虑从Chebyshev不等式入手去估计$\mu(A_{n,\varepsilon})$。
> 2. 

* [[Borel-Cantelli lemma证明某种版本下的强大数定律]]在这篇文章当中，测度$\lambda=P$是概率测度，序列则是$f_n(\omega)=\frac{S_n(\omega)}{n}$,最后要证明收敛的极限函数是常数$\mu$。我们已经通过弱大数定律知道$$\frac{S_n(\omega)}{n}\xrightarrow{P}{\mu}$$现在我们要在条件$E(|X_1|^4)<\infty$的条件下,借助Borel-Cantelli引理来把结果加强为$$\frac{S_n(\omega)}{n}\xrightarrow{a.e.}{\mu}$$这里我们的手段依旧是借助Chebyshev不等式，于是可以做到$$\begin{aligned}P\left(\left\{\omega:\left|\frac{S'_n(\omega)}{n}\right| >\varepsilon\right\}\right) =O\left(\frac{1}{n^2}\right) \end{aligned}  $$从而证明级数收敛性。
* [[随机变量期望收敛导出几乎处处收敛的一个条件]]当中我们已知随机变量$X_n$的期望的收敛结果，现在我们需要把结果加强到此随机变量$X_n$几乎处处收敛。此处采用的方法依旧是Borel-Cantelli引理，不过直接对目标进行Chebyshev不等式基础上的逐项估计误差太大，我们采用的是对函数的"值的分布"函数进行了一个类似于三角不等式的放缩，然后再进行进一步的估计，从而达成Borel-Cantelli引理证明几乎处处收敛的要求条件。
* [[Etemadi关于强大数定律的证明]]：当中“引理1”的证明当中，我们为了证明截断后的随机变量的和$T_n$在几乎处处收敛的意义下，某种程度等价，即$\frac{T_n}{n}-\frac{S_n}{n}\xrightarrow{a.e.}{0}$,我们利用了截断序列$Y_i$与原本的随机变量$X_i$的一个关系$$P(Y_i\neq X_i \text{ i.o.})=0$$而这是由Borel-Cantelli引理证明的。
### 2. 利用分段估计来加强依照测度收敛

> [!tip] 利用分段估计来加强收敛性的做法
> 如果我们得到$f_n \xrightarrow{\lambda} f$，然后我们想要根据一个额外的条件$\text{Cond}$去把这个结果加强为依某种范数的收敛，例如$L^p$或者一致收敛。我们想到可以按照[[分段估计]]，其中一段利用依测度收敛带来的“集中不等式”来对$A_{n,\varepsilon}:=\{x:|f_n(x)-f(x)|\geq\varepsilon\}$做出$$\lambda(A_{n,\varepsilon})\leq g_n(\varepsilon)$$的估计。然后另外一段则利用额外的条件$\text{Cond}$来做出估计，从而证明某种依照范数的收敛。


* [[Weierstrass逼近定理的概率途径证明]]其中2.2当中的定理1的证明则是先通过弱大数定律得到$Y_n \xrightarrow{P}{p}$然后利用函数$f$一致收敛并且有界的条件通过[[分段估计]]，把$E(f(Y_n))(p)\xrightarrow{P} f(p)$的收敛结果加强为一致收敛的结果。
* [[证明一个由变上限含参数积分给出的函数列一致收敛]]。这个问题中我们需要证明$$f_n(x):=\int_{0}^{x}f(t^n)\,dt,x\in [0,1],n\geq 1$$是一致收敛到$f(0)x$的。我们很容易看出来，这个收敛是几乎处处的，但我们想要的是一致收敛。而这里因为$f_n$的积分的结构，以及$f(x)$在单位闭区间上一致连续的特点，因此考虑分段估计来提升这个收敛结果。
