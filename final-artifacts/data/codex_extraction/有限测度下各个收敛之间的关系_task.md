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
  - 概率论
---
![[各种收敛模式之间的关系.png]]

> [!note] 定义0：收敛的模式
> 在有限测度空间$(X,\mathcal{F},\mu)$上定义的(值域为$\mathbb{R}$或者$\mathbb{C}$)可测函数列$\{f_n(x)\}_{n\in \mathbb{N}}$依照某种模式收敛到可测函数$f(x)$，其具体定义为：
> 
> * ***几乎处处收敛***:$$f_n\xrightarrow{a.e.}{f}$$其含义为，存在一个零测度集$N\in \mathcal{F},\mu(N)=0$,使得$f_n(x)\to f(x),\forall x \in N^c$。也就是说函数列在零测度集合$N$的补集上是逐点收敛的。
> * ***依测度收敛***：$$f_n\xrightarrow{\mu}{f}$$其含义为，对于任意的$\varepsilon>0$，正实数序列$$\mu(x\in X:|f_n(x)-f(x)|\geq \varepsilon)\to 0$$
> * ***依$L^p$范数收敛***：$$f_n\xrightarrow{L^p}{f}$$其含义为，实数列$$||f_n-f||_{L^p}\to 0$$其中$||\cdot||_{L^p}$是$L^p$范数，也就是说这种收敛首先要保证$L^p$可积。
> * **一致收敛**：$$f_n\xrightarrow{u}{f}$$其含义为,实数列$$||f_n-f||_u:=\sup_{x\in X}|f_n(x)-f(x)|\to 0$$
> * ***弱收敛（依分布收敛）***：函数$f_n$通过$$F_n(A):=\mu(\{x:f_n(x)\in A\})$$的方式定义出一个分布测度$F_n$相应的，函数$f$对应的分布测度为$F$,那么如果对于所有的continuity set $A$(即Borel集合,且满足$\mu(\partial A)=0$)都有$F_n(A)\to F(A)$,那么我们说$$f_n \xrightarrow{d}{f}$$即函数列$f_n$依照分布收敛到$f$。

图表中的各种收敛之间的关系里面有一些关系直接从定义就能相对容易得到：
1. “一致收敛”导出“逐点收敛”：这就是最基本的函数列极限定义。
2. “逐点收敛”导出“几乎处处收敛”：参照几乎处处收敛的定义，如果函数列在某个集合$E\subseteq X$上的每一个点都收敛到极限函数，那么不收敛的点的集合就是空集，空集的测度当然是零测度，因此自然是几乎处处收敛的。
3. 有限测度意义下，“一致收敛”导出“$L^p$收敛”：这是因为在有限测度意义下如果$1\leq p<\infty$那么$$||f_n-f||_{L^p}^p:=\int_{X}|f_n(x)-f(x)|\,d\mu(x)\leq \mu(X)\sup_{x\in X}|f_n(x)-f(x)|$$因此一致收敛可以导出$L^p$收敛。而如果$p=+\infty$，那么按照$L^{\infty}$范数的定义$$||f_n-f||_{L^\infty}:=\sup_r\{\mu\left(\{x:|f_n(x)-f(x)|\geq r\}\right)>0\}$$而一致收敛告诉我们，对任意的$\varepsilon>0$存在正整数$N_{\varepsilon}$使得任意$n>N_{\varepsilon}$都有$\sup_{x\in X}|f_n(x)-f(x)|<\varepsilon$。从而使得$|f_n(x)-f(x)|\geq \varepsilon$的$x$是一个空集。也就是说只要$n>N_{\varepsilon}$那么就不可能有$\mu\left(\{x:|f_n(x)-f(x)|\geq r\}\right)>0$，那么我们知道此时$$||f_n-f||_{L^\infty}\leq \varepsilon$$因为$\varepsilon$是任意的，因此$||f_n-f||_{L^\infty}\to 0$。
### 1. 依$L^p$范数收敛与依测度收敛的关系

> [!note] 命题1：依照Lp范数收敛推出依测度收敛
> $$f_n\xrightarrow{L^p}{f}\implies f_n\xrightarrow{\mu}{f}$$

### 1.1 利用Chebyshev定理去证明
这个命题证明的主要技术是Chebyshev不等式，并且**是不仅限于有限测度的**。

* 当然当$p = \infty$的时候，整个结论是比较明显的。因为依照范数的定义$$\begin{aligned}||f_n-f||_{L^\infty}<\varepsilon,\forall \varepsilon>0&\iff\sup_r\{\mu\left(\{x:|f_n(x)-f(x)|\geq r\}\right)>0\}<\varepsilon,\forall \varepsilon>0\\&\iff \sup_r\{\mu\left(\{x:|f_n(x)-f(x)|\geq r\}\right)>0\}=0 \\&\implies \forall r >0,\mu\left(\{x:|f_n(x)-f(x)|\geq r\}\right)=0\\&\iff f_n \xrightarrow{\mu}{f}\end{aligned}$$对n取极限之后就可以得到依测度收敛的结果。

当然也可以利用$||f_n-f||_{p}\uparrow ||f_n-f||_{\infty}$的结论，那么这样一来需要证明的无非就是p范数的时候成立结果即可。（具体可以参考[[函数p范数与无穷范数之间的关系]]）

* $1\leq p<\infty$的时候,用Chebyshev不等式(这里证明一遍此不等式):

