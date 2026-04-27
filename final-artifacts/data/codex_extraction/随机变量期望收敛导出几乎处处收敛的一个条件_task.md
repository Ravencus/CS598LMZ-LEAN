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
  - 概率论
  - 实分析
---
> [!note]  命题0
> $X_n$是概率空间上的一列随机变量，假设$E(X_n)\to C$，并且这一列随机变量的方差收敛$\sum_{n\geq 1}V(X_n)< \infty$，那么$$X_n\xrightarrow{a.s.} C$$

参照[[加强收敛性质的条件与手段]]当中的经验，当我们得到了随机变量的积分的收敛性以后，我们想要把这种收敛加强到几乎处处收敛，并且我们获得了一个与其范数有关的条件，那么我们可以考虑使用Borel-Cantelli引理来加强这种收敛。
### 1. 第一次尝试

根据[[Borel-Cantelli lemma及其应用]]当中的经验，对任意$\varepsilon>0$，我们假设$$A_{n,\varepsilon}:=\{\omega:|X_n(\omega)-C|\geq\varepsilon\}$$那么只要我们能证明对于概率测度$P$,有$$\sum_{n\geq 1}P(A_{n,\varepsilon})<\infty$$那么整个问题也就解决了。

对于上述级数的收敛判定，我们的想法也非常简单，无非就是采用[[逐项估计]]，对每一个$P(A_{n,\varepsilon})$做估计，最后试图把误差控制在$O(1)$的级别上。我们当然可以直接考虑对此集合的测度的一个上界控制，结合随机变量的方差的条件，我们可以尝试Chebyshev不等式$$\begin{aligned}P(A_{n,\varepsilon})&\leq \frac{E(|X_n-C|^2)}{\varepsilon^2}\\&=\frac{V(X_n)}{\varepsilon^2}+\frac{(EX_n-C)^2}{\varepsilon^2}\end{aligned}$$但是现在出问题了，$\sum_n \frac{V(X_n)}{\varepsilon^2}$倒是好说，可是后面的$\sum_{n\geq 1}\frac{(EX_n-C)^2}{\varepsilon^2}$可不一定是收敛的！比如下面这个反例:

> [!example]  反例1
> 考虑随机变量$X_n \sim \mathcal{N}(\frac{1}{\sqrt{n}},\frac{1}{n^2})$,那么显然均值是收敛到$C=0$的，并且方差的和是收敛的，不过此时$E(X_n)^2 = \frac{1}{n}$，这个和可并不收敛。

这说明在上面的放缩过程中，$P(A_{n,\varepsilon})$的上界产生的误差太大了，超出了我们的精度允许范围。那么有没有什么改进的方法呢？

### 2. 间接证明几乎处处收敛

> [!tip]  想法2.1:间接证明几乎处处收敛的想法
> 假设我们需要证明$f_n \xrightarrow{a.e.} f$,如果我们已经知道$g_n \xrightarrow{a.e.} f$,以及$|f_n-g_n| \xrightarrow{a.e.} 0$,那么我们就能立刻得到结果。换言之，如果我们知道别的对象也几乎处处收敛到目标函数$f$，比如这里的$g_n$，那么我们可以转而去想办法先证明$|f_n-g_n|$几乎处处收敛到0.

我们很容易通过[[Borel-Cantelli lemma及其应用]]证明$$|X_n-E(X_n)|\xrightarrow{a.e.}0$$因为Chebyshev不等式告诉我们$$P(|X_n-E(X_n)|\geq \varepsilon)\leq \frac{E(|X_n-E(X_n)|^2)}{\varepsilon^2}=\frac{V(X_n)}{\varepsilon^2}$$于是$$\sum_{n\geq 1}P(|X_n-E(X_n)|\geq \varepsilon)\leq \frac{1}{\varepsilon^2}\sum_{n\geq 1}V(X_n)<\infty$$对任意的$\varepsilon>0$成立，于是$X_n-E(X_n)$几乎处处收敛到0。

然后我们联系到$E(X_n)\to C$我们自然就能直到$$X_n=(X_n-E(X_n))+E(X_n)$$是几乎处处收敛到$C$的随机变量。

---

以上的过程因为完全用不到有限测度的限制，因此我们实际上可以把它推广到一般的测度空间当中去。

> [!note]  命题2.2
> $f_n$是测度空间$(X,\mathcal{F},\mu)$上的一列可测函数列，记$E_{\mu}(f_n)=\int_X f_n\,d\mu$，$V_{\mu}(f_n)=\int_X (f_n-E_{\mu}f_n)^2\,d\mu$那么如果$$E_{\mu}(f_n)\to C$$并且$$\sum_{n\geq 1}V_{\mu}(f_n)<\infty$$那么$f_n\to C$在$X$上几乎处处成立。

我们在一般的测度空间上重复刚才的思路：
1. 首先$f_n(x)-E_{\mu}(f_n)$几乎处处收敛到0：因为对任意的$\varepsilon>0$都有$$\mu(|f_n-E_{\mu}(f_n)|\geq \varepsilon)\leq \frac{E_{\mu}(|f_n-E_{\mu}(f_n)|^2)}{\varepsilon^2}=\frac{V_{\mu}(f_n)}{\varepsilon^2}$$于是$$\sum_{n\geq 1}\mu(|f_n-E_{\mu}(f_n)|\geq \varepsilon)\leq \frac{1}{\varepsilon^2}\sum_{n\geq 1}V_\mu(f_n)<\infty$$对任意的$\varepsilon>0$成立，于是$f_n-E_{\mu}(f_n)$几乎处处收敛到0。
2. 然后我们联系到$E_{\mu}(f_n)$收敛到$C$，于是我们自然得到$$f_n(x)=f_n(x)-E_{\mu}(f_n)+E_{\mu}(f_n)$$是几乎处处收敛到$C$的函数列。

整个过程并不需要有限可测的条件。