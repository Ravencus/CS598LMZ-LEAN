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
  - 数论
  - 丢番图逼近
---
### 1. 什么是无理测度?
* 动机:

“所有实数都可以被一列有理数逼近，但有的实数与有理序列更接近一些”

我们知道任何一个无理数都可以被一列有理序列逼近。也就是说对于无理数$\alpha$以及任意$\varepsilon>0$我们都可以找到无穷多组$p,q$其中$q>0,p,q$互素的整数使得$$0<\left|\alpha-\frac{p}{q}\right|<\varepsilon$$但是如果我们提一个“定量问题”呢？这种逼近，究竟有多近？

因为我们要讨论找到无穷多组$p,q$其中$q>0,p,q$互素，然后$\left|\alpha-\frac{p}{q}\right|$究竟有多小的问题。因为是无穷多个$q$,如果我们给这些$q$排个持续的话，我们可以得到一列不减的序列$q_n$，那么我们可以找一个有关的分母的函数$\varphi(q)$看看当$q_n\to \infty$的时候，$\varphi(q_n)$的衰减情况究竟几何。

我们可以问，对于某个无理数$\alpha$是否存在无穷多组$p,q$其中$q>0,p,q$互素使得$$0<\left|\alpha-\frac{p}{q}\right|<\varphi(q)$$
当然丢番图逼近的语境下，更常用的概念是:

> [!note] psi可逼近的数
> 令$\psi:\mathbb{N}\to \mathbb{R}^{+}$为一个正值函数，一个实数$\alpha$称之为$\psi-$可逼近的，如果存在无穷多组$p,q$其中$q>0,p,q$互素的整数满足不等式$$0<\left|\alpha-\frac{p}{q}\right|<\frac{\psi(q)}{q}$$或者引入"实数与最近的整数的距离"的概念，该定义还可以叙述为:$$||q\alpha||<\psi(q)$$对无穷多个自然数$q$成立,其中$||x||:=\min\{|x-n|:n\in \mathbb{Z}\}$。

当然$\psi$的选择要让讨论是有意义的我们要使得它满足$\frac{\psi(x)}{x}\to 0$当$x\to +\infty$的时候。最简单的形式是它是形如$\frac{C}{x^{\mu}}$的形式。对于此类问题，19世纪的研究者发现了下面这样的结果:
1. Dirichlet定理:$\psi(x)=\frac{1}{x}$，然后定理说如果$\alpha$是无理数，那么$\alpha$是$\frac{1}{x}$可逼近的数。证明可以参考:[[Kronecker定理，Dirichlet定理及其应用]]
2. Hurwitz定理(1891):$\psi(x)=\frac{1}{\sqrt{5}x}$,定理说如果$\alpha$是无理数，那么$\alpha$是$\frac{1}{\sqrt{5}x}$可逼近的数。

我们立刻就能发现，同样一个数，可以被多种不同的$\psi$的函数逼近。比如无理数$\alpha$,我们可以说是被$x^{-1}$逼近的，那也可以说是被$x^{-1/2}$逼近的。再比如特殊一点的数，Liouville数，我们可以说它是$x^{-1}$逼近的，因为它是无理数，但也可以说它是$x^{-2},x^{-3}$逼近的。那么我们立刻就会问，假设对于某个具体的无理数$\alpha$，形如$\{x^{-\mu},\mu>0\}$这样的函数里面，指数"最大的"（可能没有最大的）可以逼近$\alpha$的函数是哪个?

于是有下面这样的概念：

> [!note] 无理测度的定义
> $\alpha$是一个实数，定义集合$R$为正实数$s$的集合，其中$s$为使得不等式$$0<\left|\alpha-\frac{p}{q}\right|<\frac{1}{q^{s}}$$存在**无穷多组**整数解$(p,q)$($q>0$并且互素)的正实数。那么$$\mu(\alpha):=\sup_{s>0} R$$称之为实数$\alpha$的无理测度。如果按照$||\cdot||$的语言表述，也就是说$$\mu(\alpha):=\sup_{s>0}\{s:q^{s-1}||q\alpha||<1,\text{for infinitely many }q \in \mathbb{N}\}$$

