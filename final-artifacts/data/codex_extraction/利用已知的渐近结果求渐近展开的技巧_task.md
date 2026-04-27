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

> [!tip] 核心想法
> 当我们需要在指定的误差$O(g(n))$下对和或者积分$A_n$做渐近展开的时候，如果我们已经知道$A_n'$的在指定误差$O(g(n))$下的渐近展开（或者$A_n'$的渐近展开非常容易得到），并且同时可以确认$$A_n-A_n'=O(g(n))$$那么$A_n$的渐近展开和$A_n'$的渐近展开是一致的，从而得到$A_n$的渐近展开。

这里面通常的情况是，我们需要求$A_n$的渐近展开，然后我们发现如果$A_n$的形式做一个不算太大的变化就能变成一个已知或者很容易做渐近分析的形式$A_n'$，那么我们此时只需要量化这种相似性，确保$A_n-A_n'$的误差是在给定精度范围内的。

* [[和的估计的一个典型案例#1. 观点a 相似渐近]]：在这个观点中，我们首先是$$S_n=\sum_{k=1}^n \frac{1}{n^2}\sqrt{(n+k)(n+k+1)} = \frac{1}{n}\sum_{k=1}^n \sqrt{(1+\frac{k}{n})(1+\frac{k+1}{n})}$$为了求$S_n$的极限，我们想到了黎曼和与黎曼积分之间的关系。但是，$S_n$并非是一个标准的黎曼和。不过它倒是与黎曼和$$S_n':=\frac{1}{n}\sum_{k=1}^n \sqrt{(1+\frac{k}{n})(1+\frac{k}{n})}$$颇为类似。于是我们想到了验证二者的绝对误差的量级，最后果然是$o(1)$级别的误差，从而我们便完成了估计。
* [[一个竞赛中的和的渐近展开问题#1.1 当部分和恰好是一个黎曼和的时候]]:我们要求$$S_n=\frac{1}{n}\sum_{k\leq n }\frac{1}{1+(\frac{k}{n})^2+\frac{1}{n}}$$的在精度为$o(1)$的渐近展开，我们能发现一个近似的，并且很好求渐近展开的形式$$S_n'=\frac{1}{n}\sum_{k\leq n }\frac{1}{1+(\frac{k}{n})^2}$$于是我们想到去量化二者的误差，确定这种相似是误差允许的。后来我们发现这种误差的确是被允许的，于是便得到了$S_n$的渐近展开。
* [[不适用于逐项估计求和的极限的例子]]：这个问题当中，我们要求含参数和的极限$$\sum_{k=1}^{n}\frac{1}{n+f(k)}$$其中$f(k):=\frac{2k(k-1)}{2k-1}$。我们打算用和的简单积分估计去做问题，但是发现被求和对象的积分并不是那么显然的。不过由于$f(k)=k+O(1)$，同时因为我们实际上不难知道$\sum_{k=1}^n \frac{1}{n+k}=\frac{1}{n}\sum_{k=1}^n \frac{1}{1+\frac{k}{n}}\to \log(2)$，于是我们只要验证两个含参数和的误差是$o(1)$的，那么问题就能解决。
* [[用分段估计解决几个序列的极限问题#2.2 做法2]]:其中，我们的目标是得到$$S_n:=\sum_{k\leq n}x_{k}y_{n+1-k}$$的误差为$o(n)$的渐近展开，而我们直接就已知$$S_n':=\sum_{k\leq n}x_ky_k=ABn+o(n)$$那么剩下的工作，我们想到可以尝试量化二者之间的误差，结果果然发现误差是$o(n)$的，在允许范围内，于是问题也就解决了。
* [[利用相似的渐近判断积分收敛与发散性]]：已知$\int_{0}^{N}\frac{1}{f(x)}\,dx$的估计，求$\int_{0}^{N}\frac{1}{f(x)+f'(x)}\,dx$的估计，要求误差不超过$O(1)$。那么显然可以估计二者的差是不超过$O(1)$的，依据就是两个式子形式“接近得足够好”。
* [[素数倒数和的估计#2.2 第二个结果来自于第一个结果]]：此处，我们已知$$\sum_{n\leq x}\frac{\Lambda(n)}{n}=\log(x)+O(1)$$然后需要得到$$\sum_{p\leq x}\frac{\log(p)}{p}=\log(x)+O(1)$$这两个的渐近结果是一致，因此我们只需要证明二者的差是$O(1)$的。第一个结果我们还可以表述为$\sum_{p^m\leq x}\frac{\log(p)}{p^m}$，于是二者的差就变成了估计$$\sum_{p^m\leq x,m\geq 2} \frac{\log(p)}{p^m}=O(1)$$
* [[n个连续的阶乘之积有多少个因子#2. 做渐近分析]]:其中“问题3”当中需要给出$\sum_{p\leq n}\log(p-1)$在精度为$o(n)$下的估计。然后我们发现这个目标与Chebyshev的$\theta(n):=\sum_{p\leq n}\log(p)$是相似的，那么我们只需要估计二者的差即可。

---
补充案例：
* 考虑$$P_n:=\prod_{k=1}^n\left(1+\frac{1}{n+k+\sqrt{k}}\right)$$求$P_n$的极限：

我们发现乘积，$$P_n':=\prod_{k=1}^n\left(1+\frac{1}{n+k}\right)$$与目标$P_n$之间非常相似，并且$P_n'$的极限非常简单，因为它具有一个telescoping product的形式（参考[[制造telescoping sum求和或求乘积]]），于是$$P_n'=\prod_{k=1}^n\frac{n+k+1}{n+k}  
=\frac{2n+1}{n+1}\to 2$$
那么根据此处的想法，倘若二者之间的误差在求极限的精度要求下可以容忍，那么二者极限相等。于是接下来我们尝试验证误差。我们把乘积通过对数化的方式转换为和，然后把问题转换为和的估计：
$$\log P_n-\log P_n'  = \sum_{k=1}^n\left[\log\left(1+\frac{1}{n+k+\sqrt{k}}\right)
-\log\left(1+\frac{1}{n+k}\right)\right]$$
其中由于$\log(1+x)$在$[0,+\infty)$导数有上界1，是一个Lipschitz函数，从而$$\left|\log\left(1+\frac{1}{n+k+\sqrt{k}}\right)-\log\left(1+\frac{1}{n+k}\right)\right|  
\le  
\left|\frac{1}{n+k+\sqrt{k}}-\frac{1}{n+k}\right|  
\le \frac{\sqrt{k}}{(n+k)^2}$$从而$$|\log P_n-\log P_n'|  
\le  
\sum_{k=1}^n \frac{\sqrt{k}}{(n+k)^2}  
\le  
\frac{1}{n^2}\sum_{k=1}^n \sqrt{k}  
=O(n^{-1/2})=o(1)$$
* 最后关于$\sum_{k=1}^n \sqrt{k}$的估计参考[[自然数的r次幂的部分和估计]]。

于是$$P_n=P_n'e^{o(1)}\to 2$$

---

补充一个积分的案例：

* 定义含参数积分$$I_N:=\int_1^N \frac{dx}{x+\sin x}$$求$I_N$的渐近展开，精度为$O(1)$：

发现函数$\frac{1}{x+\sin(x)}$分母上的$\sin(x)$对整个积分的影响比较有限，以及$$I_N':=\int_1^N \frac{dx}{x}=\log N$$形式上非常简单。如果$|I_N-I_N'|$的误差在$O(1)$级别，那么我们的目的就达到了。
$$\begin{aligned}I_N-I_N' &=  
\int_1^N\left(\frac{1}{x+\sin x}-\frac{1}{x}\right)\,dx  
\\&= -\int_1^N \frac{\sin x}{x(x+\sin x)}\,dx\end{aligned}$$对于足够大的$x$有不等式$x+\sin x\ge x-1\ge \frac{x}{2}$于是$$\left|\frac{\sin x}{x(x+\sin x)}\right|  
\le  
\frac{2}{x^2}$$从而$$|I_N-I_N'|\leq \int_2^\infty \left|\frac{\sin x}{x(x+\sin x)}\right|\,dx<\int_2^{\infty}\frac{2}{x^2}\,dx=O(1)$$因此$$I_N=\log(N)+O(1)$$






