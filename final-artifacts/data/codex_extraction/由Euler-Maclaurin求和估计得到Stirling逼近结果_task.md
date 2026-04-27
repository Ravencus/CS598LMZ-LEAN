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
  - 大学数学竞赛
---

> [!question] 问题
> 估计$$ S_n=\sum_{k = 1 }^{n} \log(k)$$

因为得到这个求和的渐近展开，我们就可以得到$n!$的渐近结果。

### 1. Euler-Maclaurin公式：
这个公式主要是对关于光滑函数$f:[m,n]\to\mathbb{C}$的离散求和的一种积分估计。$$\sum_{k=m}^{n}f(k)=\int_{m}^{n}f(t)dt+\frac{f(m)+f(n)}{2}+\sum_{r=1}^{\lfloor p/2\rfloor}\frac{B_{2r}}{(2r)!}\left(f^{(2r-1)}(n)-f^{(2r-1)}(m)\right)+\frac{(-1)^{p+1}}{p!}\int_{m}^{n}B_{p}(\{t\})f^{(p)}(t)dt$$这个公式右边分为三个部分:
1.  **积分主项**:$$I_n=\int_{m}^{n}f(t)dt$$我们主要就是想要用这个积分的渐近或者估计取替代求和。
2.  **展开中间项**：$$E_p(n)=\frac{f(m)+f(n)}{2}+\sum_{r=1}^{\lfloor p/2\rfloor}\frac{B_{2r}}{(2r)!}\left(f^{(2r-1)}(n)-f^{(2r-1)}(m)\right)$$这部分的$p$的取值取决于我们想要展开多少项。
3.  **积分余项**：$$R_{p}(n)=\frac{(-1)^{p+1}}{p!}\int_{m}^{n}B_{p}(\{t\})f^{(p)}(t)dt$$其中的$B_k,B_k(x)$是Bernoulli数以及Bernoulli多项式。这种多项式$p\geq2$的情况下，在$0,1]$上的估计为:            $$|B_{p}(\{t\})|\leq\frac{2p!}{(2\pi)^p}\zeta(p)$$最常见的$B_1(x)=x-1/2,B_2(x)=x^2-x+1/6$.并且$|B_{1}(\{t\})|\leq1/2,|B_{2}(\{t\})|\leq1/6$.其中的p取决于我们想要控制到多少项，估计要多么精确，以及被估计的函数有多么光滑(可以允许最多多少阶的微分)。最后余项的估计，如果我们按照最大误差去计算，就很容易把结果变成一个不等式的上界或者下界的估计

#### 1.1 尝试使用Euler-Maclaurin公式解决该问题:

令$p=3$(p = 2的时候和p=3的时候中间项都是一样的，那么为什么不把余项做精确一点呢?)
1. 积分主项:$$I_n=\int_{1}^nf(t)dt=n\log(n)-n+1$$
 2. 中间项：$$\frac{\log(n)}{2}+\frac{1}{12}\left(\frac{1}{n}-1\right)$$
 3.  积分余项:$$R_3(n)=\frac{1}{3}\int_{1}^{n}B_{3}(\{t\})\frac{1}{t^3}dt$$
 如果我们用积分中值定理去考虑积分余项，我会得到$$S_n=n\log(n)-n+\frac{1}{2}\log(n)+C_p(n)+\frac{1}{12n}+O\left(\frac{1}{n^2}\right)$$这种处理有一个问题，就是中间的本来是常数项的部分还是带有变量$n$，我们没有把全部的余项集中在最后。不如把常数拿出来，然后把余项全部集中在最后。$$\begin{aligned}R_3(n)&=\frac{1}{3}\int_{1}^{n}B_{3}(\{t\})\frac{1}{t^3}dt\\&=\frac{1}{3}\int_{1}^{+\infty}B_{3}(\{t\})\frac{1}{t^3}dt-\frac{1}{3}\int_{n}^{+\infty}B_{3}(\{t\})\frac{1}{t^3}dt\end{aligned}$$于是我们可以令:$$C=1+\frac{1}{3}\int_{1}^{+\infty}B_{3}(\{t\})\frac{1}{t^3}dt-\frac{1}{12}$$于是$$S_n=n\log(n)-n+\frac{1}{2}\log(n)+C+\frac{1}{12n}+R(n)$$其中余项$|R(n)|<\frac{1}{12}\frac{1}{n^2}$于是$$R(n)=O\left(\frac{1}{n^2}\right)$$
 
