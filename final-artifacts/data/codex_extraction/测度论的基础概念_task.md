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
---
### 1. 外测度

> [!note] 定义1：抽象意义下的外测度
> $\mathcal{P}(X)$为集合$X$的所有子集的集合，现在定义一个映射$\mu^{*}:\mathcal{P}(X)\to [0,+\infty]$满足性质:
> 1. 把空集映射到0：$$\mu^{*}(\varnothing)=0$$
> 2. 单调性:如果$A,B \in \mathcal{P}(X)$,并且$A\subseteq B$那么$$\mu^{*}(A)\leq \mu^{*}(B)$$
> 3. 可数的次可加性：如果有可数个集合$A_1,\cdots A_i\cdots\in \mathcal{P}(X)$那么$$\mu^{*}\left(\bigcup_{i\geq 1}A_i\right)\leq \sum_{i\ge 1}\mu^{*}(A_i)$$那么这种映射就称之为集合$X$上的外测度。

* 比如说我们用覆盖某个集合的$d$维超立方体的体积的下确界可以定义出$\mathbb{R}^d$上的外测度，因为其满足上面的三个基本性质。

### 1.1 通过外测度构造测度

然而我们定义测度的动机是在不规则的集合上推广"体积，面积，长度"等概念，既然如此，现在外测度的次可加性是不够的，我们想要的是如果两个集合是不相交的，那么应该满足$$\mu^{*}(A\cup B)=\mu^{*}(A)+\mu^{*}(B)$$甚至是满足可数可加性，如果$A_1,\cdots,A_i,\cdots$，其中两两不相交，那么$$\mu^{*}\left(\bigcup_{i\geq 1}A_i\right)= \sum_{i\ge 1}\mu^{*}(A_i)$$然而如果我们考虑选择公理，那么$P(X)$当中会有一些元素并不满足我们想要的性质，因此我们需要把那些能满足这样的好的性质的集合给筛选出来，这种被筛选出来的性质更好的集合称之为$\mu-$可测集。

> [!note] Caratheodory意义下的可测
> $\mu$是集合$X$上的外测度，那么集合$E\in \mathcal{P}(X)$被称之为$\mu^{*}-$可测集，如果其满足对任意的$A\in\mathcal{P}(X)$都有 $$\mu^{*}(A)=\mu^{*}(A\cap E)+\mu^{*}(A\setminus E)$$对于一个$\mu^{*}-$可测集$E$，其对应的测度就是$\mu^{*}(E)$。

如果我们把全体$\mu-$可测的集合，或者说$\mathcal{P}(X)$的一个满足上述性质的子集表示为$\Sigma$,那么这个子集实际上是有一定的结构的：
1. $X \in \Sigma$:因为对于任意$A\in\mathcal{P}(X)$而言$A\cap X=A,A\setminus X=\varnothing$，因此按照上面的定义$X$一定是$\mu-$可测的集合。
2. $\Sigma$对于集合的补的操作是封闭的：因为假设$E$是$\mu-$可测的，如果我们现在考虑$X\setminus E$,那么对于任意$A\in\mathcal{P}(X)$而言$$A\cap X\setminus E=A\setminus E,A\setminus (X\setminus E)=A\cap E$$而因为$E$是$\mu-$可测的，那么自然$X\setminus E$也是$\mu-$可测的。
3. $\Sigma$对于集合的可数个并操作是封闭的：

> [!note] 命题1.1
> 假设有可数个$\{E_i\}_{i\geq 1}$都是$\mu^{*}-$可测的，那么这些集合的并集也是$\mu^{*}-$可测的。

这里有一个技巧：

> [!tip] 证明集合可测的技巧
> 因为外测度的次可加性，那么$\mu^{*}(A)\leq \mu^{*}(A\cap E)+\mu^{*}(A\setminus E)$是一定会成立的，那么实际上我们要证明$\mu^{*}-$可测性，我们只需要证明另一头的不等式$$\mu^{*}(A)\geq \mu^{*}(A\cap E)+\mu^{*}(A\setminus E),\forall A\in \mathcal{P}(X) $$


> [!tip] 主要思路
> 此处的主要思路是：
> 1. 首先我们证明两个可测集合的并是可测的。
> 2. 其次我们可以用归纳法结合第一条性质，证明对任意的$\cup_{i\leq n}E_i$是可测的。
> 3. 最后我们利用上述技巧，集合分析的手段证明整个命题。

