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
  - 中学数学竞赛
---
### 1. 基本性质

对于power mean最一般的定义形式为：

> [!note] 定义
> 对于非负实数$x_1,...,x_n$，以及正实数$w_1,...,w_n$,以及非零实数p:
> $${ M_{p}(x_{1},\dots ,x_{n};w_1 \cdots w_n)=\left({\frac {\sum _{i=1}^{n}w_{i}x_{i}^{p}}{\sum _{i=1}^{n}w_{i}}}\right)^{{1}/{p}}}$$
> 特别的，如果权重都为1，$w_1 = w_2 =...=w_n = 1$那么$$ M_{p}(x_{1},\dots ,x_{n})=\left({\frac {\sum _{i=1}^{n}x_{i}^{p}}{n}}\right)^{{1}/{p}}$$

> [!note] 性质1:大小关系
> 在相同的权重系数下，如果$p<q$那么:
> $$M_{p}(x_{1},\dots ,x_{n};w_1 \cdots w_n) \leq  M_{q}(x_{1},\dots ,x_{n};w_1 \cdots w_n)$$

> [!note] 性质2：极限性质
> 1. $$\lim_{p \rightarrow +\infty} M_{p}(x_1,...,x_n;w_1 \cdots w_n) = \max\{x_1,...,x_n\}$$
> 
> 2. $$\lim_{p \rightarrow -\infty} M_{p}(x_1,...,x_n;w_1 \cdots w_n) = \min\{x_1,...,x_n\}$$
> 3. $$\begin{aligned}\lim _{p\to 0}M_{p}(x_{1},\dots ,x_{n};w_1 \cdots w_n)&=\prod _{i=1}^{n}x_{i}^{\frac{w_{i}}{\sum _{j=1}^{n}w_{j}}}\\&=M_{0}(x_{1},\dots ,x_{n};w_1 \cdots w_n)\end{aligned}$$也就是说我们把最后那个乘积的结果定义为$M_0$.
* 证明参考[[逐项估计#^a88fe1]]中的“想法1.2.2”。

特别的对于简化版的Power Mean而言，性质2的推论有：$$M_{+\infty} \geq M_{3} \geq M_{2} \geq M_1 \geq M_0 \geq M_{-1} \geq M_{-\infty}$$
即n个非负实数的各个版本的平均值由大到小依次是:最大值，立方平均值，平方平均值，算术平均值，几何平均值，调和平均值，最小值。

### 2.例子

#### 2.1 调和平均值与算术平均值

考虑这两个平均值的放缩关系的想法是:

> [!tip] 考虑HM-AM的基本想法
> 在处理不等式关系的时候：
> 1. 组成不等式的部分都是正实数。
> 2. 不等式左边是求和的形式，并且是求最小值
> 3. 这些数的倒数的和会出现有趣的结构

> [!example] 例子1
> 假设$x>1$那么:
> 
> $$\frac{1}{x- 1} + \frac{1}{x} +\frac{1}{x+1} > \frac{3}{x}$$

这个例子恰好符合上面说的三个条件，于是我们便有了使用AM>HM的动机。倒过来以后求和:
$$(x-1) + x + (x+1) = 3x$$
这个形式和想要的结果非常接近，于是尝试和使用HM-AM的不等式
$$\frac{1}{x- 1} + \frac{1}{x} +\frac{1}{x+1} > \frac{9}{3x} = \frac{3}{x}$$

> [!example] 例子2
> 假设$x,y,z$都是正实数,证明:
> $$\frac{x}{y+z} + \frac{y}{x+z} +\frac{z}{x+y} \geq \frac{3}{2}$$


注意到这样的结构:

$$\frac{x}{y+z} + 1 = \frac{x+y+z}{y+z}$$

如果这样倒过来，加在一起，因为分母都是(x+y+z)所以有趣的地方在于和等于:2

所以决定可以使用

$$f(x,y,z)=\frac{x}{y+z} + \frac{y}{x+z} +\frac{z}{x+y}$$


$$f(x,y,z) +3 = \frac{x+y+z}{y+z} +\frac{x+y+z}{x+y} +\frac{x+y+z}{x+z}  \geq \frac{9}{2}$$

于是:

$$f(x,y,z) \geq  \frac{3}{2}$$
#### 2.2 算术平均值与几何平均值

> [!tip] 基本想法
> 1. 非负实数($a^2+b^2 \geq 2ab$这种例外)
> 2. 我们需要做不等式加法和乘法之间的互相转换：即我们发现把式子当中的乘法通过不等式转换为加法，或者反过来把加法转换为乘法比较有趣。
> 
> trick:可以整体使用，但是有时候需要对其中一个部分使用AM-GM。

> [!example] 例子3
> 对于任意实数a,b,c有:
> $$(a+b+c)^2\geq 3(ab +bc+ac)$$

---
$$(a+b+c)^2 = a^2+b^2+c^2 + 2(ab+ac+bc)$$ 其中
$$a^2+b^2+c^2 = \frac{a^2+b^2}{2} + \frac{a^2 + c^2}{2} + \frac{b^2+c^2}{2} \geq ab + ac +bc$$
因此得证.

更多的例子:
* [[Re0微积分1：用牛顿迭代法求算术平方根]]当中我们为了证明$x_n,n\geq 2$的时候满足迭代关系$$x_{n+1}:=\frac{1}{2}\left(x_n+\frac{a}{x_n}\right)\geq  \sqrt{a}$$的序列的下界，我们使用了AM-GM的不等式。因为其中结构$x_n+\frac{a}{x_n}$让我们意识到，用不等式可以把它转换为相乘的其结构，这个结构会更为简单。