* 此外无理测度的定义也可以放宽到：$$\mu(\alpha):=\sup_{s>0}\left\{s:\left|\alpha -\frac{p}{q}\right|<\frac{C(\alpha)}{q^{s}}存在无穷多组互素的p,q的解\right\}$$其中$q>0$$p,q$都是整数，$C(\alpha)$是一个只与$\alpha$有关的正实数。也就是说在衡量$\alpha$的有理逼近的速度这一问题上$\frac{C(\alpha)}{q^{s}}$的分子上的常数并不影响其无理测度。这是因为$$无穷多组p,q满足\left|\alpha -\frac{p}{q}\right|<\frac{C(\alpha)}{q^{s}}\implies \mu(\alpha)\geq s$$因为对于任意给定的$\varepsilon$，总是存在无数多组$p,q$并且$q>C^{1/\varepsilon}(\alpha)$于是$\frac{C(\alpha)}{q^{s}}<\frac{1}{q^{s-\varepsilon}}$。那么按照无理测度的定义，我们知道$$\mu(\alpha)\geq s-\varepsilon,\forall\varepsilon>0 \implies \mu(\alpha)\geq s $$另一方面如果$$至多有限多组p,q满足\left|\alpha -\frac{p}{q}\right|<\frac{C(\alpha)}{q^{s}}\implies \mu(\alpha)\leq s$$因此此时如果假设$\mu(\alpha)>s$那么一定存在一个$\mu(\alpha)>r>s$使得存在无数多组$p,q$使得$\left|\alpha -\frac{p}{q}\right|<\frac{1}{q^{r}}$那么也就是说，当$q$足够大的时候都有$$\frac{1}{q^r}>\left|\alpha -\frac{p}{q}\right|\geq \frac{C(\alpha)}{q^{s}}\implies C(\alpha)<\frac{1}{q^{r-s}}$$这便意味着$C(\alpha)=0$，但是这与$C(\alpha)>0$的假设矛盾，因此$\mu(\alpha)>s$的假设不成立，于是$\mu(\alpha)\leq s$。如果我们要用$||x||$来表达，我们也可以记$$\mu(\alpha):=\sup_{s>0}\{s:q^{s-1}||q\alpha||<C(\alpha),对无穷多个q\in \mathbb{Z}^{+}成立\}$$其中$C(\alpha)>0$是一个只与$\alpha$有关的数。

#### 1.1 有理数的无理测度

> [!note] 命题1.1
> 任何有理数的无理测度都是1。

首先我们来看看有理数的无理测度是怎样的。假设$\alpha=\frac{a}{b}$是一个有理数，其中整数$a,b$互素。那么对于任意有理数$\frac{p}{q}$其中$p,q$互素，并且$\frac{p}{q}\neq \frac{a}{b}$那么$$\left|\frac{a}{b}-\frac{p}{q}\right|=\frac{|aq-pb|}{|b|q}\geq \frac{1}{|b|q}$$对任意$s>1$如果$|\alpha - \frac{p}{q}|<\frac{1}{q^s}$要成立，就必须$q^{s-1}<b$。而这个不等式只能对有限多个正整数$q$成立，于是$\mu(\alpha)\leq 1$。

另一方面，对任意的不含$b$作为因子的正整数$q$选取使得$|\alpha-\frac{p}{q}|$最小的整数$p$，于是$$0<|\alpha-\frac{p}{q}|=\frac{1}{q}|q\alpha-p|\leq \frac{1}{q}\cdot \frac{1}{2}=\frac{1}{2q}$$
* 如果$b|q$那么选取使得$|\alpha-\frac{p}{q}|$最小的整数$p$的时候，我们可以选取$p=\frac{aq}{b}$，从而使得$|\alpha-\frac{p}{q}|=0$，这样一来就不符合无理测度的定义了。

于是对任意$s<1$只要$q$足够大就有$\frac{1}{2q}\leq \frac{1}{q^s}$，所以存在无穷多对满足条件的整数$(p,q)$使得不等式$$0<|\alpha-\frac{p}{q}|<\frac{1}{q^s}$$成立。
$$\mu(\alpha)\geq s,\forall s\in (0,1)$$于是综上所述$$\mu(\alpha)=1$$

#### 1.2 无理数的无理测度至少是2

> [!note] 命题1.2
> 无理数的无理测度至少是2。

