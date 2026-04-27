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

> [!question] 问题0
> 考虑两个实数列$a_n,r_n$满足$\sum_{n\geq 1}|a_n|<\infty$，证明级数$$\sum_{n\geq 1}\frac{a_n}{\sqrt{|x-r_n|}}$$对$x\in \mathbb{R}$是几乎处处绝对收敛的。

实际上我们要证明的无非就是由非负项级数定义出来的函数$$f(x):=\sum_{n\geq 1}\frac{|a_n|}{\sqrt{|x-r_n|}}$$几乎处处有限。

> [!tip] 想法1
> 如果可以证明一个加强命题：此函数是可积的。如果可以做到这一点，那么我们就能通过可积得到几乎处处有限的结论。而证明可积，我们可以从Fubini-Tonelli定理的角度出发，因为$f(x)$交换以后在实数上的积分是容易计算的，如果交换以后的结果是有限的，那么一定是可积的。（详细参考[[Fubini-Tonelli定理的例子与反例]]其中有关于Fubini-Tonelli定理的一个使用技巧）

* 另外一种交换次序的思路是基于Levi的单调收敛定理，类似的问题可以参考[[函数列Lp范数的怎样的衰减速度能保证函数列几乎处处收敛到0#1.2 单调收敛定理的角度]]。

不过我们很快就会发现$$\int_{\mathbb{R}}\frac{1}{\sqrt{|x-r_n|}}\,dx=\infty$$也就是说我们把命题加强得过头了。

> [!tip] 想法2：把命题减弱一点
> 我们实际上只需要证明在实数的任意一个开区间上的积分是可积的，从而函数在该区间上几乎处处有限。而可数个零测度的集合的并依旧是零测度的，于是因为实数可以表示为可数个这样的开区间的并，因此函数在整个实数上几乎处处有限。

考虑任意长度为$1$的开区间$I$上的积分，并使用Tonelli定理：$$\begin{aligned}\int_{I} |f(x)|\,dm(x)&=\sum_{n\geq 1} |a_n|\int_{I}\frac{1}{\sqrt{|x-r_n|}}\,dm(x) \\&\leq2\sqrt{2}\sum_{n\geq 1}|a_n|<\infty \end{aligned}$$
* 中间对不等式的放缩，只需要做一个换元就可以得到。分为两种情况，$r_n\in I$或者$r_n \not \in I$，两种情况下积分都不会超过$2\sqrt{2}$。

于是我们证明了函数在任意长度为$1$的开区间上都是几乎处处有限的，于是函数在整个实数上也都是几乎处处有限的，因此级数$\sum_{n\geq 1}\frac{a_n}{\sqrt{|x-r_n|}}$对$x\in \mathbb{R}$是几乎处处绝对收敛的。


