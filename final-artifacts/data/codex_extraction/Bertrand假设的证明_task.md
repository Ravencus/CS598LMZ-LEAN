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
  - 数论
---

> [!note] Bertrand postulate(1845)
> 对于任意的正整数$n$,区间$(n,2n]$之间必然有一个素数。

这个猜想在1850年被Chebyshev证明,后来Erdos在1932年给出了一个更为简单的证明。

### 1. Erdos的证明

首先Erdos知道这样一个结果：

> [!note] lemma1
> 对于正整数$n\geq 3$,组合数$\binom{2n}{n}$不可能包含$\frac{2n}{3}<p\leq n$的素因子。

**整个证明都是围绕着组合数$\binom{2n}{n}$的素因子$p$展开的**。如果Bertrand假设是不成立的，那么此组合数不会有任何素因子$p$，这显然是矛盾的，因为:
1. $p>2n$是不可能的，因为所有该组合数的素因子都要整除$(2n)!$.
2. $p=2n$也不可能，因为后者是偶数。
3. $n<p<2n$也不可能，因为我们假设Bertrand假设是错误的。
4. $\frac{2n}{3}<p\leq n$也不可能，因为lemma1。
5.  那么$p\leq \frac{2n}{3}$可能吗？也不可能，至少对较大的n是不可能的。

如此一来，就会产生矛盾，于是我们的假设是错误的，因此$n<p<2n$当中应当有素因子才对。

所以接下来如果要完成Erdos的证明，就需要完成4，5这两个部分的证明。

#### 1.1 lemma1的证明

