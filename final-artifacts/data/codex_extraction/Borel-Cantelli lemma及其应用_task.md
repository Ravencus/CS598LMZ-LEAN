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
### 0. 引理的基本理解

#### 0.1 引理的叙述和证明


> [!note]  Borel-Cantelli lemma
> $(X,\mathcal{F},\mu)$是一个测度空间，$E_1,E_2,E_3,...\in \mathcal{F}$并且满足测度的和收敛，$$\sum_{n\geq 1}\mu(E_n)<\infty$$
> 那么$$\mu\left(\bigcup_{n\geq N}E_n\right)\to0$$或者说几乎所有$x\in X$都包含在至多有限个$E_n$当中，即$$\mu(\limsup_{n\to\infty}E_n)=0$$

这里最后结果的等价是因为我们可以假设$A_{N}:=\cup_{n\geq N}E_n$于是
$$ \limsup_{n\to\infty}E_n\subseteq ...\subseteq A_2 \subseteq A_1$$
其中$\limsup_{n\to\infty}E_n$定义为$A_N$这列单调下降的集合列的交集。根据[[测度论的基础概念#1.2 测度的基本性质]]测度的“单调性”以及“次可数可加性”告诉我们$$\mu(A_N)\le \mu(A_1)\leq \sum_{n\geq 1}\mu(E_n)<\infty$$因此由测度的“自上而下的连续性”（参考[[测度论的基础概念#1.2 测度的基本性质]]的性质4）的公式是成立的，因为$A_N$这一列单调下降的集合列中至少有一个元素是有限测度的。于是我们知道
$$\mu(\limsup_{n\to\infty}E_n)=\lim_{N\to \infty}\mu(A_N)$$而我们又知道$$\mu(A_N)\leq \sum_{n\geq N}\mu(E_N)$$由于正项级数的收敛性，我们知道后者的极限为0，因此我们得到$$\mu(\limsup_{n\to\infty}E_n)=\lim_{N\to \infty}\mu(A_N)=0$$
最后的结果有时候也可以表述为:$$\mu\left(\{x:x\in E_n \text{ i.o.}\}\right)=0$$其中$\text{ i.o.}$表示"infinitely often"，表示发生的次数是无穷的，这是$\limsup_{n\to\infty}E_n$这个集合的另外一种解释。那么假设我们令$\text{ f.o.}$表示**至多**"finitely often"（包含不属于的情况，因为并没有说$\{E_n\}$覆盖整个$X$）,那么我们可以把集合$X$划分为两个部分：$$X=\{x:x\in E_n \text{ i.o.}\}\cup\{x:x\in E_n \text{ f.o.}\}$$
右边第一个集合是零测度的，第二个集合包含了$X$当中在测度$\mu$的意义下，几乎所有的点。这意味着$X$当中几乎所有点，都**至多**只能出现在有限个$E_n$当中。

---

Borel-Cantelli定理的另一种证明方式可以借助[[把集合问题转换为函数问题]]的思路来解决。我们无法就是要证明$\mu(\{x:x\in E_n \text{ i.o.}\})$是零测度的，即几乎所有$x$都属于有限个$E_n$当中。把这个目标翻译为函数的语言：令$$F(x):=\sum_{n\geq 1}1_{E_n}(x)$$只要$F(x)$几乎处处有限则目标就达到了，而这等价于级数几乎处处绝对收敛。参考[[证明函数项级数几乎处处绝对收敛]]当中的思路，我们可以借助于单调收敛定理（Beppo-Levi）证明加强的命题：$F(x)$可积。依据单调收敛定理，以及该命题本身的条件可以得到：$$\int_{X} F(x)\,d\mu(x)=\sum_{n\geq 1}\int_{X} 1_{E_n}(x)\,d\mu(x)=\sum_{n\geq 1}\mu(E_n)<\infty$$于是$F(x)$可积，自然$F(x)$几乎处处有限，从而命题得到了证明。

---

举个具体例子

> [!example]  例子0.1
> $([0,1],\mathcal{B}([0,1]),m)$是一个测度空间，$m$是Lebesgue测度。假设集合$I_n = [0,\frac{1}{n^2}]$,那么因为$$\sum_{n\geq 1} m(I_n)=\sum_{n\geq 1} \frac{1}{n^2}<\infty$$因此$m(x\in I_n \text{ i.o. })=0$。也就是说，$[0,1]$上几乎所有点都只属于有限多个形如$I_n = [0,\frac{1}{n^2}]$的区间，这很显然。其实这里唯一一个属于无穷多个此类区间的点就只有$x=0$这一个点罢了。

#### 0.2 引理的逆命题不一定成立

Borel-Cantelli引理告诉我们：$$\sum_{n\geq 1}\mu(E_n)<\infty\implies \mu(\limsup_{n\to \infty} E_n)=0$$那么反过来成立吗？其实是不一定的,比如下面的反例:

> [!example]  反例0.2
> $([0,1],\mathcal{L}([0,1]),m)$是集合$[0,1]$上的Lebesgue测度空间，其中$m$是Lebesgue测度。考虑此空间上的一列集合列$E_n:=(0,\frac{1}{n})$。定义$A_N:=\cup_{n\geq N}E_n$，我们知道$A_N=(0,\frac{1}{N})$，依据测度的“自上而下的连续性”，我们知道$$m(\limsup_{n\to \infty}E_n)=\lim_{N\to \infty}m(A_N)=0$$然而如果我们会发现$m(E_n)=\frac{1}{n}$其组成的级数是不收敛的。

但是部分的逆命题可以在概率空间当中，在添加独立性的条件的基础上成立，详细参考本篇文章的第二节。

### 1. 此lemma在序列的几乎处处收敛上的应用

> [!note]  常用引理1
> 如果$\forall \varepsilon > 0$,定义集合$A_{n,\varepsilon}:=\{x:|f_n(x)-f(x)|\geq\varepsilon\}$都有
> $$\sum_{n\geq1}\mu(A_{n,\varepsilon})<\infty$$那么可以得到结论
> $$\mu\left(\limsup_{n\to\infty}A_{n,\varepsilon}\right)=0,\forall \varepsilon>0$$于是
> $$f_n(x) \to f(x) \text{ a.e. }x$$

* 下面证明$\mu\left(\limsup_{n\to\infty}A_{n,\varepsilon}\right)=0,\forall \varepsilon>0$可以导出$$f_n(x) \to f(x) \text{ a.e. }x$$
对于固定的$\varepsilon>0$有$$X=\{x:x\in A_{n,\varepsilon} \text{ i.o.}\}\cup\{x:x\in A_{n,\varepsilon} \text{ f.o.}\}$$现在假设$x_0 \in \{x:x\in A_{n,\varepsilon} \text{ f.o.}\}$，这就意味着存在一个$N_{x_0,\varepsilon}$使得对任意$n>N_{x_0,\varepsilon}$有$|f_n(x_0)-f(x_0)|<\varepsilon$于是$$\limsup_{n\to \infty}|f_n(x_0)-f(x_0)|\leq \varepsilon$$现在令$A_{k}:=\{x:x\in A_{n,\frac{1}{k}} \text{ f.o.}\}$，$x_0\in A_k$意味着一定有$$\limsup_{n\to \infty}|f_n(x_0)-f(x_0)|\leq \frac{1}{k}$$于是只要$x_0 \in \cap_{k\geq 1}A_k$，那么就一定有$$\limsup_{n\to \infty}|f_n(x_0)-f(x_0)|=0$$因此$f_n(x_0)\to f(x_0)$。

那么换言之，如果集合$E$用于表示那些函数列不收敛的点的集合，那么一定有$$E\subseteq \cup_{k\geq 1}A_k^c$$而实际上$A_k^{c}=\{x:x\in A_{n,\frac{1}{k}} \text{ i.o.}\}$,常用引理1告诉我们，$\mu(A_k^c)=0$,那么$\cup_{k\geq 1}A_k^c$也是零测度的。于是$$\mu(E)\leq \mu(\cup_{k\geq 1}A_k^c)=0$$
因此$f_n(x)\xrightarrow{a.e.} f(x)$。



> [!note]  常用引理2
> $$A_{n}:=\{x:|f_n(x)-f(x)|\geq \varepsilon_n\}$$其中$\varepsilon_n \downarrow 0$，并且同时$$\sum_{n\geq 1}\mu(A_n)<\infty$$
> 于是按照上面同样的做法，如果$x \not \in \limsup_{n\to\infty} A_{n}$那么存在一个$N_x$使得$\forall n >N_x$都有$$|f_n(x)-f(x)|< \varepsilon_n$$同样能表示$f_n(x)\to f(x)$，那么能得到结论，$$f_n(x)\to f(x)$$几乎处处成立。

这两个命题以及类似的证明逻辑**可以用来证明一系列关于函数列几乎处处逐点收敛的命题**：

1. [[函数列几乎处处有界与Borel-Cantelli lemma的应用]]：这个例子当中把函数列几乎处处有界的条件转换为了集合与测度的形式，然后精心构造了一个可以适用于Borel-Cantelli引理的结构，从而证明了命题。
2. [[函数列Lp范数的怎样的衰减速度能保证函数列几乎处处收敛到0]]此例子中我们已知$||f_n||_{L^p(\mathbb{R})}^p\leq a_n$的衰减速度，这个衰减速度足够快，以至于我们可以保证对任意$\varepsilon>0$都有$$\mu(A_{n,\varepsilon})\leq \frac{||f_n||_{L^p}^p}{\varepsilon^p}\leq \frac{a_n}{\varepsilon}$$从而保证$\sum_{n\geq 1}\mu(A_{n,\varepsilon})<\infty$于是便有几乎处处收敛的结果。

### 2.在概率论当中的应用
#### 2.1 第二Borel-Cantelli引理

在概率论当中集合$A_n$的上极限会被表示为$$\limsup_{n\to\infty}E_n=\{\omega:\omega \in E_n\text{ i.o.}\}$$在考虑这个上确界集合的测度的时候还会进一步简写为$$\mathbb{P}(\limsup_{n\to\infty}E_n)=P(E_n \text{ i.o.})$$在概率论的主题当中引入了sigma代数当中两个元素独立的概念，即$A,B \in \mathcal{F}$我们说二者独立，当且仅当$P(A\cap B)=P(A)P(B)$。引入这个概念以后有第二Borel-Cantelli lemma：

> [!note]  The second Borel-Cantelli lemma
> 集合列$E_1,..,E_n,..\in\mathcal{F}$互相之间是独立的，并且其测度形成的集合不收敛$$\sum_{n\geq 1}\mathbb{P}(E_n)=\infty$$
> 那么$$\mathbb{P}(\limsup_{n\to\infty}E_n)=\mathbb{P}(E_n \text{ i.o.})=1$$

这里因为要证明$\mathbb{P}(E_n \text{ i.o.}) =1$而我们知道$\mathbb{P}(\cup_{n\geq N}E_n)\downarrow \mathbb{P}(E_n \text{ i.o.})$,那么我们实际上就是要证明对于任意的正整数$N$,$P(\cup_{n\geq N}E_n)=1$。反过来也就是要证明$P(\cap_{n\geq N}E_n^{c})=0$。

转换为一个有限问题，最后再做极限处理。
$$\begin{aligned}\mathbb{P}\left(\bigcap_{n=M}^{N} E_n^c\right) &= \prod_{n=M}^{N} (1 - \mathbb{P}(E_n)) \leq \prod_{n=M}^{N} \exp(-\mathbb{P}(E_n)) \\&= \exp\left(- \sum_{n=M}^{N} \mathbb{P}(E_n)\right) \to 0 \text{ as } N \to \infty \end{aligned}
$$
这其中用到了独立性的条件，以及使用了$1-x\leq e^{-x}$的放缩。

还有一种类似的说法：

> [!note]  The second Borel-Cantelli lemma,版本2
> 合列$E_1,..,E_n,..\in\mathcal{F}$互相之间是独立的，并且$\mathbb{P}(E_n)<1$那么$$\mathbb{P}(\cup_{n\geq 1}E_n)=1\implies \mathbb{P}(E_n \text{ i.o.})=1$$

证明和上面是一样的，$\mathbb{P}(\cup_{n\geq 1}E_n)=1$等于说$\mathbb{P}(\cap_{n\geq 1}E_n^c)=0$，然后结合独立性就能说明$\sum_{n\geq 1}\mathbb{P}(E_n)=\infty$从而得到结果。

#### 2.2 把独立性的条件减弱

如果完全没有独立性的条件，那么$\sum_{n\geq 1}\mathbb{P}(E_n)=\infty$未必能推出$\limsup_{n\to \infty} E_n$为满测度的集合。但是我们可以把独立性的条件减弱一些，使得我们可以用一个更弱的条件判断$\limsup_{n\to \infty} E_n$是不是满测度。

> [!note]  定量版本的第二Borel-Cantelli引理
> 集合列$E_1,..,E_n,..\in\mathcal{F}$满足存在一个正实数$C$使得$$\sum_{i,j\leq N}\mathbb{P}(E_i \cap E_j)\leq C \left(\sum_{i\leq N}\mathbb{P}(E_i)\right)^2$$对无穷多个正整数$N$成立，并且其测度形成的集合不收敛$$\sum_{n\geq 1}\mathbb{P}(E_n)=\infty$$
> 那么$$\mathbb{P}(\limsup_{n\to\infty}E_n)\geq \frac{1}{C}$$

* 很容易观察到，如果这一列可测集合是相互独立的，那么相当于$C=1$，对任意的正整数$N$都有$$\sum_{i,j\leq N}\mathbb{P}(E_i \cap E_j)\leq C \left(\sum_{i\leq N}\mathbb{P}(E_i)\right)^2$$从而使得$\mathbb{P}(\limsup_{n\to\infty}E_n)\geq 1$,于是$\limsup_{n\to\infty}E_n$这是一个满测度的集合。
##### 2.2.1 把无穷的问题转换为有限的问题

我们的目标是得到$\limsup_{n\to\infty}E_n$这个集合的测度的下界估计，根据[[an epsilon of room]]当中版本2的想法，我们转换为对任意的正整数$T,Q$而言$E_{T}^{Q}:=\cup_{n\geq T}^{Q} E_n$也必须满足这样的下界，或者至少$$\mathbb{P}(E_{T}^{Q})\geq \frac{1}{C}f(T,Q)$$然后函数$f$满足$$\liminf_{Q\to \infty}\liminf_{T\to \infty}f(T,Q)\geq 1$$这样我们就可以根据$$\mathbb{P}(\limsup_{n\to\infty}E_n)=\lim_{Q\to \infty}\lim_{T\to \infty}\mathbb{P}(E_{T}^{Q})\geq \frac{1}{C}$$因为$E_{T}^{Q}\uparrow E_T$,当$Q\to \infty$的时候，以及$E_{T}\downarrow \limsup_{n\to\infty}E_n$当$T\to \infty$的时候。

现在经过转换后的问题是有限问题，很多事情都更好进行具体地处理。

##### 2.2.2 利用集合的特征函数
* 参考[[把集合问题转换为函数问题]]。

> [!note]  大致的思路
> 通过集合的特征函数把集合的问题转换为函数的问题，使用处理函数的工具来分析问题。

考虑函数$G_{T,Q}(x):=\sum_{n=T}^{Q} 1_{E_n}(x)$,此函数具有性质:
1. 函数的积分恰好就是集合测度之和:$$\mathbb{E}(G_{T,Q})=\sum_{n=T}^{Q} \mathbb{E}(1_{E_n})=\sum_{n=T}^{Q} \mathbb{P}(E_n)$$
2. 函数$L^2$范数的平方，是集合两两相交的测度的和:$$\begin{aligned}\mathbb{E}(G_{T,Q}^2)&=\mathbb{E}\left(\sum_{T\leq n,m\leq Q} 1_{E_n}(x)1_{E_m}(x)\right)\\&= \sum_{T\leq n,m\leq Q} \mathbb{E}(1_{E_n}1_{E_m})\\&=\sum_{T\leq n,m\leq Q} \mathbb{P}(E_n\cap E_m)\end{aligned}$$
3. 提供$P(A_{T}^{Q})$的一个下界。由柯西不等式，我们能得到以上两个结果互相之间的一个关系:$$\mathbb{E}(G_{T,Q})^2=\mathbb{E}(G_{T,Q}\cdot 1_{E_{T}^{Q}})^2\leq \mathbb{E}(G_{T,Q}^2)P(E_{T}^{Q})$$于是$$\begin{aligned}P(E_{T}^{Q})&\geq \frac{\mathbb{E}(G_{T,Q})^2}{\mathbb{E}(G_{T,Q}^2)} \\&=\frac{\left(\sum_{n=T}^{Q} \mathbb{P}(\mathbb{P}_n)\right)^2}{\sum_{T\leq n,m\leq Q} \mathbb{P}(E_n\cap E_m)}\\&\geq  \frac{\left(\sum_{n=T}^{Q} \mathbb{P}(E_n)\right)^2}{\sum_{ n,m\leq Q} \mathbb{P}(E_n\cap E_m)}\end{aligned}$$
由以上结果，再加上对$E_n$交际测度之和上界的不等式，我们得到$$\begin{aligned}\mathbb{P}(E_{T}^{Q})&\geq \frac{\left(\sum_{n=T}^{Q} \mathbb{P}(E_n)\right)^2}{\sum_{ n,m\leq Q} \mathbb{P}(E_n\cap E_m)}\\&\geq \frac{1}{C}  \frac{\left(\sum_{n=T}^{Q} \mathbb{P}(E_n)\right)^2}{\left(\sum_{n\leq Q} \mathbb{P}(E_n)\right)^2}\\&=\frac{1}{C}  \frac{\left(\sum_{n\leq Q} \mathbb{P}(E_n)-\sum_{n< T} \mathbb{P}(E_n)\right)^2}{\left(\sum_{n\leq Q} \mathbb{P}(E_n)\right)^2}\end{aligned}$$因为$\sum_{n\geq N}\mathbb{P}(E_n)$是发散的，因此$\lim_{Q\to \infty}\mathbb{P}(E_{T}^{Q})\geq \frac{1}{C}$,因此根据最开始的分析
$$P(\limsup_{n\to\infty}E_n)=\lim_{Q\to \infty}\lim_{T\to \infty}\mathbb{P}(E_{T}^{Q})\geq \frac{1}{C}$$

#### 2.2 具体应用

因为概率论相对于一般的测度加入了有限测度,sigma代数当中元素的独立性等等条件，从而可以导出一些更好的结果：
1. 在[[有限测度空间上依测度收敛的等价命题]]：这个问题当中，我们首先证明了依照测度收敛的充要条件，其中必要条件是用Borel-Cantelli引理证明的。而这个结论的一个应用告诉我们，在有限测度的意义下，依照测度收敛可以被连续函数保持。
2. [[随机变量期望收敛导出几乎处处收敛的一个条件]]：方差形成的级数是收敛的，这一点可以结合Chebyshev不等式用来证明$X_n-E(X_n)$几乎处处收敛到0，即$$P(|X_n-E(X_n)|\geq \varepsilon)\leq \frac{E(|X_n-E(X_n)|^2)}{\varepsilon^2}=\frac{V(X_n)}{\varepsilon^2}$$于是$$\sum_{n\geq 1}P(|X_n-E(X_n)|\geq \varepsilon)\leq \frac{1}{\varepsilon^2}\sum_{n\geq 1}V(X_n)<\infty$$
3. 在[[Borel-Cantelli lemma证明某种版本下的强大数定律]]：当中，我们通过一个额外的关于随机变量$L^4$模存在的条件下，我们先给出随机变量和的平均值$\frac{S_n}{n}$的弱估计的更好的上界。根据这个更好的上界，我们可以得到$$\sum_{n\geq 1} P\left(\left\{\omega:\left|\frac{S'_n(\omega)}{n}\right| >\varepsilon\right\}\right)<\infty$$由此引出Borel-Cantelli lemma，从而根据拓展版本的引理，得到几乎处处收敛的结果，得到所谓的强大数定律。此外第二lemma还在此笔记中证明了强大数定律要成立，期望的有限性是必要条件。特别的类似于这个例子的应用，我们总结在[[加强收敛性质的条件与手段]]当中，即我们可以结合依测度收敛的“集中不等式”与"Borel-Cantelli引理"，从而证明几乎处处收敛。
4. [[Etemadi关于强大数定律的证明]]：当中“引理1”的证明当中，我们为了证明截断后的随机变量的和$T_n$在几乎处处收敛的意义下，某种程度等价，即$\frac{T_n}{n}-\frac{S_n}{n}\xrightarrow{a.e.}{0}$,我们利用了截断序列$Y_i$与原本的随机变量$X_i$的一个关系$$P(Y_i\neq X_i \text{ i.o.})=0$$而这是由Borel-Cantelli引理证明的。
5. [[单位区间内10进制小数中含有无数个7的小数的Lebesgue测度为1]]：在这个问题当中我们把关于Lebesgue测度的问题转换为概率问题，因为我们知道10进制表示当中每一位数都是独立同分布的$U(\{0,1,...,9\})$的随机变量。然后我们观察到，问题当中说的十进制小数中包含无穷多个7，我们很快想到了这等于是求$P(\omega \in A_k \text{ i.o.})$。这样我们只需要考虑每一位为7的事件的概率，以及这些事件是否独立，而这些条件显然可以被满足，因此考虑使用第二Borel-Cantelli lemma.
6. [[Khintchine定理#1. 级数收敛的情形]]：我们需要证明在级数收敛，即$\sum_{q\geq 1}\psi(q)<\infty$的情况下，$\psi$可测的集合，$A_{\psi}:=\{x\in \mathbb{R}:||qx||<\psi(q)\}$是零测度的。问题等价于在单位区间上考虑，即证明$A_{\psi}\cap [0,1]$是零测度的，紧接着发现，我们可以把该集合看成是$$A_{\psi}\cap [0,1]=\limsup_{q\to \infty} E_q$$于是问题转换为后者是零测度的，这很显然可以利用Borel-Cantelli引理来证明，最后问题转换为估计$m(E_q)$。
7. [[Khintchine定理]]的第二部分，

