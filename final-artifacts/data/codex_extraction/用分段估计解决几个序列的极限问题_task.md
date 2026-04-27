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
  - 微积分
  - 考研
---
### 1. 问题1

> [!question] 问题1
> 已知$x_n \to A$,求$$\lim_{n \rightarrow \infty} \frac{x_n + x_{n-1} + ...+x_1}{n}$$

首先我们可以先猜测一下结果的可能性。假设$$A_n:=\frac{x_n + x_{n-1} + ...+x_1}{n}$$并称序列$A_n$是序列$x_n$的前n项的算术平均值。
1. 假设序列$x_n=A$是一个常数列，那么其前n项的算术平均值$A_n = A$。
2. 假设序列$x_n = \frac{1}{n}\to 0$那么此时的算术平均值实际上$A_n =H_n/n$是第n个调和数，而我们知道$H_n =\log(n)+\gamma +O(1/n)$，因此$A_n \to 0$

所以我们猜测会不会结果就是$$A_n\to A$$那么实际上我们要求的极限是$$\lim_{n\to \infty}\left|\frac{1}{n}\sum_{k\leq n}x_k-A\right|$$而这个我们可以把问题转换为定量估计的问题。这实际上就是序列极限的定义，即证明$A_n-A\to 0$。

由[[逐项估计]]的思路，我们可以把问题加强为估计$$\frac{1}{n}\sum_{k\leq n}\left|x_k-A\right|$$那么现在应该如何处理上面的和的上界的估计呢？我们想到条件告诉我们$x_n \to A$，这通常可以尝试制造一个分段估计，因为$|x_k-A|$在尾部的部分基本上是很小的，大部分的值集中在靠近$k=1$的部分。那么由极限的定义，对于任意的$\varepsilon >0$存在一个$N_{\varepsilon}$使得$k>N_{\varepsilon}$的时候$|x_k-A|<\varepsilon$于是$$\begin{aligned}\frac{1}{n}\sum_{k\leq n}\left|x_k-A\right|&=\frac{1}{n}\sum_{k\leq N_{\varepsilon}}\left|x_k-A\right|+\frac{1}{n}\sum_{n\geq k>N_{\varepsilon}}\left|x_k-A\right|\\& \leq \frac{B_{\varepsilon}}{n}+\frac{n-N_{\varepsilon}}{n}\varepsilon \end{aligned}$$两边取上极限，于是得到$$\frac{1}{n}\sum_{k\leq n}\left|x_k-A\right|\to 0$$于是$$\lim_{n\to \infty}\left|\frac{1}{n}\sum_{k\leq n}x_k-A\right|=0$$

### 2. 问题2

> [!question] 问题2
> 假设$x_n\to A,y_n \to B$证明$$\frac{x_1y_n+\cdots +x_ny_1}{n}\to AB$$

#### 2.1 做法1 

参照问题1，如法炮制，我们可以把问题转换为证明$$\left|\frac{1}{n}\sum_{k\leq n}x_{k}y_{n+1-k}-AB\right|$$我们同样可以考虑[[逐项估计]]证明一个加强的命题$$\frac{1}{n}\sum_{k\leq n}\left|x_{k}y_{n+1-k}-AB\right|$$但是此时我们遇到了一个困难，如果仿照问题1当中的逐项估计+分段估计的方法，但是逐项估计的前提建立在我们对每一项有一个较好的估计的基础上，但是这里我们要如何解决每一项的估计？对于这种两项乘积的形式，我们可以考虑利用三角不等式，把整体的估计用两两估计控制起来$$|x_ky_{n+1-k}-AB|\leq |x_ky_{n+1-k}-Ay_{n+1-k}|+|Ay_{n+1-k}-AB|$$这样我们再炮制上面的思路做分段估计。于是对于$x_k$而言，任意$\varepsilon>0$存在$N_{\varepsilon}$使得任意$k>N_{\varepsilon}$都有$|x_k-A|<\varepsilon$。于是
1. 对于尾部，也就是$k>N_{\varepsilon}$而言$$\begin{aligned}|x_ky_{n+1-k}-AB|&\leq |x_ky_{n+1-k}-Ay_{n+1-k}|+|Ay_{n+1-k}-AB|\\ &<\varepsilon |y_{n+1-k}|+|A|\cdot|y_{n+1-k}-B| \end{aligned}$$
2. 对于第一段，也就是$k\leq N_{\varepsilon}$而言，我们令$M_{\varepsilon}$是前$N_{\varepsilon}$当中$|x_k-A|$最大的一项（想想看如果不是利用[[an epsilon of room]]当中第二项，的想法把无穷命题转换为有限问题，这种取最大值的操作怎么可能进行），于是：$$\begin{aligned}|x_ky_{n+1-k}-AB|&\leq |x_ky_{n+1-k}-Ay_{n+1-k}|+|Ay_{n+1-k}-AB|\\ &\leq M_{\varepsilon}|y_{n+1-k}|+|A|\cdot |y_{n+1-k}-B| \end{aligned}$$
3. 

