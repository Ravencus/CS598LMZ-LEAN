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
  - 调和分析
---
### 1. Dirichlet核并非逼近单位元

> [!note] Dirichlet核
> $$D_N(x):=\sum_{|n|\leq N}e^{inx}=\frac{\sin\left[\left(N+\frac{1}{2}\right)x\right]}{\sin(x/2)}$$

这个核是在讨论函数的傅里叶级数展开时候的自然而然产生的。对于一个定义在$[-\pi,\pi]$上的周期为$2\pi$的函数，考虑其傅里叶级数展开的部分和$S_N(f)$的时候,因为$$\begin{aligned}S_N(f)&:=\sum_{|n|\leq N}\widehat{f}(n)e^{inx}\\&= \sum_{|n|\leq N}\left(\frac{1}{2\pi}\int_{-\pi}^{\pi}f(y)e^{-iny}\,dy\right)e^{inx}\\&= \frac{1}{2\pi}\int_{-\pi}^{\pi}f(y)\left(\sum_{|n|\leq N}e^{in(x-y)}\right)\,dy \\&=\frac{1}{2\pi}\int_{-\pi}^{\pi}f(y)D_N(x-y)\,dy \\&= f*D_N(x)\end{aligned}$$
所以当我们研究函数$f$是否能在某种意义下被其傅里叶展开的部分和$S_N(f)$逼近的时候，按照上面的推导，我们实际上是研究$f*D_N$是否能在某种意义下逼近$f$。

于是联想到[[approximation to the identity]]当中关于逼近单位元，以及逼近单位元的性质的内容，我们自然会提出一个问题$D_N$是否是一个逼近单位元?

首先我们意识到，$D_N(x)$是可积的，并且积分为1。因为按照定义$$\begin{aligned}\frac{1}{2\pi}\int_{-\pi}^{\pi}D_N(x)\,dx &=\frac{1}{2\pi}\int_{-\pi}^{\pi}\sum_{|n|\leq N} e^{inx}\,dx\\&= \sum_{|n|\leq N}\frac{1}{2\pi}\int_{-\pi}^{\pi}e^{inx}\,dx \end{aligned}$$如果令$I_n:=\frac{1}{2\pi}\int_{-\pi}^{\pi}e^{inx}\,dx$,那么我们会发现，$I_0=1$,以及$I_{-n}=I_n$,于是我们知道对于任意的正整数$N$都有$$\frac{1}{2\pi}\int_{-\pi}^{\pi}D_N(x)\,dx=1$$
接下来就是要验证其被绝对值的积分的一致有界性（[[approximation to the identity]]的定义中，第二条需要满足的条件），不过我们立刻发现这一条性质是有问题的，因为
$$\int_{-\pi}^{\pi}|D_N(x)|dx\geq2\int_{0}^{\pi}\frac{\left|\sin\left((N+\frac{1}{2})x\right)\right|}{x}dx$$
然而后面的那个积分并非一致有界的。下面对这个充当下界的积分进行估计。

