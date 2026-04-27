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
---

> [!question] 问题0 
> 求极限$$\lim_{n\to \infty} \sum_{k=1}^n \frac{1}{n^2}\sqrt{(n+k)(n+k+1)}$$

令$$S_n:=\sum_{k=1}^n \frac{1}{n^2}\sqrt{(n+k)(n+k+1)}$$首先我们明确一点，求$S_n$的极限，也就是对$S_n$做最低精度为$o(1)$的和的估计。

* 这样思考的好处是什么?详细参考[[从几个极限问题去理解Landau符号#3. Landau符号的优点]]。

明确这一点以后，我们便切换我们的视野到"和的估计"这个主题当中。

### 1. 观点a:相似渐近

这种观点的立足点在于[[黎曼积分与黎曼和的误差]]。我们稍微做一些尝试便发现：
$$S_n=\sum_{k=1}^n \frac{1}{n^2}\sqrt{(n+k)(n+k+1)} = \frac{1}{n}\sum_{k=1}^n \sqrt{(1+\frac{k}{n})(1+\frac{k+1}{n})}$$我们希望看到的是可以把$S_n$写成函数$\sqrt{(1+x)^2}=1+x$在区间$[0,1]$上的黎曼和，如此一来由于对应的黎曼积分非常简单，而根据[[黎曼积分与黎曼和的误差]]之间的误差满足关于估计$S_n$的最低误差要求$o(1)$绰绰有余，因此问题便可以解决。

但是，此处并非是$S_n':=\frac{1}{n}\sum_{k=1}^n \sqrt{(1+\frac{k}{n})(1+\frac{k}{n})}$而是多了那么一点，这便让我们想到了[[利用已知的渐近结果求渐近展开的技巧]]。我们不是要得到一个形如$$S_n=A+o(1)$$的估计吗？（即$\lim_{n\to \infty}S_n=A$）其中根据黎曼和与黎曼积分的关系$$S_n'=\int_0^1 (1+x)\,dx +o(1)=\frac{3}{2}+o(1)$$倘若我们可以证明$|S_n-S_n'|=o(1)$那么岂不是是说$$S_n=S_n'+o(1)=\frac{3}{2}+o(1)$$那么目标就算是达成。而我们之所以如此猜测，是因为二者从形式上来说的确是非常相似，仅有细微的差别。

为了验证这种猜测，我们不妨尝试[[逐项估计]]。这里的动机是，既然二者的被求和对象如此相似，那么我们只需要验证被求和对象之差的绝对误差，在经过$\sum_{k=1}^n$的求和之后，累积误差不会超过$o(1)$，即误差累积之下，依旧是一个无穷小量（$n\to \infty$的极限为0）。由于$$ \sqrt{(1+\frac{k}{n})(1+\frac{k+1}{n})}-\sqrt{(1+\frac{k}{n})(1+\frac{k}{n})}<\frac{k+1}{n}-\frac{k}{n}=\frac{1}{n}$$于是$$|S_n-S_n'|<\frac{1}{n}\sum_{k=1}^n \frac{1}{n}=\frac{1}{n}$$于是便验证了我们的猜测。

因此最终我们得到答案$$S_n=S_n'+o(1)=\frac{3}{2}+o(1)$$即$$\lim_{n\to \infty}S_n=\frac{3}{2}$$

### 2. 观点2：逐项放缩

试问，如果问题改成求极限$$\lim_{n\to \infty} \sum_{k=1}^n \frac{k}{n^2}$$我们还需要犹豫吗？直接给出简洁的和的表达式$$\sum_{k=1}^n \frac{k}{n^2}=\frac{n(n+1)}{2n^2}$$然后直接利用极限的基本运算规律，以及我们对有理多项式序列极限的理解便可以计算出结果。

那么“问题0”当中阻挡我们求和的困难是什么？是根号！直接去根号的方法，有3条经验可以参考：
1. 其实第一种观点便可以看作是一种去更好的思路。
2. 另外一种更直接不需要任何巧思的办法就是把被求和对象看成是$$f(k):=\sqrt{(n+k)(n+k+1)}$$然后倘若我们可以很方便地估计出$\int_1^n f(x)\,dx$， 那么我们有大量的[[和的积分估计]]的思路可以解决问题。可惜，$f$的原函数并不简单。倒不是说，求不出来，但是为了做$S_n$的精度仅仅为$o(1)$的目标，这值得吗？我认为不值。
3. 直接放缩$f(k)$通过$$g(k)\leq f(k)\leq h(k)$$其中$g,h$都不带根号，并且和的估计明显比$f$更容易。并且同时$$E_k=|h(k)-g(k)|$$误差累积下，$$\sum_{k=1}^n \frac{E_k}{n^2}=o(1)$$其本质就是[[逐项估计]]。

在“问题0”这个问题当中，第三条去除根号的路径显然是可为的。一种利用单调性进行逐项放缩$$n+k<\sqrt{(n+k)(n+k+1)}<n+k+1$$但是这个时候我们不要着急去求两边和，然后配合$\frac{1}{n^2}$去算极限，然后心中惴惴不安，祈求最后的极限是上界和极限与下界和极限相等。

> [!quote]
> 先确认自己走在正确的道路上，然后再奔跑才明智。因为在错误的道路上狂奔，只会让自己越来越难以回头。

* 一个失败的教训：[[从一个光滑函数部分和的渐近问题开始#2.1 一个失败的逐项放缩]]。像这个问题当中，如果直接跟着感觉来进行放缩$$\frac{1}{\sqrt{n^2+n}} \leq \frac{1}{\sqrt{n^2+k}} \leq \frac{1}{\sqrt{n^2+1}}$$但是罔顾我们最终估计的精度要求，最后结果就是算了一大堆，结果发现，误差要求达不到，一切都是徒劳。

我们当前的上下界的误差上限为$1$，那么上下界的和累积误差为$$\sum_{k=1}^n\frac{1}{n^2}=\frac{1}{n}=o(1)$$这表明我们做对了。这个时候，我们根本无需把上下界和的极限都计算一次，我们只需要选择一边计算即可，比如上界$$\sum_{k=1}^n \frac{n+k+1}{n^2}=1+\frac{n(n+1)}{2n^2}+\frac{1}{n}\to \frac{3}{2}$$从而我们得到结论$$S_n = \frac{3}{2}+o(1)\to\frac{3}{2}$$


