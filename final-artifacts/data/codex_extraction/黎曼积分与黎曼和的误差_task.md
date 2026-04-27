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
  - 微积分
---

> [!question]  问题0
> $f\in C^2([0,1])$，令$$R_n:=\int_0^1f(t)\,\mathrm{d}t-\frac1n\sum_{k=0}^{n-1}f(k/n)$$求$$\lim_{n\to \infty}nR_n$$

* 事实上我们只需要$f\in C^1$就可以得到关于函数黎曼和的估计的结论$$\frac1n\sum_{k=0}^{n-1}f(k/n) = \int_0^1f(t)\,\mathrm{d}t - \frac{f(1)-f(0)}{2n}+O\left(1/n^2\right)$$如果条件再弱一些，只要求$f'\in L^1$，那么估计会减弱到$$\frac1n\sum_{k=0}^{n-1}f(k/n) = \int_0^1f(t)\,\mathrm{d}t - \frac{f(1)-f(0)}{2n}+O\left(1/n\right)$$
### 1. 分段估计

$R_n$的形式提醒我们，这符合[[逐项估计#4. 差的估计中的逐项估计]]的形式，我们可以通过对积分区间进行均匀切割的方式，把$R_n$变成一个标准的和的估计问题。然后中间我们再对每一段使用[[逐项估计#3.2 光滑函数的Taylor展开]]于是便得到：

$$\begin{align}
&\int_0^1f(t)\,\mathrm{d}t-\frac1n\sum_{k=0}^{n-1}f(k/n)\\
&=\sum_{k=0}^{n-1}\int_{k/n}^{(k+1)/n}\left(f(t)-f(k/n)\right)\,\mathrm{d}t\\
&=\sum_{k=0}^{n-1}\int_{k/n}^{(k+1)/n}\left(f'(k/n)(t-k/n)+O((t-k/n)^2\right)\,\mathrm{d}t\\
&=\sum_{k=0}^{n-1}\left(f'(k/n)\frac1{2n^2}+O(1/n^3)\right) \\&=\frac{1}{2n^2}\sum_{k=0}^{n-1}f'(k/n)+O\left(1/n^2\right)
\end{align}$$

于是$$\begin{aligned}\lim_{n\to \infty}nR_n&=\lim_{n\to \infty}\frac{1}{2n}\sum_{k=0}^{n-1}f'(k/n)\\&=\frac{1}{2}\int_{0}^{1} f'(t)d t\\&= \frac{f(1)-f(0)}{2} \end{aligned}$$

---

反过来我们还可以得到结论$$\frac1n\sum_{k=0}^{n-1}f(k/n) = \int_0^1f(t)\,\mathrm{d}t - \frac{f(1)-f(0)}{2n}+O\left(1/n^2\right)$$
* 此处利用了结论$$\left|\frac1n\sum_{k=0}^{n-1}\varphi(k/n) - \int_0^1\varphi(t)\,\mathrm{d}t\right|\leq \frac{\text{Var}(\varphi)}{n}$$其中$\text{Var}(\varphi)$是函数$\varphi$的全变差（Total Variation）。这里$\varphi =f'$,并且发现$f'$是闭区间上的连续函数，因此全变差有限。所以$$\left|\frac{1}{2n}\sum_{k=0}^{n-1}f'(k/n)-\int_{0}^1f'(t)\,dt\right|=O(1/n)$$
以上结果启发我们下面的这种解法。

### 2. Euler-Maclaurin求和

我们知道$\frac1n\sum_{k=0}^{n-1}f(k/n) \to\int_0^1f(t)\,\mathrm{d}t$，那么我们可以把整个问题看成是对$$S_n:=\frac1n\sum_{k=0}^{n-1}f(k/n) $$的精度为$o(1/n)$级别的估计。

那么既然是一个和的估计，而且被求和函数具有一定的光滑性，并且渐近展开的常数项当中出现了$\int_0^1f(t)\,\mathrm{d}t$，那么没有理由不去尝试[[和的积分估计#2.如果函数是光滑的，那么则有更好的估计，即Euler-Maclaurin求和估计]]。

令$g_n(k):=f(k/n)$，运用一阶的Euler-Maclaurin求和公式我们得到$$\begin{aligned}\sum_{k=0}^{n-1}g_n(t)&=\int_{0}^{n-1}g_n(t)\,dt+\frac{g_n(0)+g_n(n-1)}{2}\\&+\frac{g_n'(0)-g_n'(n-1)}{12}-\frac{1}{2}\int_{1}^{n-1}B_{2}(\{t\})g_n^{''}(t)\,dt\end{aligned}$$
其中:
1. 第一项：$$\begin{aligned}\int_{0}^{n-1}g_n(t)\,dt&=n\int_{0}^{1-\frac{1}{n}}f(u)\,du\\&=n\int_{0}^1 f(u)\,du-n\int_{1-\frac{1}{n}}^{1}f(u)\,du\end{aligned}$$其中余项估计中，我们对$f$在$1$处进行Taylor展开$$f(u)=f(1)-f'(1)(1-u)+O((1-u)^2)$$带入$u=1-1/n$然后积分可得$$n\int_{1-\frac{1}{n}}^{1}f(u)\,du=f(1)-\frac{f'(1)}{2n}+O(1/n^2)$$于是第一项的渐近为$$n\int_{0}^1 f(u)\,du-f(1)+\frac{f'(1)}{2n}+O(1/n^2)$$
2. 第二项：通过Taylor展开我们知道$$\begin{aligned}\frac{g_n(0)+g_n(n-1)}{2}+\frac{g_n'(0)-g_n'(n-1)}{12}&=\frac{f(0)+f(1)}{2}-\frac{f'(1)}{2n}\\&+\frac{f'(1)-f'(0)}{12n}\\&+O(1/n^2)\end{aligned}$$
3. 第三项：$$\begin{aligned}T_n&:=\frac{1}{2}\int_{0}^{n-1}B_{2}(\{t\})g_n^{''}(t)\,dt\\&=-\frac{1}{2n}\int_{0}^{1-1/n}B_2(\{nu\})f''(u)\,du\\&= -\frac{1}{2n}\int_{0}^{1}B_2(\{nu\})f''(u)\,du+o(1/n)\end{aligned}$$由于$B_2(\{x\})$是一个周期$1$的有界函数，并且该函数在一个周期上的积分为0。此外$f'(u)$在闭区间$[0,1]$上连续，因此由[[广义的Riemann - Lebesgue lemma]]我们得到$$\int_{0}^{1}B_2(\{nu\})f''(u)\,du\to 0$$于是$$T_n=o(1/n)$$
于是综上所述$$\begin{aligned}S_n &= \int_{0}^1 f(u)\,du-\frac{f(1)-f(0)}{2n}+\frac{f'(1)-f'(0)}{12n^2}+o\left(\frac{1}{n^2}\right)\end{aligned}$$



