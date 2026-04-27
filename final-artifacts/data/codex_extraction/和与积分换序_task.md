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

> [!tip] 核心想法0
> 1. 如果我们有一个求和/积分问题，比如$\sum X$这个和或$\int X$这个积分是难以处理的，
> 2. 此时我们又发现我们可以把$X$写成一个新的和或者积分，$X=\sum Y$或者$X =\int Y$那么此时我们得到了:
> $$\sum \sum Y \text{ or }\sum \int Y\text{ or } \int \sum Y \text{ or }\int \int Y$$
> 3. 交换二者的次序，试试看交换以后的结果会不会更好。简单来说就是给目标对象换一个表达方式，并且期望这个新的表达比原本的表达在当前状况下更好处理。

这个操作本身是中性的，其价值取决于我们最后得到的等价的形式与我们的目的之间是否更匹配。

> [!example] 例子0.1：全纯函数的幂级数表示与积分表示
> 比如[[全纯函数与解析函数的等价性]]当中，带入这个视角我们无非就是把全纯函数$f(z)$的积分表示，即柯西积分公式，通过内部做展开的方式，然后交换得到函数的幂级数表示。我们很难说，一个全纯函数的积分表示更好还是幂级数表示更好，直到我们明确我们的目标。
> 
> 例如，当我们讨论全纯函数零点的时候，我们会尝试在零点附近进行幂级数展开，这样会方便我们处理局部的信息。比如[[identity theorem#^a4f64f]]这个命题当中，为了证明全纯函数的零点都是孤立的，我们就用的是全纯函数的幂级数表示而非积分表示。
> 
> 再比如，当我们需要通过全纯函数的全局条件推断其本身性质的时候，积分表示就更管用。例如[[揭露全纯以及亚纯函数信息的Liouville原则]]当中许多关于全纯函数增长速度控制的条件。全纯函数的幂级数表示就很难结合这种函数的全局条件，但是积分表示就很合适。

此处的工具恰好就是一种把和或者积分从一个形式变成另外一个形式的手段。我们会在这篇笔记当中分类讨论：
1. 如何展开然后换序，
2. 展开哪个部分，采用何种展开才能使得新的形式比原本的形式更好。


### 1. [[把条件函数展开为新的和或积分然后换序]]

### 2. [[把积分或求和对象视为一个计数函数并展开]]

### 3. 和与积分内部做幂级数展开

整个形式可以抽象为$$\int XY=\int X\sum Z = \sum \int XZ$$
#### 3.1 幂级数展开

> [!tip] 想法3.1.1
> 此时我们展开无非就是得到：$$\int f(x)g(x) = \int f(x)\sum a_n x^n = \sum a_n\int f(x)x^n$$无论是计算积分还是做积分估计，我们需要保证两点：
> 1. $f$的n次矩，也就是$b_n:=\int f(x)x^n$对我们而言是简单的（已知，好算，好估计）
> 2. $\sum a_n b_n$对我们来说是简单的（已知，好算，好估计）

* 转换为级数并不等于简单，只是我们把重担对积分的处理转移到了对级数的处理上。

> [!tip] 想法3.1.2
> 有时候，展开未必是直接对$g$进行展开，而是$$\int f(x)g(x)=\int f(x)h(u)$$其中$h(u)=g(x)$。然后我们是对$h(u)$进行展开，从而得到$$\int f(x)h(u)=\int f(x)\sum a_n u^n = \sum a_n \int f(x)u^n(x)$$也就是说，我们也不能只是关注那些普通的$n$次矩好算的函数$f$，也要关注对于一些特殊的n次矩$\int f(x)u^n(x)$优化的函数。

* 类似于[[把积分转换为与Dirichlet eta函数有关的级数]]也算是这种思路的延申。虽然

> [!note] 命题3.1.3:正半轴上指数衰减的函数n次矩
> 区间$[0,+\infty)$上常见的$n$次矩简单的函数$g(x)$以及它们的$n$次矩$b_n:=\int_0^{\infty}g(x)x^n\,dx$：
> * 指数衰减型$e^{-ax}$，$$\begin{aligned}b_n&=\int_0^{\infty}e^{-ax}x^n\,dx \xlongequal{t=ax}\frac{1}{a^{n+1}}\int_0^{\infty}t^ne^{-t}\,dt \\&= \frac{\Gamma(n+1)}{a^{n+1}}\\&=\frac{n!}{a^{n+1}}\end{aligned}$$
> * 高斯函数$e^{-ax^2}$,$$\begin{aligned}b_n&=\int_0^{\infty}e^{-ax^2}x^n\\&\xlongequal{t=ax^2}\frac{1}{2a^{(n+1)/2}}\int_0^{\infty}t^{\frac{n}{2}-\frac{1}{2}}e^{-t}\,dt \\&=\frac{\Gamma(\frac{n+1}{2})}{2a^{(n+1)/2}}\end{aligned}$$
> * 玻色-爱因斯坦分布（简化）$\frac{1}{e^x-1}$。这个函数的$n$次矩的计算本身就体现了"想法3.1.2"的技巧，我们利用$$\frac{1}{e^x-1}=\frac{e^{-x}}{1-e^{-x}}=\sum_{k\geq 1} e^{-kx}$$从而交换次序，并结合上面已经推导出来的指数型的普通n次矩的结论，得到$$\begin{aligned}b_n&=\int_0^{\infty}\frac{x^n}{e^x-1}\,dx \\&= \int_0^{\infty}x^n\sum_{k\geq 1} e^{-kx}\\&= \sum_{k\geq 1}\int_0^{\infty}x^ne^{-kx} \,dx \\&= \sum_{k\geq 1}\frac{n!}{k^{n+1}}\\&=n!\zeta(n+1)\end{aligned}$$
> * 费米-狄拉克分布（简化），方法与思路与上一个类似。利用$$\frac{1}{e^x+1}=\frac{e^{-x}}{1+e^{-x}}=\sum_{k\geq 1} (-1)^{k-1}e^{-kx}$$从而$$\begin{aligned}b_n&=\int_0^{\infty}\frac{x^n}{e^x+1}\,dx \\&= \int_0^{\infty}x^n\sum_{k\geq 1} (-1)^{k-1}e^{-kx}\\&= \sum_{k\geq 1}(-1)^{k-1}\int_0^{\infty}x^ne^{-kx} \,dx \\&= n!\sum_{k\geq 1}\frac{(-1)^{k-1}}{k^{n+1}}\\&=n!(1-2^{-n})\zeta(n+1)\end{aligned}$$


> [!example] 例子3.1.4
> 计算含参数积分$$I(a):=\int_{-\infty}^{\infty}e^{-x^2}\cos(ax)\,dx$$

* 这个问题有很多不同算法，如果按照我们此处的想法。首先依照函数的对称性简化积分$$\frac{I(a)}{2}=\int_0^{\infty}e^{-x^2}\cos(ax)\,dx$$这个积分当中有一个在$[0,+\infty)$上指数衰减的函数，即高斯函数。于是我们不妨考虑对$\cos(ax)$做幂级数展开，从而$$\begin{aligned}\frac{I(a)}{2}&=\int_0^{\infty}e^{-x^2}\sum_{n\geq 0} \frac{(-1)^n}{(2n)!}(ax)^{2n}\\&= \sum_{n\geq 0}\frac{(-1)^na^{2n}}{(2n)!}\int_0^{\infty}e^{-x^2}x^{2n}\,dx \\&=\frac{1}{2}\sum_{n\geq 0}\frac{(-1)^na^{2n}}{(2n)!}\cdot \Gamma(n+\frac{1}{2})\\&=\frac{1}{2}\sum_{n\geq 0}\frac{(-1)^na^{2n}}{(2n)!}\cdot \frac{(2n)!\sqrt{\pi}}{4^nn!}\\&= \frac{1}{2}\sqrt{\pi }\sum_{n\geq 0}\frac{1}{n!}\left(-\frac{a^2}{4}\right)^n \\&=\frac{1}{2}\sqrt{\pi}e^{-\frac{a^2}{4}}\end{aligned}$$于是$$I(a)=\sqrt{\pi}e^{-\frac{a^2}{4}}$$
* 这里交换次序的理由是Fubini-Tonelli定理，因为被积函数$$u_n(x)=e^{-x^2}\frac{(-1)^na^{2n}}{(2n)!}$$是一个绝对收敛的被积函数（参考[[Fubini-Tonelli定理的例子与反例]]），即只要$|u_n(x)|$交换或者不交换能算出一个有限的结果，那么交换就一定是合法的。根据以上计算，即便去掉$(-1)^n$，交换以后的结果也一定是有限的。

---

> [!example] 例子3.1.5 
> 令$a>0,b\in \mathbb{R}$并且满足$a>|b|$，计算含参数积分$$I(a,b):=\int_0^{\infty}e^{-ax}J_0(bx)\,dx$$其中$J_0(z)$是第一类零阶贝塞尔函数。
* 由于$e^{-ax}$是一个在$[0,\infty)$上指数衰减的函数，然后我们直到贝塞尔函数的幂级数展开$$J_0(z)=\sum_{n\geq 0}\frac{(-1)^n}{(n!)^2}\left(\frac{z}{2}\right)^{2n}$$因此我们打算展开$J_0(bx)$然后交换次序，从计算一个有关$e^{-ax}$n次矩有关的一个级数。$$\begin{aligned}I(a,b)&=\int_0^{\infty}e^{-ax}\sum_{n\geq 0}\frac{(-1)^n}{(n!)^2}\left(\frac{bx}{2}\right)^{2n}\,dx \\&= \sum_{n\geq 0}\frac{(-1)^n}{(n!)^2}\left(\frac{b}{2}\right)^{2n}\int_0^{\infty}e^{-ax}x^{2n}\,dx \\&=\sum_{n\geq 0}\frac{(-1)^n}{(n!)^2}\left(\frac{b}{2}\right)^{2n}\frac{(2n)!}{a^{2n+1}}\\&=\frac{1}{a}\sum_{n\geq 0}(-1)^n\binom{2n}{n}\left(\frac{b^2}{4a^2}\right)^n\end{aligned}$$根据二项式展开公式，$$\frac{1}{(1+z)^{1/2}}=\sum_{n\geq 0}(-1)^n\binom{2n}{n}(z/4)^n$$于是$$I(a,b)=\frac{1}{a}\cdot \frac{1}{\sqrt{1+\frac{b^2}{a^2}}}=\frac{1}{\sqrt{a^2+b^2}}$$
* 交换的理由依旧是Fubini-Tonelli，去掉$(-1)^n$以后计算出来的结果是$\frac{1}{a}\sum_{n\geq 0} \binom{2n}{n}\left(\frac{b^2}{4a^2}\right)^n$，由于幂级数$\sum_{n\geq 0} \binom{2n}{n}z^n$根据ratio test计算出来其收敛半径为$\frac{1}{4}$。由于$|b|<a$从而目标级数绝对收敛，因此根据Fubini-Tonelli定理，交换合法。

---

> [!note] 命题3.1.6: 区间$(0,1)$上常见的$n$次矩
> 相比于无穷区间，有限区间$(0,1)$上的积分矩通常与 $\Gamma$ 函数、Beta 函数以及阶乘幂密切相关。以下是常见的 $g(x)$ 及其 $n$ 次矩 $b_n:=\int_0^1 g(x)x^n\,dx$：
> * **对数函数** $(\ln x)^k$(其中$k$为正整数)。利用换元 $x=e^{-t}$ 将其转化为 Gamma 函数积分：
>   $$\begin{aligned}b_n&=\int_0^1 x^n (\ln x)^k \,dx \\&\xlongequal{x=e^{-t}} \int_{\infty}^0 e^{-nt}(-t)^k (-e^{-t})\,dt \\&= (-1)^k \int_0^{\infty} t^k e^{-(n+1)t}\,dt \\&= (-1)^k \frac{\Gamma(k+1)}{(n+1)^{k+1}} = (-1)^k \frac{k!}{(n+1)^{k+1}}\end{aligned}$$
>   * 特别地，当 $k=1$ 时，$b_n = -\frac{1}{(n+1)^2}$。
> * **移位幂函数** $(1-x)^a$(其中$a>-1$)。这直接对应于 Euler Beta 函数的定义：
>   $$\begin{aligned}b_n&=\int_0^1 x^n (1-x)^a \,dx \\&= B(n+1, a+1) \\&= \frac{\Gamma(n+1)\Gamma(a+1)}{\Gamma(n+a+2)}\end{aligned}$$如果 $a$ 是正整数 $m$，则 $b_n = \frac{n!m!}{(n+m+1)!}$。
> * $\frac{1}{\sqrt{1-x^2}}$。利用三角换元 $x=\sin \theta$ 转化为 Wallis 积分公式：
>   $$\begin{aligned}b_n&=\int_0^1 \frac{x^n}{\sqrt{1-x^2}}\,dx \\&\xlongequal{x=\sin \theta} \int_0^{\frac{\pi}{2}} \sin^n \theta \,d\theta \\&= \frac{\sqrt{\pi}}{2}\frac{\Gamma(\frac{n+1}{2})}{\Gamma(\frac{n}{2}+1)}\end{aligned}$$此时通常需要讨论 $n$ 的奇偶性。若 $n=2k$，则 $b_{2k} = \frac{\pi}{2}\frac{(2k-1)!!}{(2k)!!} = \frac{\pi}{2}\frac{\binom{2k}{k}}{4^k}$。

> [!example] 例子3.1.7
> 计算积分 $$I = \int_0^1 \frac{\ln x}{1+x}\,dx$$
* 这是一个非常经典的积分，通常可以通过级数展开求解。观察到 $\frac{1}{1+x}$ 在 $(0,1)$ 上可以展开为几何级数，且 $\ln x$ 的 $n$ 次矩非常简单（见命题3.1.6）。
* 展开 $g(x)=\frac{1}{1+x} = \sum_{n\geq 0} (-1)^n x^n$。
* 交换积分与求和次序：
  $$\begin{aligned}I &= \int_0^1 \ln x \sum_{n\geq 0} (-1)^n x^n \,dx \\&= \sum_{n\geq 0} (-1)^n \int_0^1 x^n \ln x \,dx \\&= \sum_{n\geq 0} (-1)^n \left( -\frac{1}{(n+1)^2} \right) \\&= \sum_{n\geq 0} \frac{(-1)^{n+1}}{(n+1)^2} \\&= -1 + \frac{1}{4} - \frac{1}{9} + \frac{1}{16} - \cdots \\&= -\left(1 - \frac{1}{2^2} + \frac{1}{3^2} - \frac{1}{4^2} + \cdots\right) \\&= -\frac{\pi^2}{12}\end{aligned}$$
* 交换次序的理由：根据 Fubini-Tonelli 定理，我们考察绝对值的积分 $\int_0^1 |\ln x| \sum |(-1)^n x^n| dx = \int_0^1 \frac{-\ln x}{1-x} dx$。利用同样的矩方法，$\sum \frac{1}{(n+1)^2} = \frac{\pi^2}{6} < \infty$，因此交换是合法的。

---

> [!example] 例子3.1.8
> 计算含参数积分（第一类零阶贝塞尔函数的积分表示）：$$I(a) := \int_0^1 \frac{\cos(ax)}{\sqrt{1-x^2}}\,dx$$
* 观察到权函数 $\frac{1}{\sqrt{1-x^2}}$ 是区间 $[0,1]$ 上 $n$ 次矩（偶数阶）形式优美的函数。我们对 $\cos(ax)$ 进行泰勒展开。
* 注意到 $\cos(ax) = \sum_{k\geq 0} \frac{(-1)^k}{(2k)!} (ax)^{2k}$。
* 代入积分并交换次序：
  $$\begin{aligned}I(a) &= \int_0^1 \frac{1}{\sqrt{1-x^2}} \sum_{k\geq 0} \frac{(-1)^k a^{2k}}{(2k)!} x^{2k} \,dx \\&= \sum_{k\geq 0} \frac{(-1)^k a^{2k}}{(2k)!} \int_0^1 \frac{x^{2k}}{\sqrt{1-x^2}} \,dx\end{aligned}$$
* 利用命题3.1.6中关于切比雪夫权重的偶次矩公式 $b_{2k} = \frac{\pi}{2} \frac{\binom{2k}{k}}{4^k} = \frac{\pi}{2} \frac{(2k)!}{(k!)^2 4^k}$：
  $$\begin{aligned}I(a) &= \sum_{k\geq 0} \frac{(-1)^k a^{2k}}{(2k)!} \cdot \frac{\pi}{2} \frac{(2k)!}{(k!)^2 4^k} \\&= \frac{\pi}{2} \sum_{k\geq 0} \frac{(-1)^k}{(k!)^2} \left( \frac{a^2}{4} \right)^k \\&= \frac{\pi}{2} \sum_{k\geq 0} \frac{(-1)^k}{(k!)^2} \left( \frac{a}{2} \right)^{2k}\end{aligned}$$
* 识别级数部分，正是第一类零阶贝塞尔函数 $J_0(a)$ 的定义式，因此：
  $$I(a) = \frac{\pi}{2} J_0(a)$$
* 这里的交换次序同样由级数的绝对收敛性保证（贝塞尔函数的级数在全平面绝对收敛）。

---

* [[关于log的一个积分#2.转换为级数处理]]：在处理积分$\int_{0}^{1} \log(1-x) \log(x) dx$的时候，由于我们事先知道$\log x$在$(0,1)$上的情况比较简单，于是尝试展对$\log(1-x)$进行幂级数展开。最后得到的结果是$\sum_{n \geq 1}\frac{1}{n(n+1)} -\sum_{n \geq 1}\frac{1}{(n+1)^2}$这个级数。这并不代表问题自动变得简单，只是因为我们对该级数比当前的积分更熟悉而已。





[[通过重整来证明表达式的非负性]]当中有这样一个例子，$$\sum_{1\leq i,j\leq
n}\left(\log(1+a_ia_j)-\log(1-a_ia_j)\right) \geq
0$$为了证明此对象非负，我们展开了被求和的对象为级数，然后交换了次序从而得到$\sum_{k\geq 1} \frac{1+(-1)^{k-1}}{k}\sum_{1\leq i,j\leq n}(a_ia_j)^{k}$，于是便证明了非负性。这里注意到双重求和，特别是求和下标范围完全一致的双重求和，对求和对象为对称的两个元素乘积的形式(比如此处的$a_ia_j$)很敏感，因为这意味着非负。



### 3.和与积分换序

顾名思义，也就是当我们在处理求和问题的时候发现不容易处理，于是考虑把被求和的一部分考虑为某个函数的积分，然后交换积分与求和的次序，看看是否能简化问题。

* 这其中一个经典的处理方法是，当我们需要证明某个双重求和的$\sum \sum X$我们通过把被求和对象改写为一个$\int Y_1Y_2$的形式那么原来的求和便成为了$$\sum\sum\int Y_1 Y_2 = \int\sum\sum Y_1Y_2 = \int(\sum Y_1)^2\geq 0$$在[[通过重整来证明表达式的非负性]]当中例如$\sum_{1\leq i,j\leq n}\frac{a_ia_j}{i+j-1} \geq 0$这个问题，我们把被求和的其中一部分$$\frac{1}{i+j-1}=\int_{0}^{1} x^{i-1}x^{j-1}\,dx $$做了处理，从而可以做到上面的操作，从而证明非负性。再比如此笔记中的另外一个问题，$$\sum_{1\leq i,j\leq n} \min(r_i,r_j)x_ix_j \geq 0$$处理方法是展开$\min(r_i,r_j) =\int_{0}^{\infty} \mathbf{1}_{t\leq r_i}(t)\mathbf{1}_{t\leq r_j}(t)\,dt$于是也可以进行上面的操作。再比如此笔记当中的$\sum_{1\leq i,j\leq n}|x_i+x_j|-|x_i-x_j|$问题,我们通过$$|x_i+x_j|-|x_i-x_j|=\frac{2}{\pi}\int_{0}^{\infty} \sum_{1\leq i,j\leq n}\frac{\sin(x_it)\sin(x_j t)}{t}\,dt $$完成此操作。

### 4. 积分换序