首先对于任意的两个可测集合$E',E''$，$$\begin{aligned}\mu^{*}(A)&= \mu^{*}(A\cap E')+\mu^{*}(A\setminus E')\\&= \mu^{*}(A\cap E'\cap E'')+\mu^{*}(A\cap E'\setminus E'')+\mu^{*}(A\setminus E'\cap E'')+\mu^{*}(A\setminus E'\setminus E'')\\&=\mu^{*}(A\cap E'\cap E'')+\mu^{*}(A\cap E'\cap E''^{c})+\mu^{*}(A\cap  (E'^{c}\cup E''^c))+\mu^{*}(A\cap E'^c\cap E''^c) \\&\geq \mu^{*}(A\cap (E'\cup E''))+\mu^{*}(A\setminus(E'\cup E''))\end{aligned}$$
参考上文中"证明集合可测的技巧"，因为上述不等式的成立，那么我们证明了任意两个可测集合的并是可测的。
* 上面这段证明的关键在于，首先认识到，任何两个集合$A,B$我们都可以把其中一个表示为$A=(A\cap B)\cup (A\setminus B)$。第二行我们利用了两次$E''$的可测性的定义。最后的不等式其关键在于$A\cap E'\cap E'',A\cap E'\cap E''^{c},A\cap  (E'^{c}\cup E''^c)$三个部分的并恰好就是$A\cap (E'\cup E'')$,那么由次可加性，就能得到最后的不等式。

接下来利用归纳法，很容易得到$F_n:=\cup_{i\leq n}E_i$对于任意的正整数$n$,都是可测集。现在我们的目标是证明$F:=\cup_{i\geq 1}E_i$是可测的，按照上文中的思路，我们的最终目标是得到不等式：$$\mu^{*}(A)\geq \mu^{*}(A\cap F)+\mu^{*}(A\setminus F),\forall A\in \mathcal{P}(X) $$而我们的出发点是因为$F_n$可测，于是对任意正整$n$数都满足$$\mu^{*}(A)=\mu^{*}(A\cap F_n)+\mu^{*}(A\setminus F_n)$$对于这个式子首先观察到$A\setminus F\subseteq A\setminus F_n$,于是$$\mu^{*}(A)\geq \mu^{*}(A\cap F_n)+\mu^{*}(A\setminus F)$$由于$E_n$是可测的，那么一定是满足$$\begin{aligned}\mu^{*}(A\cap F_n)&=\mu^{*}(A\cap F_n\cap E_n)+\mu^{*}(A\cap F_n\setminus E_n)\\&=\mu^{*}(A\cap E_n)+\mu^{*}(A\cap F_{n-1})\end{aligned}$$这里相当于得到了$\mu^{*}(A\cap F_n)$的一个差分的关系，那么就将其表达为差分和的形式，得到$$\begin{aligned}\mu^{*}(A)&\geq \mu^{*}(A\cap E_n)+\mu^{*}(A\setminus F)\\&= \sum_{i=1}^{n}\mu^{*}(A\cap E_i)+ \mu^{*}(A\setminus F)\end{aligned}$$两边取极限$$\begin{aligned}\mu^{*}(A)&\geq \sum_{i\geq 1}\mu^{*}(A\cap E_i)+\mu^{*}(A\setminus F)\\&\geq \mu^{*}(A\cap F)+\mu^{*}(A\setminus F)\end{aligned}$$于是根据一开始提到的证明集合可测的技巧，因为下界这一边的不等式也是成立的，因此$F$是可测的。

> [!note] 命题1.2
> 如果$\{E_i\}_{i\geq 1}$两两不相交，并且都是$\mu^{*}-$可测的集合，那么不仅它们的并是可测的，此外还成立可数可加性:$$\mu^{*}\left(\bigcup_{i\geq 1}E_i\right)=\sum_{i\geq 1}\mu^{*}(E_i)$$

此外利用以上证明集合是Caratheodory意义下可测的技巧，我们可以证明：

> [!note] 命题1.3
> 如果一个集合外测度为0，它一定是Caratheodory意义下的可测集。


整合以上的关于$\Sigma \subseteq P(X)$的性质，我们可以这样概括集合$X$上$\mu-$可测的集合：

> [!note] sigma代数的定义
> 集合$X$上的$\sigma-$代数$\mathcal{F}$是集合$X$的幂集的一个子集，并且满足下面三个性质:
> 1. 全集的包含性:$X\in \mathcal{F}$。
> 2. 补集的封闭性:如果$A\in \mathcal{F}$,那么$X\setminus A \in \mathcal{F}$。
> 3. 可数并的封闭性:如果$\{A_n\}_{n\geq 1}\subseteq \mathcal{F}$那么$\cup_{n\geq 1}A_n \in \mathcal{F}$。

通过上面的证明，显然集合$X$上所有$\mu-$可测的集合形成$X$上的一个$\sigma-$代数（集合代数）的结构。

因此这也就不难理解为何测度可以定义为：

> [!note] 测度以及测度空间
> 测度$\mu$是定义在$\sigma-$代数$\mathcal{F}$上的一个函数:$$\mu:\mathcal{F}\to [0,+\infty]$$并且满足以下两个性质:
> 1. 空集的测度为0:$\mu(\varnothing)=0$
> 2. $\sigma-$代数上的可数可加性:$\{E_i\}_{i\geq 1}\subseteq \mathcal{F}$并且两两不相交，那么$$\mu\left(\bigcup_{i\geq 1}E_i\right)=\sum_{i\geq 1}\mu(E_i)$$
> 我们把，集合$X$，此集合上的一个$\sigma-$代数，以及对应的测度$\mu$三个合在一起$(X,\mathcal{F},\mu)$称之为一个测度空间。

以上讨论可以总结为:

> [!note] Caratheodory extension theorem
> 如果$\mu^{*}:\mathcal{P}(X)\to [0,\infty]$是集合$X$上的外测度，$\mathcal{F}$是一个包含$\mathcal{P}(X)$当中所有在Cratheodory意义下$\mu^{*}-$可测的集族。令$\mu:\mathcal{F}\to [0,+\infty]$是外测度在$\mathcal{F}$上的限制，即$\mu(E)=\mu^{*}(E)$,只要$E\in \mathcal{F}$。那么$\mathcal{F}$是一个$\sigma-$代数，而$\mu$是在此代数上的测度，$(X,\mathcal{F},\mu)$是一个测度空间。

#### 1.2 测度的基本性质

> [!note] 性质1：单调性
> $E_1,E_2 \in \mathcal{F}$并且$E_1\subseteq E_2$那么$$\mu(E_1)\leq \mu(E_2)$$

着我们可以从测度的可数可加性出发，因为我们可以把大一点的集合表示为$$E_2=E_1\cup (E_2\setminus E_1)$$于是我们现在可以保证右边的两个集合互不相交，于是$$\mu(E_2)=\mu(E_1)+\mu(E_2\setminus E_1)$$那么大于等于的关系就很容易看出来了。

> [!note] 性质2：次可数可加性
> $E_1,\cdots,E_n,\cdots \in \mathcal{F}$,那么$$\mu\left(\bigcup_{n\geq 1}E_n\right)\leq \sum_{n\geq 1}\mu(E_n)$$

这里注意，不同于测度的定义当中的"可数可加性"的性质中对元素两两互不相交的要求，这里对集合列$E_n$没有做任何要求，只要是可测即可，因此结论就被减弱了。

> [!note] 性质3：自下而上的连续性
> $E_1,\cdots,E_n,\cdots \in \mathcal{F}$并且是这是一列单调上升的集合列，即$E_1\subseteq E_2 \subseteq \cdots \subseteq E_n \cdots$,那么这列集合的并集是可测的，并且其测度满足$$\mu\left(\bigcup_{n\geq 1}E_n\right)=\lim_{n\to \infty}\mu(E_n)=\sup_{n\geq 1}\mu(E_n)$$

^16fa84

> [!note] 性质4：自上而下的连续性
> $E_1,\cdots,E_n,\cdots \in \mathcal{F}$并且是这是一列单调下降的集合列，即$\cdots \subseteq E_n \subseteq \cdots  \cdots \subseteq E_2\subseteq E_1$,那么这一列集合的交集是可测的。并且如果这一列集合列当中至少有一个集合是有限测度的，那么这列集合的交集的测度满足关系$$\mu\left(\bigcap_{n\geq 1}E_n\right)=\lim_{n\to \infty}\mu(E_n)=\inf_{n\geq 1}\mu(E_n)$$

^850d06

* 换言之，在一般的测度空间当中使用这个性质，计算一列单调下降的序列交集的测度的时候，需要注意这一列集合当中是否存在一个有限测度的集合，否则可能会出现反例。但是如果我们的测度空间本身就是一个“有限测度空间”，例如一个概率测度空间，那么这一个限制条件自然就不需要了。

> [!note] 反例1.2
> 当我们考虑Lebesgue测度空间$(\mathbb{R},\mathcal{F},m)$的时候，考虑一列单调下降的集合序列$E_n:=[n,+\infty)$,这一列集合的交集实际上是一个空集。因为$E:=\cap_{n\geq 1}E_n$，那么任意实数$x$如果$x \in E$,它会大于任意正整数，这是不可能的。因此$E$实际上是空集，然而$\mu(E_n)=+\infty,\forall n\geq 1$，所以这是不可能的。


### 2. Borel测度

#### 2.1 Borel测度的构造

我们定义集合$X$上的测度的时候，我们一般会考虑这个集合上的一个$\sigma-$代数$\mathcal{F}$和一个满足特殊性质的非负实数值函数$\mu$（具体见上一节），来建立一个测度空间$(X,\mathcal{F},\mu)$。而如果这个集合本身并非是一个普通的集合，比如我们区别对待$X$的一些子集，例如我们称其中一些子集为开集，并且所谓开集的集合$\tau$满足一些特殊的结构，称之为拓扑结构，那么现在$(X,\tau)$。

那么我们要如何在一个拥有拓扑结构的集合$X$上建立测度空间,并且使得其拓扑结构和测度空间的结构是兼容的？这个问题实际上比较普遍，比如说我们通常要处理测度问题的集合都不是孤立存在的一个任意的集合，这个集合通常又可以组成，比如一个赋范空间，或者度量空间等，这天然就是拓扑空间。而这样的空间上处理测度问题也好，基于测度的积分也好，都避不开要和拓扑空间上的一些概念打交道。比如说现在有两个拓扑空间$(X,\tau_X),(Y,\tau_Y)$,然后考虑$f:X\to Y$这样一个连续函数，那么如果我们要考虑此连续函数的（基于某种测度的）积分，我们当然想要这个函数$f$是一个可测函数。

> [!note] 可测函数的概念
> 如果我们分别在两个集合$X,Y$上建立两个可测空间（即可以定义测度的空间）$(X,\sigma_X),(Y,\sigma_Y)$那么，如果现在考虑$g:X\to Y$这样一个函数，那么如果函数满足对任意的$A\in \sigma_Y$其原像$g^{-1}(A)\in \sigma_X$，那么称$f$是$X$到$Y$的$(\sigma_X,\sigma_Y)-$可测函数，简称为可测函数。
* 比如说当我们说$f:\mathbb{R}\to \mathbb{R}$是Lebesgue可测函数的时候，实际上说的是函数$f$是从可测空间$(\mathbb{R},\mathcal{L}(\mathbb{R}))$到可测空间$(\mathbb{R},\mathcal{B}(\mathbb{R}))$的可测函数，即一个$(\mathcal{L}(\mathbb{R}),\mathcal{B}(\mathbb{R}))-$可测函数。其中$\mathcal{L}$是实数上的Lebesgue$\sigma-$代数，而$\mathcal{B}$是实数上的Borel $\sigma-$代数。

书接上文，我们想要两个拓扑空间$(X,\tau_X),(Y,\tau_Y)$之间的连续函数$f$是可测的，这是对于分析学的问题而言，这是一个很合理的要求。

而所谓连续函数：
$$\text{对任意}A\in \tau_Y\text{都满足}f^{-1}(A)\text{是开集}$$
而所谓可测函数：
$$\text{对任意}A\in \sigma_Y\text{都满足}f^{-1}(A)\in \sigma_X$$

如果我们想要这件事兼容起来，一个比较简单的处理就是，为什么不干脆$\tau_X \subseteq \sigma_X,\tau_Y \subseteq \sigma_Y$。当然我们不会直接想着，干脆二者直接相等，因为别忘了$\sigma-$代数需要满足自己的一套结构（见1.1节末尾），不过也别太大了，因为我们希望这个概念是简洁的，于是不如定义:
$$\text{包含拓扑空间全部开集}\tau\text{的最小}\sigma-\text{代数}$$

> [!note] borel代数与borel集
> $(X,\tau)$是一个拓扑空间，记$\sigma(\tau)$为包含$\tau$的最小$\sigma-$代数，称之为Borel $\sigma-$代数，其中任意元素称之为Borel集。

* 这样的Borel代数是包含整个$\tau$，并且包含全部的闭集的，因为由于$\sigma-$代数的要求：补集也包含在此集合代数当中。不过通常来说，Borel代数还要比这个范围更大，它包含$G_{\sigma}$以及$F_\sigma$集族。其中$$G_{\sigma}:=\{\cap_{i\geq 1}A_i:A_i\text{ is open}\},F_{\sigma}:=\{\cup_{i\geq 1}A_i:A_i\text{ is closed}\}$$也就是说开集的可数交和闭集合的可数并都是Borel集，这就超出了一般来说拓扑空间中开集与闭集的概念了。因为拓扑的结构保证的是，开集的有限交是开的，但是没有保证开集的可数交是开的。同样的道理，拓扑结构保证了闭集的有限交是闭的，但是没有保证可数交是闭的（源自于开集有限交为开的规则）。此外很容易看出，如果$E\in G_{\delta}$那么其补集合$X\setminus E \in F_\delta$,反之亦然。

下面展示一些具体的例子：

考虑实数$\mathbb{R}$的欧氏拓扑,以及此拓扑上生成的Borel $\sigma-$代数$\mathcal{B}(\mathbb{R})$，那么以下集合是Borel集，但并非开集或者闭集：
1. 半开半闭的区间$(a,b]$:因为这样的区间还可以表示为$$[a,b)=\bigcup_{n\geq 1}[a,b-\frac{1}{n})$$
2. 有理数集合以及无理数集:$\mathbb{Q}$可以理解为所有有理数的单点集$\{q\}$的可数并。而单点集在实数欧氏拓扑下是闭集，因此$\mathbb{Q}\in F_{\sigma}$，因此这是一个Borel集。不过这个集合既非开集，也非闭集。因为有理数集内部并不包含任何开区间，其补集是无理数集，也并非开集。而既然$\mathbb{Q}\in F_{\sigma}$那么无理数$\mathbb{R}\setminus \mathbb{Q}\in G_\delta$，也是一个Borel集。

> [!note] Borel可测空间
> $(X,\tau)$是一个拓扑空间$(X,\mathcal{F})$称之为Borel可测空间，如果$$\mathcal{B}(X)\subseteq \mathcal{F}$$其中$\mathcal{B}(X)$是Borel $\sigma-$代数。当然如果此空间上再装备一个测度，那么$(X,\mathcal{F},\mu)$就称之为Borel测度空间。

#### 2.2 测度的完备化

> [!note] 完备测度空间的概念
> 一个测度空间$(X,\mathcal{F},\mu)$称为完备的，如果满足：对任意$A\in \mathcal{F}$以及所有$B\subseteq A$如果$\mu(A)=0$那么一定有$B\in \mathcal{F}$。换言之，任何零测集的子集都是可测的。

* 通常来说Borel测度空间不是完备的。

下面我们说明完备测度的概念的一个动机，同时给出一个具体的Borel测度空间但并非完备测度空间的例子。不过我们需要先搞懂，product measure的概念。

假设我们现在有两个测度空间$(X_1,\Sigma_1,\mu_1),(X_2,\Sigma_2,\mu_2)$，然后我们想要在笛卡尔集$X_1\times X_2$上建立基于这两个集合原本所在测度空间的新的测度空间，我们要怎么办？

首先我们需要建立$X_1\times X_2$上的$\sigma-$代数，其建立方式如下：$$\Sigma_1\otimes\Sigma_2:=\{A_1\times A_2:A_1\in \Sigma_1,A_2\in \Sigma_2\}$$不难证明这是一个$\sigma-$代数。于是基于上述两个测度空间的乘积测度空间可以定义为:

> [!note] 乘积测度
> $(X_1,\Sigma_1,\mu_1),(X_2,\Sigma_2,\mu_2)$是两个测度空间，那么基于这两个空间的一个乘积测度(product measure)$\mu_1\times \mu_2$是可测空间$(X_1\times X_2,\Sigma_1\otimes\Sigma_2)$上满足$$\mu_1\times \mu_2(A_1\times A_2)=\mu_1(A_1)\mu_2(A_2),\forall A_1\in \Sigma_1,A_2\in \Sigma_2$$条件的测度。

那么接下来我们可以构造一个具体的，不完备的测度空间：

> [!example] 例子2.2
> $(\mathbb{R},\mathcal{L},m)$是Lebesgue测度空间，其中$\mathcal{L}$是实数的Lebesgue代数。现在考虑再次基础上建立的乘积测度空间$$(\mathbb{R}^2,\mathcal{L}\otimes \mathcal{L},m^2)$$那么集合$[0,1]\times\{0\}$一定是$m^2$零测度的集合，因为$$m^2([0,1]\times\{0\})=m([0,1])m(\{0\})=0$$不过我们知道，单位闭区间$[0,1]$当中是存在不可测集合的，比如一个Vitali集$V\subset [0,1]$,可以构造子集$V\times \{0\}\subset [0,1]\times\{0\}$，但是这并不是一个$\mathcal{L}\otimes \mathcal{L}$中的元素。


#### 2.3 度量空间中判断外测度是否为Borel测度的方法

判断一个度量空间$(X,d)$上定义的外测度$\mu$为Borel测度的依据：

> [!note] 命题2.2 ：关于度量空间当中Borel测度的Caratheodory判别
> $\mu$是度量空间$(X,d)$上定义的外测度，如果$\mu$满足，对任意的距离大于0的两个集合$A,B$($\text{dist}(A,B)>0$)都有$$\mu(A\cup B)=\mu(A)+\mu(B)$$那么这是一个Borel测度。

* 度量空间当中两个集合的距离被定义为$$\text{dist}(A,B):=\inf\{d(x,y):x\in A,y\in B\}$$
* 此处我们称外测度$\mu$是一个Borel测度，指的是在测度空间$$(X,\mathcal{F}_C,\mu)$$当中，$\mathcal{F}_C$是$X$上的Borel代数的的完备化，而$\mu$是这样的测度空间当中的测度。比如说实数$\mathbb{R}$的Lebesgue测度空间$(\mathbb{R},\mathcal{L},m)$，我们就可以说Lebesgue外测度$m$是Borel测度，其中$\mathcal{L}$作为Lebesgue可测集的$\sigma-$代数是比Borel代数$\mathcal{B}(\mathbb{R})$更大的代数。==（此处可以给一个例子）==

### 3. Haar测度

#### 3.1 Hausdroff空间上的合适的测度空间

虽然Borel测度空间的确能在一定程度上兼容拓扑空间$(X,\tau)$，但还不够好，它会存在下面这些问题：

==(需要讨论的Borel测度的问题，放这里)==

因此我们需要测度具有一定的正则性(正规性)，分别是:内正则，外正则，以及局部有限性，于是:

> [!note] Radon测度空间
> Hausdroff空间$(X,\tau)$上建立的Borel测度空间$(X,\mathcal{F},\mu)$加上以下正则性的要求以后可称其为Radon测度空间：
> 1. 外正则性：$$\mu(A)=\inf\{\mu(U):U \text{ is open and } A \subseteq U\}$$
> 2. 内正则性:$$\mu(A)=\sup\{\mu(K):K \text{ is compact and  } K \subseteq A\}$$
> 3. 局部有限性：对于每一个$X$的紧子集$K$,这个测度是有限的,即$\mu(K)< \infty$。

#### 3.2 如何在拓扑群上定义合适的测度空间?

如果说Radon测度是为具有Hausdroff性的拓扑空间而生，那么对于更丰富一些的结构呢？比如说$\mathbb{R}^d$,它本身除了是一个欧氏空间以外，同时上面还有群结构$(\mathbb{R}^d,+)$,那么这样的结构(一个局部紧的拓扑群)上的好的测度应该具有什么性质?
$$\text{测度需要在群作用下保持不变}$$
==（why？补充一些具体的例子）==


**平移不变性**：这一点是针对于拓扑群$(X,\cdot)$而言的，对于任意的群元素$g \in X$，以及$A \in \mathcal{B}(X)$如果满足左平移不变性:$$\mu(gA) = \mu(A)$$以及右平移不变性$$\mu(Ag) = \mu(A)$$
当我们不讨论局部紧的拓扑群，单纯讨论LCH空间的时候，如果满足前两条性质，即测度满足局部有限性和正则性，那么这是一个**Radon测度**. 如果在LCH空间上还建立了群结构，那么测度关于群运作用是不变的，那么这称之为**Haar测度**。
