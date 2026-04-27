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
  - 组合学
  - 调和分析
  - 中学数学竞赛
---

> [!note] APMO 2013,P4
> $A,B$是整数集的两个不相交的有限子集，$a,b$是两个正整数，此外$$A\cup B \subset (A-a)\cup (B+b)$$其中$A-a:=\{x-a:x \in A\},B+b:=\{x+b:x \in B\}$证明$$a|A|=b|B|$$


### 1. 傅里叶分析的做法

> [!tip] 大致的想法
> 把集合满足的性质转换为特征函数满足的性质，然后通过处理函数的手段研究特征函数，最后把分析的结果对应到集合的性质上去。

首先注意到，$|(A-a)\cup (B+b)|\geq |A|+|B|$,其次因为$$\begin{aligned}|(A-a)\cup (B+b)| &= |A-a|+|B+b|-|(A-a)\cap (B+b)|\\ &\leq |A-a|+|B+b|\\&=|A|+|B|\end{aligned}$$这就意味着，$|(A-a)\cup (B+b)|=|A|+|B|$也就是说$(A-a)\cap (B+b)=\varnothing$。那么也就是说，$$A\cup B=(A-a)\cup (B+b)$$并且左右两边都是无交并。现在我们的主要目的是把这个集合的关系翻译为特征函数的关系。

#### 1.1 初次尝试

最简单的不过，考虑$1_A(x),1_B(x)$，然后函数方程变成$$\begin{aligned}1_A(x)+1_B(x)&=1_{A-a}(x)+1_{B-b}(x)\\&= 1_A(x+a)+1_B(x-b)\end{aligned}$$
* 注意，我们必须保证集合$A\cap B= \varnothing,A-a \cap B+b = \varnothing$才能给出上述的函数方程。

这样的函数方程显示出一定的平移不变性，所以我们可以考虑做一些傅里叶的分析手段。但是问题的关键在于，我们究竟要如何“间接地测量”$A,B$这两个有限集合的尺寸？

例如在[[Borel-Cantelli lemma及其应用#2.2.2 利用集合的特征函数]]当中，我们为了估计一系列集合交集的测度和的下界，于是考虑特征函数和$\sum_{T\leq n\leq Q} 1_{A_n}(x)$的积分，特征函数乘积的和$\sum_{T\leq n,m\leq Q} 1_{A_n}(x)1_{A_m}(x)$的积分。

但这里的问题是，如果我们考虑$\mathbb{R}$上的傅里叶变换，那么对应的测度就是Lebesgue测度，可对于有限集合而言其Lebesgue测度根本就是0。所以我们要选用合适的版本的傅里叶变换。这里的问题是离散的，测算离散集合的尺寸的不错的方式应该是"计数测度"，而计数测度恰好就是$(\mathbb{Z},+)$这个加法以及离散拓扑构成的LCA群上的Haar测度。

> [!note] 定义整数加法群上的傅里叶变换
> 根据[[Riemann - Lebesgue lemma的证明]]当中3的讨论，注意到$\mathbb{Z}$的庞特里亚金对偶群是$\widehat{\mathbb{Z}}:=\{e^{2\pi i n \xi}:\xi \in [0,1)]\}$,于是这种意义下的$f \in L^1(\mathbb{Z})$的函数其傅里叶变换定义为$$\widehat{f}(\xi ):=\sum_{n\in \mathbb{Z}}f(n)e^{-2\pi i n \xi}$$其傅里叶逆变换(如果成立的话)为$$f(n)=\int_{0}^{1}\widehat{f}(\xi)e^{2\pi i n \xi}\,d\xi$$

于是在这样的意义下，因为$1_A,1_B \in L^1(\mathbb{Z})$，也是也就是$\sum_{n\in A}1_A=|A|<\infty$成立，因此函数方程$$\begin{aligned}1_A(x)+1_B(x)= 1_A(x+a)+1_B(x-b)\end{aligned}$$两边都可以进行傅里叶变换，于是得到$$\widehat{1_A}(\xi)+\widehat{1_B}(\xi)=e^{2\pi i \xi a}\widehat{1_A}(\xi)+e^{-2\pi i \xi b}\widehat{1_B}(\xi)$$而我们的目标是得到关于$\widehat{1_A}(0)=|A|,\widehat{1_B}(0)=|B|$之间的关系。

直接对上面的函数方程取$\xi =0$行不行?这样就没有意义了，因为直接导致恒等，不会得到任何额外的信息。不过因为$1_A(x),1_B(x)$衰减速度是如此地快，这样导致其傅里叶变换后的函数一定是可微的，因此可以考虑两边微分得到一个新的函数方程,然后令$\xi=0$消去无关项目以后得到$$a\widehat{1_A}(0)=b\widehat{1_B}(0)$$从而导致$a|A|=b|B|$。