> [!note] Chebyshev不等式
> $$\begin{aligned}\mu\left(\{x:|f_n(x)-f(x)|\geq
> \varepsilon\}\right)&=\mu\left(\{x:|f_n(x)-f(x)|^p\geq
> \varepsilon^p\}\right) \\ &= \int_{\{x:|f_n(x)-f(x)|^p\geq
> \varepsilon^p\}}1d\mu \\&\leq
> \int_{\{x:|f_n(x)-f(x)|^p\geq
> \varepsilon^p\}}\frac{|f_n(x)-f(x)|^p}{\varepsilon^p}d\mu
> \\&\leq \int \frac{|f_n(x)-f(x)|^p}{\varepsilon^p} d\mu =
> \frac{1}{\varepsilon^p}||f_n-f||^p_{L^p}\end{aligned}$$
> 


对$n$取极限就很容易得到：
$$\lim_{n\to \infty}\mu\left(\{x:|f_n(x)-f(x)|\geq
\varepsilon\}\right)=0,\forall \varepsilon
>0$$

#### 1.2 在有限测度上的另一个版本的证明

在有限测度的条件下，如果不借助Chebyshev不等式，这个结论也是可以证明的。

整个证明，的想法可以概括为：[[用子列来提升收敛或发散性质]]。

我们借助借助[[有限测度空间上依测度收敛的等价命题]]，即所谓依测度收敛等价于此函数列的任意子列都存在几乎处处收敛的子列。而我们可以证明如果$f_n \xrightarrow{L^p} f$那么,其任意的子列$f_{n_k}$也一定是$L^p$收敛到$f$。如此一来，由于[[Riesz-Fischer定理]]定理当中的证明过程，我们知道$L^p$收敛的序列当中存在快速收敛的子列，从而子列$f_{n_k}$当中存在一个几乎处处收敛的子列。这意味着，$f_n$的任意子列都存在几乎处处收敛的子列，于是$f_n \xrightarrow{\mu} f$。

### 2. 几乎处处收敛与依测度收敛之间的关系

#### 2.1 依测度收敛弱于几乎处处收敛

有限测度空间上几乎处处收敛是比依测度收敛更强的收敛，首先

> [!note] 命题2.1.1：有限测度空间中几乎处处收敛推出依测度收敛
> 如果$\mu(X)<\infty$,那么$$f_n\xrightarrow{a.e.}{f}\implies f_n\xrightarrow{\mu}{f}$$

* 这一点用[[有限测度空间上依测度收敛的等价命题]]当中的命题来说明是很容易的。因为既然$f_n$几乎处处收敛到$f$，那么其任意子列也是几乎处处收敛到$f$的。而等价条件告诉我们，在有限测度的意义下，序列的任意子列存在子列是几乎处处收敛的，那么这就意味着依测度收敛。因此我们便得到了依测度收敛。
* 我们能从[[加强收敛性质的条件与手段]]当中看到，我们在证明概率空间当中几乎处处收敛的时候，会首先验证依测度收敛，然后尝试用一些条件加强这种收敛为几乎处处收敛。这里面最常用的工具就是Borel-Cantelli引理。

反过来在有限测度空间当中，依测度收敛未必能导出几乎处处收敛，比如下面这个例子：

> [!example] 反例2.1
> 假设$X_n$是一列独立的随机变量，满足$$\mathbb{P}(X_n=1)=\frac{1}{n},\mathbb{P}(X_n=0)=1-\frac{1}{n}$$对于足够小的$\varepsilon>0$,$\mathbb{P}(|X_n|\geq \varepsilon)=\frac{1}{n}$因此我们知道$$X_n \xrightarrow{\mathbb{P}}0$$但是，如果我们发现$\sum_{n\geq 1}\mathbb{P}(X_n=1) =+\infty$,由于随机变量的独立性，第二Borel-Cantelli引理(参考[[Borel-Cantelli lemma及其应用#2.1 第二Borel-Cantelli引理]])告诉我们$$\mathbb{P}(\{\omega:X_n(\omega)=1 \text{ i.o.}\})=1$$令$E_{n,\varepsilon}:=\{\omega:|X_n(\omega)-1|\geq \varepsilon\}$那么上述结果相当于告诉我们$\mathbb{P}(\limsup_{n\to \infty}E_{n,\varepsilon})=0$因此由[[Borel-Cantelli lemma及其应用#1. 此lemma在序列的几乎处处收敛上的应用]]当中的“常用引理1”$$X_n \xrightarrow{\text{a.e.}}1$$
> 这个例子告诉我们，函数列依测度收敛到某个结果未必几乎处处收敛到相同的结果。

* 关于为何$\mathbb{P}(\limsup_{n\to \infty}E_{n,\varepsilon})=0$：因为我们可以把$\Omega$分为$$\Omega= \{\omega:X_n(\omega)=1\text{ i.o.}\}\cup\{\omega:X_n(\omega)=1\text{ f.o.}\}$$第二类集合表示那些至多包含在有限个$\{\omega:X_n(\omega)=1\}$集合当中的元素组成的集合，这里面当然也包含那些使得$X_n(\omega)\neq 1$的元素。因此$E_{n,\varepsilon}\subseteq \{\omega:X_n(\omega)=1\text{ f.o.}\}$而之前的结果$\mathbb{P}(\{\omega:X_n(\omega)=1 \text{ i.o.}\})=1$相当于告诉我们$\{\omega:X_n(\omega)=1\text{ f.o.}\}$是一个零测度的集合。于是我们知道$\mathbb{P}(E_{n,\varepsilon})=0$。而所谓$E_{n,\varepsilon}$的上极限，其实也就是$\cup_{n\geq N}E_{n,\varepsilon}$的极限（下降的集合套的交集），依照测度的“自上而下的连续性”（[[测度论的基础概念#1.2 测度的基本性质]]性质4），于是我们得到结论$\mathbb{P}(\limsup_{n\to \infty}E_{n,\varepsilon})=0$。