这与Dirichlet定理有密切的关系。参考[[Kronecker定理，Dirichlet定理及其应用#2.1 Dirichlet定理的推论]]的证明告诉我们，$$q||q\alpha||<1$$对无穷多个正整数$q$成立。按照无理测度的定义，这说明$$\mu(\alpha)\geq 2$$
* 命题1，2通过定量的方式告诉我们，一个数如果保持很高的精度被有理数逼近，那么这一定不是有理数。虽然有理数也可以被有理序列逼近，但是这种逼近的效果是不如无理数的。


####  1.3 无理测度严格大于2的实数其Lebesgue测度为0

> [!note] 命题1.3.1
> 无理测度(Irrational measure)严格大于2的实数是Lebesgue零测度的。

这个命题说明，无理测度严格大于2的无理数其占用的“空间”是很少的，相较于全体无理数的L测度而言。

不失一般性，可以单纯考虑$[0,1]$当中的情况。假设$A =\{\alpha \in[0,1]:\mu(\alpha)>2\}$,其中$\mu$是irrational measure。于是按照[[an epsilon of room]]的想法，我们可以先证明$A_{\varepsilon} =\{\alpha\in[0,1]:\mu(\alpha)>2+\varepsilon\}$的Lebesgue测度$m(A_{\varepsilon})= 0$。因为我们可以有这样的表达式 $A = \cup_{n\geq 1} A_{1/n}$ ,从而如果任意的$A_{\varepsilon}$是零测度的，那么会导致$A$也是零测度的。而证明$A_{\varepsilon}$是零测度的，基本的想法是:"**如果我们要证明一个集合是零测度，那么不妨先找一个能覆盖此集合的集合，然后试着缩小这种覆盖，如果能把这种覆盖在测度的意义下缩小到0，那么便证明了被覆盖的集合的零测度。**"

按照irrational measure的定义，对任意$\alpha \in A_\varepsilon$都存在无数多对$0<p<q$的互素的整数，使得$$\left|\alpha-\frac{p}{q}\right|<\frac{1}{q^{2+\varepsilon}}$$这意味着符合条件的$q$的集合其上确界是无限大，否则的话只有有限对$p,q$能满足上述不等式。这意味着如果我们给定$M>0$一定存在一个$q>M$以及与之互素的$p$，使得$$\alpha
    \in
    I(p,q)=\left(\frac{p}{q}-\frac{1}{q^{2+\varepsilon}},\frac{p}{q}+\frac{1}{q^{2+\varepsilon}}\right)$$不过我们不知道也很难知道，给定$\alpha$对应的具体的$p,q$是什么，但是没有关系这个问题不需要知道确切的这方面的信息，因为我们只需要给出覆盖$A_{\varepsilon}$的一个合适的上界的估计即可。

##### 1.3.1 覆盖$A_{\varepsilon}$的集合其测度的上界估计

给定$M$，$\forall \alpha \in A_{\varepsilon }$，$\alpha \in I(p_{\alpha},q_{\alpha}),q_{\alpha}>M$，虽然具体是什么很难说，但是一定有$$\forall
    \alpha \in \bigcup_{q> M \text{ and } p<q}
    I(p,q)$$那么$$\begin{aligned}m(A_{\varepsilon})&\leq
    \sum_{q> M \text{ and } p<q} m(I(p,q))\\ & =
    \sum_{q=M+1}^{\infty}\sum_{p=1}^{q-1}
    \frac{2}{q^{2+\varepsilon}} \\
    &\leq\sum_{q=M+1}^{\infty}\frac{2}{q^{1+\varepsilon}}
    \\&=\int_{M+1}^{\infty}\frac{1}{x^{1+\varepsilon}}dx+O\left(\frac{1}{M^{1+\varepsilon}}\right)
    \\ &=
    O\left(\frac{1}{M^{\varepsilon}}\right)\end{aligned}$$因为$M$是任意正整数，令$M \to +\infty$于是$m(A_{\varepsilon}) = 0$。当然上述命题也可以通过[[Borel-Cantelli lemma及其应用]]去证明。

##### 1.3.2 用Borel-Cantelli引理简化上述过程

假设我们定义$E_{\varepsilon,q}=\cup_{p=0}^{q-1}I(p,q)$,那么所有那些无理测度严格大于$2+\varepsilon$的实数构成的集合$A_{\varepsilon}$中的元素满足，$\alpha \in A_{\varepsilon}$，那么对任意的$M>0$都有$\alpha \in \cup_{q>M} E_{\varepsilon,q}$。也就是说$$A_{\varepsilon}\subseteq \limsup_{q\to \infty}E_{\varepsilon,q}$$于是按照Borel-Cantelli引理，我们只需要搞清楚$m(E_{\varepsilon,q})$的增长幅度即可。根据上面的分析$$m(E_{\varepsilon,q})=O\left(\frac{1}{q^{1+\varepsilon}}\right)$$因此这就能保证$\sum_{q\geq 1}m(E_{\varepsilon,q})$收敛，于是$m(\limsup_{q\to \infty}E_{\varepsilon,q})=0$,于是$$m(A_{\varepsilon})=0$$
#### 1.4 与Badly approximable之间的关系

> [!note] badly approximable的数
> 实数$\alpha$被称之为badly approximable如果存在一个正实数$C(\alpha)$使得任意有理数$\frac{p}{q}$都有$$\left|\alpha-\frac{p}{q}\right|\geq \frac{C(\alpha)}{q^2}$$
* 我们对定义稍微变一下形式，可以写成$$q|q\alpha-p|\geq C(\alpha)$$对任意整数$p$以及正整数$q$成立。然后由于$||x||$的定义：$x$与最近的整数的距离。我们知道$$q|q\alpha-p|\geq q||q\alpha||$$所以如果$\alpha\in \mathbf{Bad}$，那么一定对于任意的$q \in \mathbb{Z}^{+}$都有$q||q\alpha||\geq C(\alpha)$。反过来，如果对于任意的$q \in \mathbb{Z}^{+}$都有$q||q\alpha||\geq C(\alpha)$，那么一定对于任意的$(p,q)\in \mathbb{Z}\times \mathbb{Z}^{+}$都有$q|q\alpha-p|\geq q||q\alpha||\geq C(\alpha)$。因此badly approximable的定义还可以等价地定义为$$\alpha \in \mathbf{Bad} \iff \exists C(\alpha)>0,s.t. q||q\alpha||\geq C(\alpha),\forall q\in \mathbb{Z}^{+}$$
* 进一步这个概念还可以叙述为$$\alpha \in \mathbf{Bad} \iff \liminf_{q\to \infty }q||q\alpha||>0$$因为如果$\alpha\in \mathbf{Bad}$那么,对任意的自然数$q$都有$q||q\alpha||\geq C(\alpha)>0$于是$$\liminf_{q\to \infty}q||q\alpha||\geq C(\alpha)>0$$反过来如果$\liminf_{q\to \infty}q||q\alpha||=A(\alpha)>0$那么根据[[函数与序列的上下极限]]当中的命题，这意味着至多存在$N$个$q$使得$0<q||q\alpha||<A(\alpha)$那么只要令$B(\alpha):=\min_{1\leq q\leq N}\{q||q\alpha||\}$如此一来只需要令$$C(\alpha):=\min\left\{\frac{A(\alpha)}{2},B(\alpha)\right\}$$那么我们就知道对任意的正整数$q$都有$$q||q\alpha||\geq C(\alpha)>0$$于是$\alpha\in \mathbf{Bad}$。

> [!note] 命题1.4.1
> 所有Badly approximable的实数，形成的集合是Lebesgue零测度的，即$$m(\mathbf{Bad})=0$$
> 

事实上我们只需要证明$\mathbf{Bad}\cap [0,1]$是零测度的即可。因为假设$x \in \mathbf{Bad}\cap [k,k+1]$，那么因为$||qx|| = ||q(x-k)||$所以$$k+\mathbf{Bad}\cap [0,1]=\mathbf{Bad}\cap [k,k+1]$$而Lebesgue测度是具有平移不变性的，因此只要$\mathbf{Bad}\cap [0,1]$是零测度的，那么其余区间的情况都是零测度，而可数个零测度的集合并依旧是零测度的，因此只需要处理一个区间的就够了。

* 这个问题首先对于每个点的直接的覆盖是没有的，这与1.3.1的命题完全不同。其次我们也不可能像证明$m(\mathbb{Q})=0$那样在每个元素周围找一个很小的区间，然后保证区间总和是可以被任意$\varepsilon$控制的，因为这基于元素个数可数，但是$\mathbf{Bad}$这个集合可未必是可数的。
* 其次我们也不好像证明1.3.1那样去给出一个任意调整测度大小的，关于$\mathbf{Bad}\cap [0,1]$的覆盖。不过既然正面走不通，是否可以考虑证明其补集，那些不属于$\mathbf{Bad}$的集合是满测度的。基于这样的想法，有下面的证明:

这个结果完全可以看作是[[Khintchine定理]]的一个推论，因为$\psi-$approximable的数的集合含义是$$A_{\psi}:=\{x\in \mathbb{R}:||qx||<\psi(q) \text{ for infinitely many }q \in \mathbb{N}\}$$也就等于说$$x\in A_{\psi}\implies \inf_{q\in \mathbb{N}} q||qx||\leq \inf_{q\in \mathbb{N}}q\psi(q)$$也即是说，只要$\psi(q)=o(1/q)$那么这个集合里面的数一定不属于$\mathbf{Bad}$，也就是说$$\mathbf{Bad}\cap [0,1]\subset [0,1]\setminus A_{\psi}$$那么如果我们能找到一个$\psi$使得，$m(A_{\psi}\cap [0,1])=1$那么岂不是说$m([0,1]\setminus A_{\psi})=0$,也就是说$$m(\mathbf{Bad}\cap [0,1])=0$$从而$m(\mathbf{Bad})=0$。

所以这样的$\psi$成立吗？这个函数需要满足两个条件：
1. [[Khintchine定理]]给出了一个充分条件，要$\psi(q)$作为一个单调减少的值为正实数的函数，其衰减得足够慢,以至于正项级数$\sum_{q\geq 1}\psi(q)$是发散。
2. $q\psi(q)\to 0$。
这样的函数其实挺多的，例如$$\psi(q):=\frac{1}{q\log(q)}$$
因此命题得到了证明。

* 如果$\alpha$是badly approximable的数那么根据之前关于$\left|\alpha-\frac{p}{q}\right|\geq \frac{C(\alpha)}{q^2}$的系数以及无理测度的讨论，我们知道此性质可以导出$\mu(\alpha)\leq 2$。同时结合"命题1.4.1"以及"1.3.1"，以及结合Roth定理（代数无理数的无理测度为2），以及代数数的可数性，我们知道：从Lebesgue测度的角度而言，绝大多数无理数即非badly approximable，也非无理测度严格大于2，也并非代数数。即大多数无理数都是超越数，其被有理数逼近的情况，既不是太好。这样的一个典型代表就是$e$。$e$首先是一个超越数，其次$\mu(e)=2$，然后$e$并非badly approximable的。

我们可以从连分数的角度来判断一个数是否是badly approximable的数。

> [!note] 定理1.4.2
> 设实无理数$\alpha$写成连分数为$[a_0;a_1,a_2,\cdots]$是badly approximable的数，当且仅当存在正实数$C$使得$$a_n\leq C,\forall n \in \mathbb{N}$$

我们之所以从连分数的角度考虑实数被有理数逼近的情况，是因为下面的这个概念：

> [!note] 定义1.4.3:最佳逼近的定义
> 令$\alpha\in \mathbb{R}$。正整数$q$称之为$\alpha$的最佳逼近如果$$\forall q'\in \mathbb{N},q'<q\implies ||q'\alpha||>||q\alpha||$$


我们用下面的图像可以更为直观地理解这个定义：

```mathematica
(*距离最近整数的距离*)dist[x_?NumericQ] := Abs[x - Round[x]];

nMax = 1000;                                (*横轴最大 n*)
vals = Table[{n, dist[n  Sqrt[2]]}, {n, nMax}];

(* \[LongDash]\[LongDash]提取\[OpenCurlyDoubleQuote]刷新纪录\
\[CloseCurlyDoubleQuote]的点\[LongDash]\[LongDash]*)
bestPoints = 
  Reap[FoldList[
     Function[{min, pt},(*pt={n,value}*)
      If[Last[pt] < min, Sow[pt]];(*只有刷新 min 时才 Sow*)
      Min[min, Last[pt]]                        (*继续传递当前最小值*)], 
     Infinity,(*初始 min 很大*)vals]][[2, 
    1]];                                       (*把 Sow 到的点取出来*)

(* \[LongDash]\[LongDash]绘图，红色标注 best approximations\[LongDash]\
\[LongDash]*)
DiscretePlot[dist[n  Sqrt[2]], {n, 1, nMax}, Filling -> None, 
 PlotStyle -> Blue, PlotRange -> All, 
 AxesLabel -> {"n", "‖nsqrt{2}‖"}, 
 Epilog -> {Red, PointSize[Medium], Point[bestPoints]}]
```

具体过程就是，我们考虑$r_n:=||n\sqrt{2}||$当$n=1,\cdots,N$的结果。我们先认为$r_1$就是最小的值，而对应的$n_1=1$就是第一个对于$\sqrt{2}$而言的最佳逼近。然后等到第一个出现$r_{n_2}<r_{n_1}$的时候，把$n_2$记为下一个最佳逼近，然后依此类推。在图像上，标注所有的$r_{n_k}$为红色其余的点为蓝色。

![[根号2的最佳逼近.png]]

现在我们来看连分数的一个性质：

> [!note] 定理1.4.4
> 令$\alpha$是一个无理数，正整数$q$为$\alpha$的最佳逼近，当且仅当$q$是$\alpha$对应的的连分数展开的某个收敛分数（convergent）的分母。

* 假设$\alpha=[a_0;a_1,\cdots,a_n,\cdots]$这个连分数的第n个convergent指的是$$\frac{p_n}{q_n}=[a_0;a_1,\cdots,a_n]$$（这里连分数$p_n,q_n$自动是互素的）也就是说，$q$是$\alpha$的最佳逼近，当且仅当$q=q_n$对某个$n$成立。

---

现在回到对"定理1.4.2"的证明上：

首先回忆badly approximable的等价定义，$$\alpha \in \mathbf{Bad} \iff \liminf_{q\to \infty }q||q\alpha||>0$$从连分数的角度来看，由于$q_n$是$\alpha$的最佳逼近，那么对于任意的$q_n\leq q<q_{n+1}$而言$q||q\alpha||\geq q_n||q_n\alpha||$这就意味着$$\liminf_{q\to \infty}q||q\alpha||=\liminf_{n\to \infty}q_n||q_n\alpha||$$于是我们得到了badly approximable的连分数角度的新的等价定义:
$$\alpha \in \mathbf{Bad} \iff \liminf_{n\to \infty}q_n||q_n\alpha||>0$$从这个角度出发，联系到连分数分母的递推关系，我们得到$$\frac{1}{(a_{n+1}+1)q_n+q_{n-1}}=\frac{1}{q_n+q_{n+1}}<|q_n\alpha-p_n|<\frac{1}{q_{n+1}}=\frac{1}{a_{n+1}q_n+q_{n-1}}$$两边都做一下放缩可以得到$$\frac{1}{(a_{n+1}+2)q_n}<|q_n\alpha-p_n|<\frac{1}{a_{n+1}q_n}$$因此只要$q_n\geq 2$那么一定有$|q_n\alpha-p_n|=||q_n\alpha||$于是$$\frac{1}{a_{n+1}+2}<q_n||q_n\alpha||<\frac{1}{a_{n+1}}$$于是$$\liminf_{n\to \infty}\frac{1}{a_{n+1}+2}\leq \liminf_{n\to \infty}q_n||q_n\alpha||\leq \liminf_{n\to \infty}\frac{1}{a_{n+1}}$$
所以:
1. 如果$a_n$是有上界的正整数序列，那么$\liminf_{n\to \infty}q_n||q_n\alpha||>0$,因此$\alpha \in \mathbf{Bad}$。
2. 如果$\alpha \in \mathbf{Bad}$，那么$\liminf_{n\to \infty}q_n||q_n\alpha||>0$从而$\liminf_{n\to \infty}\frac{1}{a_{n+1}}>0$，从而$a_n$必然是有上界的序列。

因此“定理1.4.2”得到了证明。

---

* 从这里我们便能看出来$e$为何不是一个badly apprximable的无理数。因为$e=[2;1,2,1,1,4,1,1,6,1,1,8,1,1,10,\cdots]$其规律是$a_0=2$然后$a_{3k-1}=2k$其余的$a_k=1$。这样就告诉我们$a_n$是无界的，因此按照“定理1.4.2”$$e\not\in \mathbf{Bad}$$
* 另一方面，我们知道$\sqrt{2}=[1;2,2,2,2\cdots]$因此对于$\sqrt{2}$由于$a_n\leq 2$那么按照"定理1.4.2"我们知道$$\sqrt{2}\in \mathbf{Bad}$$


### 3. 代数数的无理测度


> [!note] 定理3.1:Liouville定理（1844）
> 如果$\alpha$是一个d次代数数($d\geq 2$)，那么存在一个常数$C(\alpha)>0$使得不等式$$\left|\alpha-\frac{p}{q}\right|>\frac{C(\alpha)}{q^d}$$对任意正整数$q$以及任意整数$p$成立。

* 通过前文对无理测度的分析我们知道，这个说法等价于说$$\mu(\alpha)\leq d$$
Liouville的核心想法是对$\alpha$的极小多项式使用Lagrange中值定理，中值定理的开区间的端点为$\alpha,\frac{p}{q}$，这样只需要对多项式做简单的下界估计就可以得到定理中的不等式。

具体来说，假设$$f(x):=a_0+a_1x+\cdots+a_dx^d$$是$\alpha$在$\mathbb{Z}[x]$当中的极小多项式。这个多项式具有性质:
1. $\deg f=d$这来自于$\alpha$是$d$次代数无理数的定义。
2. $f$是不可约的。因为如果其可约，那么一定存在次数更小的以$\alpha$为复根的整系数多项式，这与极小多项式的定义矛盾。

由于我们要借助$\frac{f(\alpha)-f(p/q)}{\alpha-p/q}=f'(\xi)$的形式得到$|\alpha-p/q|$的下界估计，考虑到$f(\alpha)=0$以及$f(p/q)\neq 0$，我们最终要估计的对象是$\frac{|f(p/q)|}{|f'(\xi)|}$。

1. 关于$|f(p/q)|$:$$f(p/q)=\frac{1}{q^d}A$$其中$A$一定是一个整数，因为我们相当于对$f(p/q)$进行了一个通分的处理，既然是整数那么$|A|\geq 1$。于是我们得到$$|f(p/q)|\geq \frac{1}{q^d}$$
2. 关于$|f'(\xi)|$:虽然我们无法确定多项式的形式，以及$\xi$的确切位置但是仔细观察我们发现我们实际上只需要确定$|\alpha-p/q|\leq 1$的那些$p,q$即可。因为当$|\alpha-p/q|> 1$的时候，由于任意正整数$q$都可以使得$1/q^d\leq 1$因此天然就有$|\alpha-p/q|>\frac{1}{q^d}$符合我们期望的形式。而对于$|\alpha-p/q|\leq 1$的情况，我们是可以确定$\xi$的一个位置的范围$\xi\in (\alpha-1,\alpha+1)$于是$|f'(x)|$作为一个连续函数在$[\alpha-1,\alpha+1]$上一定存在最大值$M$，从而使得$$|f'(\xi)|\leq M$$
* 这里其实也体现了用中值定理做估计的一个缺点，我们需要确定$\xi$的范围，并且没有办法给到精确的估计。关于这一点的讨论还可以参考笔记:[[含参数一元函数的不等式]]。

于是最终我们只需要令$C(\alpha):=\max\{\frac{1}{M},1\}$，我们就可以说$$\left|\alpha-\frac{p}{q}\right|>\frac{C(\alpha)}{q^d}$$任意正整数$q$以及任意整数$p$成立。

* 根据这个结果Liouville构造出了历史上第一个被严格证明的超越数，即[[Liouville数]]。

* 关于此证明的一个视频讲解，参考[b站：这个定理间接产生了两个菲尔兹奖成果](https://www.bilibili.com/video/BV1dEKtzvEFZ)

---


> [!note] Thue–Siegel–Roth定理，1955
> 所有代数无理数的无理测度都是2。

* 参考:https://en.wikipedia.org/wiki/Roth%27s_theorem