借用[[从二项式系数到Kummer定理#1. Legendre公式]]当中的p-adic valuation的记号，我们这里要证明组合数没有满足$2\leq \frac{2n}{3}<p\leq n$的素因子，也就是证明：$$\nu_p\left(\binom{2n}{n}\right)=\nu_p(2n!)-2\nu_p(n!)=0$$
首先考虑$\nu_p(2n!)$，这个式子的含义是，$p^{\nu_p(2n!)} || 2n!$,即$p$的$\nu_p(2n!)$次方**恰好**（意味着不多不少，没有更多素因子）可以整除于$2n!$。

由条件$2\leq \frac{2n}{3}<p\leq n$，我们知道$1,\cdots,n,n+1,\dots,2n$当中必定会包含$p$。那么这2n个正整数当中是否还存在另外的含有$p$作为素因子的正整数？$2p$恰好是这样一个数。那么是否还有更多的这样的数？要回答这个问题，我们首先想到这2n个正整数当中含有素因子$p$的元素必须满足:
1. 形如$kp$,$k$是正整数。
2. $kp\leq 2n$
那么除了$p,2p$以外就不会有别的满足这两个条件的正整数了，因为$3p>2n$。这也是为何Erdos的证明当中以$\frac{2n}{3}$作为分段处理的断点。

由上面的分我们知道，任意满足条件$2\leq \frac{2n}{3}<p\leq n$的素数都有$\nu_p(2n!)=2$，以及$\nu_p(n!)=1$于是$$\nu_p(2n!)-2\nu_p(n!)= 0\implies \nu_p\left(\binom{2n}{n}\right) =0$$
因此不可能有$p$满足$2\leq \frac{2n}{3}<p\leq n$的同时还整除$\binom{2n}{n}$.

#### 1.2 $p\leq \frac{2n}{3}$也不可能

> [!tip] 核心想法
> 如果$p\leq \frac{2n}{3}$那么我们可以得到一个关于组合数的上界估计$$\binom{2n}{n}\leq 4^{2n/3}(2n)^{\sqrt{2n}}$$
> 而我们还可以知道，对于组合数我们有一个很粗糙的下界：
> $$\binom{2n}{n}>\frac{4^n}{2n+1}$$
> 
> （这个结果可以结合二项式定理证明，因为$\binom{2n}{n}$是$(1+1)^{2n}$的展开的$2n+1$项当中最大的一个）
> 
> 那么二者结合起来就会得到一个不等式的关系,即$$\frac{4^n}{2n+1}\leq 4^{2n/3}(2n)^{\sqrt{2n}}$$
> 
> 左边的序列增长速度是慢于右边的，那么不等式至多只能对有限个$n$成立，这就是矛盾的关键。
> 
>经过验证这个不等式必须要对$n\leq 506$的整数才能成立，那么问题就变成了我们只要验证有限个$n$，就能证明Bertrand的假设是对的。

这里的验证就是通常的一元不等式的问题，完全没有必要手算，可以借助Wolfram/Mathematica解决，不过也有一定的技巧:

> [!note] Wolfram当中使用Reduce函数求解不等式的技巧
> 在使用Reduce解决不等式问题的时候，最好不要让变量出现在指数上。如果变量在指数上，先取对数，然后输入到Reduce函数当中。

于是我们最终输入到Wolfram当中的式子是:
```mathematica
Reduce[Assuming[n > 0, 
  2*n*Log[2]/3 < (Sqrt[2*n] + 2)*Log[2*n]], n, Integers]
```

如何能把组合数的上界与素数的范围$p\leq \frac{2n}{3}$联系在一起呢？观点就是，组合数也是整数，整数由算术基本定理存在唯一的素因分解。我们假设对任意的组合数的素因子而言，其**素因子的最高次幂$\nu_p\left(\binom{2n}{n}\right)$简写为$r_p(n)$**。那么$$\binom{2n}{n}=\prod_{p\leq 2n/3}p^{r_p(n)}$$
当然这样是不足以得到最后的上界的，还要注意其他的一些性质:

> [!note] lemma2
> p是素数，n是正整数，那么$$\prod_{p\leq n} p < 4^n$$

* 这个问题可以用归纳法证明，详细证明参考:[[对素数连乘积的粗糙上界估计]]

> [!note] lemma3
> 对于正整数$n>1$以及素数p，$$p^{r_p(n)}\leq 2n<p^{r_p(n)+1}$$或者也可以理解为$$r_p(n)=\lfloor\log_{p}(2n)\rfloor$$此处$r_p(n)$表示组合数$\binom{2n}{n}$当中素因子$p$的指数。

* **关于lemma3的证明**:
* **为什么不用这个结果直接估计？**
lemma3直接给出了上界，那么$$\binom{2n}{n}=\prod_{p\leq 2n/3}p^{r_p(n)}\leq (2n)^{\pi(2n/3)}\leq (2n)^{2n/3}$$
可是我们如果稍微验证一下就会发现不妥，
```wolfram
Reduce[Assuming[
  n > 0, (2*n/3)*Log[2*n] >= n*Log[4] - Log[2*n + 1]], n, Integers]
```
这个结果是显然成立的，只要对于任意的$n\geq 1$都是成立的，这就达不到制造矛盾的效果。于是我们明白，**想要制造矛盾需要，上界的增长级别是小于下界的增长级别的，从而才能导致在某个$n>N$以后产生矛盾。**

当然此处我们也不应该从$\pi(2n/3)$的更精确的估计下手，否则我们这里就会变成欲证明Bertrand假设需要先证明一个更为困难的和素数分布函数有关的命题。

因此我们的目标是，**要在使用平凡的关于素数分布函数的不等式，即$\pi(x)<x$的估计的条件下，让上界估计变得更精确，精确到增长级别小于下界。**

* **结合lemma2进行分段估计**：

Erdos给出的解决方案是，结合lemma2的结果进行分段估计。分段的理由是，既然lemma3告诉我们，$p^{r_p(n)}\leq 2n$，那么如果$r_p(n)\geq 2$那么此时$p\leq \sqrt{2n}$.换句话说，如果$\frac{2n}{3}\geq p>\sqrt{2n}$那么$r_p(n)=1$,这两段的行为不同于是有必要进行分段估计，于是:

$$\begin{aligned}\binom{2n}{n}&=\prod_{p\leq 2n/3}p^{r_p(n)} \\ &= \prod_{p\leq \sqrt{2n}} p^{r_p(n)}\prod_{\sqrt{2n}<p \leq \frac{2n}{3}} p^{r_p(n)} \\ &= \prod_{p\leq \sqrt{2n}} p^{r_p(n)} \prod_{\sqrt{2n}<p \leq \frac{2n}{3}} p  \\ &\leq \prod_{p\leq \sqrt{2n}}2n \prod_{p \leq \frac{2n}{3}} p \\ &\leq (2n)^{\pi(\sqrt{2n})}4^{2n/3}\\ &\leq (2n)^{\sqrt{2n}}4^{2n/3}\end{aligned}$$

这里分段的想法让我们想起了[[分段估计]]当中的认识，**如果我们估计的手法粗糙，产生的误差大，那么就让被估计的这一段尽可能短一些，这样也同样能降低误差。**


### 2. 根据Chebyshev的思路给出的证明

Chebyshev的证明本质上是关于素数计数函数$\pi(x)$的估计的。Chebyshev证明了$$C_1\frac{x}{\log(x)}<\pi(x)< C_2\frac{x}{\log(x)} $$
其中$C_1\approx 0.92,C_2\approx 1.1$,于是我们只需要证明:$$\pi(2x)-\pi(x)\geq 1$$即可，也就是说只需要去解不等式$$C_1\frac{2x}{\log(2x)}-C_2\frac{x}{\log(x)}\geq 1$$而这个不等式对于$x\geq 8$的情况都成立，于是很容易验证Bertrand Postulate是成立的。

在Chebyshev的证明中，他引入了两个辅助函数:

> [!note] Chebyshev引入的辅助函数
> Chebyshev第一函数:
> $$\theta(x)=\sum_{p\leq x}\log(p)$$ 
> Chebyshev第二函数:
> $$\psi(x):=\sum_{n\leq x}\Lambda(n)$$其中$\Lambda(n)$表示Von Mangoldt函数，定义为:$$\Lambda(n):=\begin{cases}\log(p)&n=p^k,k\geq 1\\0&\text{Otherwise}\end{cases}$$

这两个辅助函数一个是不超过$x$的素数的对数求和，另一个是加权对数求和。这一点在下面这个关于第二Chebyshev函数的引理当中得到体现：


---

> [!note] lemma1
> $$\psi(x)=\sum_{p\leq x}\left\lfloor\frac{\log(x)}{\log(p)}\right\rfloor\log(p)$$

这个结果并不难从此函数的定义当中得到。结合Von Mangoldt函数的定义，该函数可以表示为$$\begin{aligned}\psi(x)&=\sum_{p^k\leq x;p\in \mathbb{P}}\log(p)\\&=\sum_{p\leq x}\log(p)\sum_{k\leq \left\lfloor\frac{\log(x)}{\log(p)}\right\rfloor}1 \\&=\sum_{p\leq x}\left\lfloor\frac{\log(x)}{\log(p)}\right\rfloor\log(p)\end{aligned}$$

---

Chebyshev的考虑是，这两个辅助函数会比$\pi(x)$更容易研究(why?),并且他注意到这两个辅助函数与$\pi(x)$这样的关系:

> [!note] Chebyshev函数与素数计数函数之间的关系
> 当$x\geq 2$的时候有:
> 1. $$\theta(x)=\psi(x)+O(\sqrt{x})$$
> 2. $$\pi(x)=\frac{\psi(x)}{\log(x)}+O\left(\frac{x}{\log^2(x)}\right)$$

所以本质上来说，只要我们可以对$\psi(x)$做好估计，也就能估计$\pi(x)$,比如说如果我们可以证明$\psi(x)\sim x$那么我们就可以证明素数定理。不过此处我们的主要目标还是Bertrand postulate，还不需要证明更强的素数定理，所以实际上我们的目的是给出估计$$C_1\frac{x}{\log(x)}<\pi(x)< C_2\frac{x}{\log(x)}$$
而整个过程是通过对两个Chebyshev函数做出估计得到的。以下的估计并非Chebyshev原始的证明，而是参照Erdos估计素数计数函数做出的估计(参考[[Erdos关于pi函数的估计]])。

#### 2.1 尝试用Erdos风格的做法估计Chebyshev第二函数

> [!note] 目标1
> 证明，存在两个正实数$a_1,a_2$使得$$a_1x<\psi(x)< a_2x $$当$x\geq 2$的时候。

Erdos风格的一个证明主要是在$\binom{2n}{n}$上下文章。

##### 2.1.1 下界估计
令$b_n=\binom{2n}{n}$,那么$$\log(b_n)=\sum_{p\leq 2n}v_p(b_n)\log(p)$$
其中$v_p(b_n)$表示$b_n$的素因子$p$的指数，按照Legendre公式(参考[[从二项式系数到Kummer定理]])可以表示为$$v_p(b_n)=\sum_{k\geq 1}\left(\left\lfloor\frac{2n}{p^k}\right\rfloor-2\left\lfloor\frac{n}{p^k}\right\rfloor\right)\leq \sum_{k\leq \left\lfloor\log_p(2n)\right\rfloor}1=\left\lfloor\frac{\log(2n)}{\log(p)}\right\rfloor$$
这是一个粗糙的估计，这里的想法不过是认为，但凡$p^k>2n$,级数当中的被求和对象必然是0.

如此一来，我们可以把$\log(b_n)$表示为:$$\log(b_n)\leq \sum_{p\leq 2n}\left\lfloor\frac{\log(2n)}{\log(p)}\right\rfloor\log(p)$$
而后者根本就是$\psi(2n)$.


而我们是知道$b_n$的一个下界估计的，在本文的第一个部分已经证明过。模仿[[Erdos关于pi函数的估计]]的1当中的做法，一旦我们得到$\psi(2n)$的估计，我们就能得到对于$x>8$的情况下$\psi(x)$的估计，即$$n\log(4)-\log(2n+1)<\log(b_n)\leq \psi(2n)$$
于是当$x>8$的时候有$$\psi(x)>\frac{3}{4}\log(2)x-\log(9x/16+1)>a_1x$$
在$x\geq 250$的情况下$a_1=0.5$.大概也就是如此了，因为不等式中间的函数的渐近展开$x$项的系数就是$3\log(2)/4 \approx 0.52$左右。

解上面得不等式完全可以通过计算机去完成.只需要定义出来Chebyshev第二函数，然后使用Reduce函数解出不等式即可。

```wolfram
ChebyshevPsi[x_] := 
 Sum[Log[Prime[n]]*Floor[Log[x]/Log[Prime[n]]], {n, 1, PrimePi[x]}]
```

##### 2.1.2 上界估计

* **先得到$\theta(x)$的上界估计**

同样参考Erdos的风格，上界可以从不等式$$b_n=\binom{2n}{n}=\prod_{p<2n}p^{v_p(n)}>\prod_{n<p<2n}p$$
入手，当$n>1$的时候$$\log(b_n)>\sum_{n<p< 2n}\log(p)=\theta(2n)-\theta(n)$$
如同[[Erdos关于pi函数的估计]]当中得到下界估计一样的操作，我们可以轻易得通过二项式定理得到一个$b_n$的一个上界，于是我们得到:$$\theta(n)-\theta(n/2)<n\log(2)$$
然后根据$$\theta(2^k)<\theta(1)+\sum_{1\leq i\le k}2^i\log(2)=2\log(2)(2^k-1)$$
于是因为$2^{k-1}<x\leq 2^{k}$，因此得到:$$\theta(x)\leq \theta(2^k)<2\log(2)(2^k-1)<2\log(2)(2x-1)<4\log(2)x$$
其中$4\log(2)\approx 2.77$，对任意$x\geq 1$成立.

* **然后估计$\theta(x)$与$\psi(x)$二者的误差**

利用lemma1的表达，我们可以看出二者之间的差异$$\begin{aligned}\psi(x)-\theta(x)&=\sum_{p\leq x}\log(p)\sum_{1\leq k\leq \left\lfloor\frac{\log(x)}{\log(p)}\right\rfloor}1-\sum_{p\leq x}\log(p)\\ &= \sum_{p\leq \sqrt{x}}\log(p)\sum_{2\leq k\leq \left\lfloor\frac{\log(x)}{\log(p)}\right\rfloor}1\\ &\leq \sum_{p\leq \sqrt{x}}\log(p)\left\lfloor\frac{\log(x)}{\log(p)}\right\rfloor \leq  \sqrt{x} \log(x) \end{aligned}$$
所以$$\psi(x)\leq \theta(x)+\sqrt{x} \log(x) \leq 4\log(2)x+\sqrt{x} \log(x)$$
解一个不等式，不难得到当$x\geq 893$的时候，$$\psi(x)<3 x$$
也就是说最终得到结论:$$\frac{x}{2}<\psi(x)< 3x $$其中下界成立需要$x\geq 250$,而上界成立需要$x\geq 893$.

实际上结合[[Erdos关于pi函数的估计]]的结论，我们按照Erdos的风格，在$\binom{2n}{n}$上做文章，可以得到以下的最早是Chebyshev得到的结论：

> [!note] Chebyshev估计
> 1. $\psi(x)\asymp x$
> 2. $\theta(x)\asymp x$
> 3. $\pi(x)\asymp x$

但是，我们要看到**Erdos这个估计的误差是非常大的，精度远远及不上Chebyshev当时给的精度，虽然证明方法完全初等。**