于是整体做分段估计就是$$\begin{aligned}\frac{1}{n}\sum_{k\leq n}\left|x_{k}y_{n+1-k}-AB\right|&=\frac{1}{n}\sum_{ k\leq N_{\varepsilon}}\left|x_{k}y_{n+1-k}-AB\right|+\frac{1}{n}\sum_{N_{\varepsilon}< k\leq n}\left|x_{k}y_{n+1-k}-AB\right|\\&<\frac{1}{n}\sum_{ k\leq N_{\varepsilon}}\left(M_{\varepsilon}|y_{n+1-k}|+|A|\cdot |y_{n+1-k}-B|\right)\\&+\frac{1}{n}\sum_{ N_{\varepsilon}< k\leq n}\left(\varepsilon |y_{n+1-k}|+|A|\cdot|y_{n+1-k}-B| \right) \\ &<\frac{T_{\varepsilon}M_{\varepsilon}}{n}+\frac{\varepsilon}{n}\sum_{k=1}^n |y_{n+1-k}|+\frac{|A|}{n}\sum_{k=1}^n |y_{n+1-k}-B|\\&= \frac{T_{\varepsilon}M_{\varepsilon}}{n}+\frac{\varepsilon}{n}\sum_{j=1}^n |y_{j}|+\frac{|A|}{n}\sum_{j=1}^n |y_{j}-B|\end{aligned}$$
* 这里我们假设前$N_{\varepsilon}$的$y_{n+1-k}$的和的上界为$T_{\varepsilon}$，因为固定$\varepsilon$以后这个和是有限的和。
* 上面最后两行的放缩，是想要利用问题1的结果，即极限的算术平均值的极限等于序列极限本身。而我们知道$|y_j|\to |B|$以及$|y_j-B|\to 0$。
两边取上极限，于是得到$$\limsup_{n\to \infty } \frac{1}{n}\sum_{k\leq n}\left|x_{k}y_{n+1-k}-AB\right|\leq \varepsilon |B| $$对任意$\varepsilon>0$成立。于是这便说明$$\left|\frac{1}{n}\sum_{k\leq n}x_{k}y_{n+1-k}-AB\right|\to 0$$
#### 2.2 做法2

第二种做法的经验参考自[[一个竞赛中的和的渐近展开问题#1.1 当部分和恰好是一个黎曼和的时候]]当中的想法

> [!tip] 想法
> 如果你发现一个$S_n'$其形式比$S_n$更好得到渐近展开，比如说对$S_n$做某种放缩，只要放缩整体的误差是被$O(g(n))$控制起来的(这里表示目标误差精度)，那么最终的渐近展开是相同的。

那么这个问题我们可以理解为对部分和$$S_n:=\sum_{k\leq n}x_{k}y_{n+1-k}$$做渐近展开，要求误差精度至少为$o(n)$。同时我们发现，问题1其实告诉我们$$S_n':=\sum_{k\leq n}x_ky_k=ABn+o(n)$$那么如果我们可以证明$$S_n-S_n'=o(n)$$那么整个问题就可以被证明了。而我们已意识到，这实际上并不困难,因为$$\begin{aligned}|S_n-S_n'|&\leq \sum_{k\leq n}|x_k(y_k-y_{n+1-k})|\\&\leq M\sum_{k\leq n}|y_k-y_{n+1-k}|\\&\leq M\sum_{k\leq n} \left(|y_k-B|+|y_{n+1-k}-B|\right)\\&= 2M\sum_{k\leq n}|y_k-B|\\&= o(n)\end{aligned}$$于是整个计划是行得通的，因此$$S_n:=\sum_{k\leq n}x_{k}y_{n+1-k}=ABn+o(n)$$那么$$S_n/n = AB+o(1)$$以此极限为$AB$.
