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
  - 高考
  - 中学数学竞赛
  - 大学数学竞赛
  - 微积分
---

> [!question] 问题1,1996 CMO Q5/2024某省高考模拟题 p17
> 已知$x_0=0$以及$x_1,\cdots,x_n>0$且满足$x_0+x_1+\cdots+x_n=1$证明:
> $$1\leq \sum_{i=1}^n \frac{x_i}{\sqrt{1+x_0+\cdots +x_{i-1}}\sqrt{x_i+\cdots+x_n}}<\frac{\pi}{2}$$

> [!note] 左边的不等式的证明
> 左边的不等式是相对简单的。思路是[[逐项估计]]，我们可以把分母上看成是$\sqrt{ab}$，那么“算术平均值与几何平均值”的不等式(参考[[Power mean及其性质]])告诉我们$$\sqrt{ab}\leq \frac{a+b}{2}$$之所以我们考虑$a+b$的和是因为$$a+b=1+x_0+\cdots+x_{i-1}+x_i+\cdots+x_n=1+1=2$$这样满足了逐项放缩的条件，因为缩小以后的每一项是好求和的，因为$$\frac{x_i}{\sqrt{ab}}\geq x_i$$因此左边的不等式是成立的。

对于右边的不等式，乍一看是没有通用的方法去解决的。不过通过观察，令$y_i:=\sum_{k\leq i}x_k$，我们可以把被求和对象改写为$$\frac{y_i-y_{i-1}}{\sqrt{1+y_{i-1}}\sqrt{1-y_{i-1}}}$$其中$0=y_0<\cdots<y_n=1$。此时我们可以把和重新写成$$\sum_{i=1}^n (y_i-y_{i-1})\frac{1}{\sqrt{1-y_{i-1}^2}}$$这让我们想到[[和的积分估计#1. 和的简单积分估计]]。因为$f(x)=\frac{1}{\sqrt{1-x^2}}$具有单调性，那么我们立刻可以得到$$\sum_{i=1}^n (y_i-y_{i-1})\frac{1}{\sqrt{1-y_{i-1}^2}}<\int_{0}^{1}\frac{1}{\sqrt{1-x^2}}\,dx=\frac{\pi}{2}$$