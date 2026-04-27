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
---

> [!question] 问题1
> $H_n:=\sum_{k\leq n}\frac{1}{k}$为第n个调和数，给出其一个下界估计。
### 1. 用Dyadic分解来进行这个下界估计

使用Dyadic分解来对部分和$H_n$做估计本质上和[[柯西凝聚判别法]]是一样的，其基本的想法都是:

> [!tip] 对非负不增序列部分和做Dyadic分解的基本想法
> 对于部分和$\sum_{n\geq N}a_n$其中被求和对象，序列$a_n$不增，非负，那么我们可以对自然数的子集$\{1,...,N\}$做Dyadic分解，把这个集合分解为$M_N = \lfloor\log_2^{N}\rfloor$段形如$$\{2^k,...,2^{k+1}-1\}$$的集合(其中$k\in \{0,...,M_N-1\}$)，以及一段$\{2^{M_N},...,N\}$.于是$$\sum_{n\leq N}a_n=\sum_{k=0}^{M_N-1}\sum_{2^k\leq n<2^{k+1}}a_n+R_N$$于是我们可以对每一段$\sum_{2^k\leq n<2^{k+1}}a_n$做简单的估计从而估计整个部分和。

参考[[柯西凝聚判别法]]当中的推导，可以得到一个下界估计:$$\sum_{n=1}^{N}a_n\geq \frac{1}{2}\sum_{k=1}^{M_N}2^{k}a_{2^{k}}$$
带入$a_n = \frac{1}{n}$,于是$$\begin{aligned}H_N&>\frac{1}{2}\sum_{k=1}^{M_N}1\\&= \frac{M_N}{2}\\ &\geq \frac{1}{2\log(2)}\log(N)\end{aligned}$$
* 当然我们也可以直接使用[[柯西凝聚判别法]]来完成这件事。事实上柯西凝聚判别就是Dyadic分解做估计的一个体现。凝聚判别直接把调和级数部分和转换为$$\sum_{k\leq M} 2^k \frac{1}{2^k}=\sum_{k\leq M} 1$$而这个部分和表明，级数发散。

### 2. 与简单积分估计的对比

根据[[和的积分估计]]，如果我们仅仅是对$H_N$做简单的积分估计，我们可以得到$$\begin{aligned}H_N &= \int_{1}^{N}\frac{1}{t}\,dt + O(1)\\&=\log(N)+O(1)\end{aligned}$$
如果我们动用更加细致的Euler-Macluarin求和，可以得到:$$H_N=\log(N)+\gamma+\frac{1}{2N}+O\left(\frac{1}{N^2}\right)$$这意味着上面我们用Dyadic分解得到的估计实际上并不是那么好的估计。因为$\log(N)$的系数$\frac{1}{2\log(2)}\approx 0.72$，按照我们后面更加精确的分许，一个不错的下界，至少$\log(N)$的系数应该是1才对。

那么问题出在哪里呢？很简单，根据[[分段估计]]当中的说法，虽然单调减少到0的$a_n$其误差在尾部积累的并不多，但是这怎么比得过积分估计呢，哪怕是简单的积分估计。因为[[和的积分估计]]其本质上是对于每一个$a_n$用在$[n,n+1]$之间的积分来近似。从分段估计的角度上来分析，这里每一段的长度实际上是1，对于离散求和而言，还有什么分段能比每个对象单独处理的长度为1的分段来得更为合适?