#### 1.3 利用Wallis Product求出常数
 这里的常数$C$是没有办法通过Euler-Maclaurin求和估计去得到的，只能另寻他法

> [!note] Wallis product,1656
>  $$\frac{\pi}{2}=\prod_{n\geq1}\frac{2n}{2n-1}\frac{2n}{2n+1}=\lim_{n\to+\infty}\frac{1}{2n+1}\cdot\frac{2^{4n}(n!)^4}{[(2n)!]^2}$$ 

这个式子实际上是Hardmard分解作用在$\sin(\pi z)$上的特殊情况,具体公式是:$$\sin(\pi z)=\pi z\prod_{n\geq1}\left(1-\frac{z^2}{n^2}\right)$$这里只需要令$z=\frac{1}{2}$,便是Wallis product公式(参考[[Wallis公式,正弦函数Hadamard分解互相之间的关系]])。如果把渐进式子$n!$$$\begin{aligned}n!=\log(S_n)&=\exp(C)\sqrt{n}\left(\frac{n}{e}\right)^n\exp\left(\frac{1}{12n}+O\left(\frac{1}{n^2}\right)\right)\\&=B\sqrt{n}\left(\frac{n}{e}\right)^n\left(1+O\left(\frac{1}{n}\right)\right)\end{aligned}$$带入到这个式子里面，可以得到最终的极限等于:$$\frac{B^2}{4}=\frac{\pi}{2}$$因此$B=\sqrt{2\pi}$

### 2. 关于$S_n$的更精确的不等式关系:

$$r_n=S_n-(n\log(n)-n+\frac{1}{2}\log(n)+\log(\sqrt{2\pi}))=\frac{1}{12n}+R(n)$$我们现在证明

> [!note] 余项的不等式关系
> $$0<r_n<\frac{1}{12n}$$


也就是要证明$$\begin{aligned}R(n)&=-\frac{1}{3}\int_{n}^{+\infty}B_{3}(\{t\})\frac{1}{t^3}<0\end{aligned}$$可以把这个积分写的更详细，$$\begin{aligned}\int_{n}^{+\infty}B_{3}(\{t\})\frac{1}{t^3}&=\sum_{k\geq n}\int_{k}^{k+1}\frac{B_3(t-k)}{t^3}dt\\&=\sum_{k\geq n}g(k)\end{aligned}$$其中$$g(k)=3+\frac{1}{4}\frac{1}{k(k+1)}+\frac{3}{2}(1+2k)(\log(k)-\log(k+1))>0$$对任意$k\geq1$成立。这里的证明可以理解为无非就是证明,$$\log(1+\frac{1}{k})<\frac{2}{3}\frac{3+\frac{1}{4k+4k^2}}{1+2k}$$我们可以用(2,3)阶的Pade逼近找到一个$\log(1+\frac{1}{k})$的更小的有理函数的上界$$\log(1+\frac{1}{k})<\frac{3k(19+30k)}{-1+21k+102k^2+90k^3}$$然后只需要证明这个有理数的上界比后面的那个还要小，即说明$$\frac{-1+9k}{6k(1+k)(1+2k)(-1+21k+102k^2+90k^3)}>0$$对于$k\geq1$的情况下，分子分母皆为正。

> [!note] 更精确的不等式，Robbins，1955
> $$\frac{1}{12n+1}<r_n<\frac{1}{12n}$$

具体证明参考:https://www.jstor.org/stable/2308012