> [!note] 估计的基本思路
> 因为被积对象的分子具有周期性，在$[0,\pi]$内的积分会走过很多个周期，于是考虑通过换元得到在$[0,(N+\frac{1}{2})\pi]$上的积分，然分拆积分。(思路可以参考[[分段估计#2. 可数分段]])最后把不完整的周期分离出去，整个渐进问题就是估计一个不完整的周期，以及在一个周期里面做渐进。

$$\begin{aligned}\int_{0}^{\pi}\frac{|\sin((N+1/2)x)|}{x}dx&=\int_{0}^{(N+1/2)\pi}\frac{\sin(t)}{t}dt\\&=\int_{0}^{N\pi}\frac{\sin(t)}{t}dt+\int_{N\pi}^{(N+\frac{1}{2})\pi}\frac{\sin(t)}{t}dt\\&=\sum_{k=0}^{N-1}\int_{k\pi}^{(k+1)\pi}\frac{\sin(t)}{t}dt+O\left(\log\left(1+\frac{1}{2N}\right)\right)\\&=\sum_{k=0}^{N-1}\int_{0}^{\pi}\frac{\sin(s)}{k\pi+s}ds+O\left(\frac{1}{N}\right)\\&=\sum_{k=1}^{N-1}\frac{2}{\pi}\frac{1}{k}+O\left(\frac{1}{N}\right)\\&=\frac{2}{\pi}H_{N-1}+O\left(1\right)\\&=\frac{2}{\pi}\log(N)+O\left(1\right)\\&=\frac{2}{\pi}\log(N)+O(1)\end{aligned}$$
* 中间逐项估计的关键步骤是$\int_{0}^{\pi} \frac{\sin(s)}{k\pi +s}\,ds$这个对象我们对被积分对象的其中一部分做了渐近，而不是对全部做渐近，从而使得做积分以后结果会变得简单。此处$$\int_{0}^{\pi} \frac{\sin(s)}{k\pi +s}\,ds=\frac{2}{\pi k}+O\left(\frac{1}{k^2}\right),k>0$$
因此$D_N$并不满足逼近单位元当中对其绝对值的积分的一致有界性的要求，因此Dirichlet核并非逼近单位元。

### 2. Fejer 核是一个逼近单位元

Fejer在Dirichlet的基础上继续思考，既然$f$的傅里叶展开的通常意义下的部分和可能无法很好地收敛到函数$f$本身，那么退而求其次，其Cesaro和是否能能收敛到$f$呢？

所谓Cesaro和就是通常意义下的部分和$S_n$这个序列的算术平均值。之所以说这是退而求其次的妥协，是因为$$\sigma_N:=\frac{S_0+\cdots+S_{N-1}}{N}$$的定义下,如果部分和序列$S_n$的极限是存在的，假设为$s$那么其算术平均值$\sigma_n$一定是收敛到$s$的（其证明可以参考:[[用分段估计解决几个序列的极限问题#1. 问题1]]）。因此我们知道，如果一个序列是可和的序列，即$S_n$极限存在，那么其一定是Cesaro可和的，即$\sigma_n$的极限也存在，并且两种意义下的和收敛到同一个值。不过反过来却不对，比如下面的例子:

> [!example] 例子2.1
> $a_n:=(-1)^n$，那么其部分和$$S_n:=\begin{cases}1&n\text{是偶数}\\0&n\text{是奇数}\end{cases}$$是不存在极限的。但是这个序列确实Cesaro可和的，因为$$\sigma_N:=\frac{S_0+\cdots+S_{N-1}}{N}=\frac{\lfloor\frac{N}{2}+1\rfloor}{N}$$其极限为$\frac{1}{2}$。
> 

* 不过如果给$a_n$一些特殊的性质$P$,也就是说一个序列Cesaro可和，以及具备某种性质$P$是可以得到在同样意义下可和的概念的。参考[[什么样的条件可以从Cesaro可和得到通常意义下的可和]]。

回到函数$f$的傅里叶级数是否可和的问题上，如果我们考虑$f$的傅里叶级数的部分和$S_N(f)$的是否在Cesaro和的意义下可和，那么我们就需要考虑$$\sigma_N(f):=\frac{S_0(f)+\cdots S_{N-1}(f)}{N}$$因为$S_n(f)=f*D_n$，因此我们就不必重新再进行一遍Dirichlet做过的操作，而是直接得到$$\sigma_N(f)=f*\left(\frac{D_0+\cdots D_{N-1}}{N}\right)$$此时令$F_N:=\frac{D_0+\cdots D_{N-1}}{N}$，这就是Fejer核。于是此时，关于$f$的傅里叶级数是否Cesaro可和的问题就变成了$f*F_N$是否有有极限，是否在某种意义下逼近于$f$？那么此时我们面临与先前讨论Dirichlet核一样的问题，即Fejer核$F_N$是否是一个逼近单位元?

> [!note] 定理2.2
> $$F_N(x):=\frac{1}{N}\frac{\sin^2(Nx/2)}{\sin^2(x/2)}$$并且这是一个$L^1([-\pi,\pi])$上的逼近单位元。

* $F_N(x)$的closed form的形式就是基本的三角函数的性质。
1. 积分为1：因为$F_N(x)$是Dirichlet核的算术平均值，而Dirichlet核是满足积分为1的结果的，因此自然$F_N$也满足积分为1的结果。于是结合$F_N$的closed form的结果，我们有$$\int_{-\pi}^{\pi} \frac{\sin^2(Nx/2)}{\sin^2(x/2)}\,dx=2\pi N$$
2. $F_N$绝对值的积分具有一致有界性：这一点因为$F_N(x)\geq 0$，因此直接由第一条就证明了。因为它本身的积分与绝对值的积分没有任何区别。
3. $F_N$的绝对值的积分的任意尾部都是衰减到0的：这主要是因为，对于任意的$\delta>0$当$\delta<|x|\leq \pi$的时候$F_N(x)$的分母是有正的下界的，即$$\sin^2(x/2)\geq C_{\delta}>0$$于是$F_N(x)\leq \frac{1}{NC_{\delta}}$也就是说，对于任意的正整数$N$，$F_N(x)=O(1/N)$,因此$$\frac{1}{2\pi}\int_{\delta<|x|\leq \pi}|F_N(x)|\,dx<\frac{1}{NC_{\delta}} $$所以$|F_N|$的积分在任意的尾部都是随着$N\to \infty$衰减到0的。

因此综上所述，$F_N$是一个逼近单位元。

此外，既然$f$的傅里叶级数展开是在Cesaro和的意义下可和的，那么我们可以借此得到函数傅里叶级数的一些性质。

> [!note] 推论2.3
> 如果函数$f$是单位圆周$\mathbb{T}$上的可积函数，并且其傅里叶系数满足$$\widehat{f}(n)=0,\forall n\in \mathbb{Z}$$那么在$f$的任意连续点处都为取值为0。

首先定义在单位圆周上的函数我们可以对其进行参数化，从而得到一个对应的，定义在$[-\pi,\pi]$上的周期为$2\pi$的$L^1$可积的函数$g$(这部分可以参考[[圆周上的函数的傅里叶展开]])。因此我们只需要证明这个函数$g$如果其傅里叶系数满足条件$$\widehat{g}(n)=0,\forall n\in \mathbb{Z}$$的时候，$g(x)$在任意的连续点处取值为0，就可以证明这样的性质对应到单位圆周$\mathbb{T}$上的函数$f$上的时候可以被继承。而$\widehat{g}(n)=0$导致其傅里叶级数的部分和$S_n(g)=0$,于是其Cesaro和也是0，从而$g*F_N(x)=0$。而由定理"2.2"我们知道，$F_N$是一个逼近单位元，而[[approximation to the identity#]]的基本性质可知，如果$g$在$x$处连续，那么$$g*F_N(x)\to g(x)$$这意味着对任意$\varepsilon>0$，都有$|g(x)|<\varepsilon$,于是$g(x)=0$。按照$f$的参数化的定义，$g(x)=0$就导致$f(z)$在对应位置的单位圆周上取值也是0。

接着我们可以得到关于函数的傅里叶级数的收敛性的性质：

> [!note] 推论2.4
> 假设$f \in C(\mathbb{T}\to \mathbb{C})$，并且其对应的傅里叶系数形成的级数绝对收敛，即$$\sum_{n\in \mathbb{Z}}|\widehat{f}(n)|<\infty$$那么函数的傅里叶级数的部分和一致收敛到函数本身。

如同"推论2.3"一样，虽然我们要证明的是单位圆周上的连续函数$f$在具有上述性质的时候，其傅里叶级数部分和$\sum_{|n|\leq N}\widehat{f}(n)z^n$一致收敛到$f$，不过我们可以通过对$f$进行参数化，从而只需要处理对应的$[-\pi,\pi]$上的周期函数$g$即可。

在推论2.4的假设下$g \in C([-\pi,\pi]\to \mathbb{C})$，并且其对应的傅里叶系数(经典意义下的)是绝对收敛的，因此其傅里叶级数$\sum_{n\in \mathbb{Z}}\widehat{g}(n)e^{inx}$由Weierstrass判别，自然是一致收敛的。假设$$\sum_{n\in \mathbb{Z}}\widehat{g}(n)e^{inx}\rightrightarrows h(x)$$并且由于一致收敛对连续性的保持，于是$h(x)$也是一个连续函数。并且$h(x)$其傅里叶系数恰好就是$\widehat{g}(n)$。那么如果我们考虑连续函数$g(x)-h(x)$，于是其傅里叶系数皆为0，由"推论2.3"可知$$g(x)-h(x)\equiv 0$$因此我们知道$$\sum_{n\in \mathbb{Z}}\widehat{g}(n)e^{inx}\rightrightarrows g(x)$$因此自然对应的单位圆周上的函数$f$也有此性质。

> [!note] 推论2.5
> 如果$f \in C(\mathbb{T}\to \mathbb{C})$那么可以被$\mathbb{T}$上的多项式一致逼近。

* 此结果可以由[[Stone-Weierstrass定理]]得出，此过程已经在[[模1均匀分布与Weyl判别#1.2 用三角多项式一致逼近函数：$2 iff 3$]]当中的“引理1.2.1”当中给出。
* 这里我们还可以给出一个构造性的证明，因为单位圆周上的函数的参数化的缘故，我们只需要证明对应的$[-\pi,\pi]$上的周期函数$g$可以被对应的$[-\pi,\pi]$上的三角多项式一致逼近即可。因为假设$P(z)$是单位圆周$z \in \mathbb{T}$上的多项式,那么在进行$z = e^{inx}$的参数化以后，$P(e^{inx})$就是一个三角多项式。而因为$g$的性质以及连续性，由“推论2.4”我们知道$$g*F_N(x)\rightrightarrows g(x)$$而$\sigma_N(x):=g*F_N(x)$正是一个三角多项式。
