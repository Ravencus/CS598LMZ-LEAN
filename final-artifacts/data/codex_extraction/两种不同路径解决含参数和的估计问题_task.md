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
  - 微积分
  - 考研
  - 大学数学竞赛
---

> [!question] 问题1
> 求极限$$\lim_{n\to \infty}\sqrt{n}\left(1-\sum_{i\leq n}\frac{1}{n+\sqrt{i}}\right)$$

### 1. 从和的积分估计出发

我们需要估计的主要目标是$$S_n:=\sum_{i\leq n}\frac{1}{n+\sqrt{i}}$$只要我们得到$S_n$的精度为$o\left(\frac{1}{\sqrt{n}}\right)$的估计，那么“问题1”就能得到解决。$S_n$的被求和对象是函数$f_n(x):=\frac{1}{n+\sqrt{x}}$，这是一个随着$x$增加而单调减少的函数。那么为何不试试看[[和的积分估计]]当中的简单积分估计？（[[和的积分估计#1. 和的简单积分估计]]）

不过启用这个方法之前，我们需要做一些基本的判断：
1. $f_n(x)$的积分是简单？$$\int_{1}^n f_n(x)\,dx=2\sqrt{n}-2n\log(n+\sqrt{n})-2+2n\log(n+1)$$这个积分结果是较为简单的，后续可以用Taylor展开进行下一步的估计。
2. 简单积分估计的精度是否足够？如果考虑简单积分估计，我们得到的余项为$O(\frac{1}{n+\sqrt{n}})+O(\frac{1}{n+1})$。这个精度是符合$o\left(\frac{1}{\sqrt{n}}\right)$的要求的。
那么这个问题利用“和的简单积分估计”是完全可行的，于是$$\begin{aligned}S_n&=\int_{1}^n f_n(x)\,dx+o\left(\frac{1}{\sqrt{n}}\right)\\&=2\sqrt{n}-2n\log(n+\sqrt{n})-2+2n\log(n+1)+o\left(\frac{1}{\sqrt{n}}\right)\\&=1-\frac{2}{3}\frac{1}{\sqrt{n}}+o\left(\frac{1}{\sqrt{n}}\right)\end{aligned}$$
于是我们很容易知道，$$\lim_{n\to \infty}\sqrt{n}(1-S_n)=\frac{2}{3}$$
### 2. 基于Taylor展开的逐项估计

同样是想要得到$S_n$的精度为$o\left(\frac{1}{\sqrt{n}}\right)$的估计，为何不试试直接对$f_n(x)$进行Taylor展开呢？$$\begin{aligned}f_n(x):=\frac{1}{n}\left(1-\frac{x}{n}+o\left(\frac{x}{n}\right)\right)\end{aligned}$$于是
$$f_n(i)=\frac{1}{n}-\frac{\sqrt{i}}{n^2}+o\left(\frac{\sqrt{i}}{n^2}\right)$$那么$$S_n=1-\frac{1}{n^2}\sum_{i\leq n}\sqrt{i}+o\left(\frac{1}{n^2}\sum_{i\leq n^2}\sqrt{i}\right)$$这个估计的精度是符合要求的，因为[[自然数的r次幂的部分和估计#2. $0<r<1$情形下的渐近展开]]的"问题2"告诉我们$$\sum_{i\leq n}\sqrt{i}=\frac{2}{3}n^{3/2}+O(\sqrt{n})$$于是$$S_n=1-\frac{2}{3}\frac{1}{\sqrt{n}}+o\left(\frac{1}{\sqrt{n}}\right)$$所以“问题1”当中的极限也为$\frac{2}{3}$。


