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
  - 实分析
---
> [!note] Silverman-Toepliz定理,1913
> $a_{n,k}$是一个非负的双重序列，并且满足:
> 1. 关于$k$的和为1，即:$$\sum_{k=1}^na_{n,k}=1$$
> 2. 当$k$固定的时候，$$\lim_{n\to \infty}a_{n,k}=0$$
> 
> 那么对于任意的有极限的序列$x_n$，都有$$\lim_{n\to \infty}\sum_{k=1}^{n}a_{n,k}x_k=\lim_{n\to \infty}x_n$$

* 这里我们完全可以把$\sum_{k=1}^{n}a_{n,k}x_k$理解为对$x_k$的前n项和的加权平均值，因为权重系数$a_{n,k}$关于k的和为1。典型的比如[[关于一个组合数有关的加权平均的极限问题]]当中$$\frac{\binom{n}{0}x_0+\cdots+\binom{n}{n}x_n}{2^n}$$这个和有一个典型的特点:$\sum_{k=1}^n\frac{\binom{n}{k}}{2^n}=1$，并且对于任意固定的$k$，由于$\binom{n}{k}\leq \frac{n^k}{k!2^n}$因此就可以得到$\frac{\binom{n}{k}}{2^n}\to 0$。
* 另外一个典型的用处是求这样的极限$$\frac{a_1+2a_2+\cdots +na_n}{n^2}$$其中$a_k\to a$。我们可以把结果改造成$\sum_{k=1}^n \frac{k}{n^2}a_k$的样子，但是我们发现$\frac{k}{n^2}$的和并非是$1$,或者一个常数，而是$\frac{n+1}{2n}$。不过既然是接近于常数的结果，我们没有道理不能在误差允许的范围内稍微调整一下结果（思路来自[[利用已知的渐近结果求渐近展开的技巧]]）。比如说假设$S_n=\sum_{k=1}^n \frac{k}{n^2}a_k$,然后$$\begin{aligned}S_n&=\frac{a_1+2a_2+\cdots +(n-1)a_{n-1}}{n^2}+\frac{a_n}{n}\\&\to \frac{a}{2}+0=\frac{a}{2}\end{aligned}$$
### 1. 证明结果

证明的路径是根据分段估计([[分段估计]])，确切的说就是简单的分段估计。理由很简单，因为$x_k$因为是存在极限的，那么在靠近极限的那部分自然是很小的，也就是说整个部分和是呈现一种二分的特点，所以为了精度的我们选择使用分段估计。

假设$x_k$的极限是存在且有限的，由于第一个条件$\sum_{k=1}^na_{n,k}=1$所以不失一般性，我们可以假设$x_n$的极限为$0$。因为如果$x_n$的极限为$a$，那么$\sum_{k=1}^{n}a_{n,k}x_k-a$的估计，我们可以转换为$\sum_{k=1}^{n}a_{n,k}(x_k-a)$这样一个部分和的估计，其中$x_k-a\to 0$。

于是令$S_n=\sum_{k=1}^{n}a_{n,k}x_k$,那么现在的目的就是要证明$$S_n\to 0$$或者说估计部分和$S_n$。

一个简单的加强命题的做法，使用三角不等式，得到$|S_n|\leq \sum_{k=1}^n|a_{n,k}x_k|$,如果$|S_n|$的极限为0，那么$S_n$的极限也为0。

接下来我们开始使用分段估计。此处分段的界限由任意的正实数$\varepsilon$控制，对于这样的固定的$\varepsilon>0$，存在$N_{\varepsilon}$使得任意$k>N_{\varepsilon}$(当然这里也假设$n>N_{\varepsilon}$)都有$|x_k|<\varepsilon$。于是:$$\begin{aligned}|S_n|&\leq \sum_{k=1}^n|a_{n,k}x_k|\\ &=\sum_{1\leq k\leq N_{\varepsilon}}|a_{n,k}x_k|+\sum_{N_{\varepsilon}<k\leq n}|a_{n,k}x_k|\\&< M\sum_{1\leq k\leq N_{\varepsilon}}|a_{n,k}|+\varepsilon  \end{aligned}$$
* 对于极限为$0$的序列$|x_k|$而言，它一定是有界的，此处$M$为其上界。
因为对于任意固定的$k$,条件告诉我们$a_{n,k}\xrightarrow{n\to \infty}0$,于是我们可以两边对$n$取上极限，于是得到:$$\limsup_{n\to \infty}|S_n|\leq \varepsilon$$因为这个结果对任意$\varepsilon>0$成立，因此$|S_n|$的极限存在且为0，这意味着$S_n\to 0$。

### 2. 推广

通过上面的证明，我们发现实际上S-T定理的条件还可以进一步放松：

> [!note] 命题2.1:Silverman-Toepliz定理的推广
> $a_{n,k}$是一个双重序列，并且满足:
> 1. 关于$k$的和**渐进**为1，即:$$\lim_{n\to \infty}\sum_{k=1}^na_{n,k}=1$$
> 2. 当$k$固定的时候，$$\lim_{n\to \infty}a_{n,k}=0$$
> 3. $$\sup_{n\in \mathbb{N}^{+}}\sum_{k\leq n}|a_{n,k}|<+\infty$$
> 
> 那么对于任意的有极限的序列$x_n$，都有$$\lim_{n\to \infty}\sum_{k=1}^{n}a_{n,k}x_k=\lim_{n\to \infty}x_n$$

由于$\lim_{n\to \infty}\sum_{k=1}^na_{n,k}=1$这个条件，不失一般性，我们可以假设$x_n$的极限为0，然后我们只需要证明$$S_n=\sum_{k=1}^{n}a_{n,k}x_k\to 0$$
* 这里之所以这样做，是因为假设$x_k$的极限为$a$，那么$$\sum_{k=1}^{n}a_{n,k}x_k-a=\sum_{k=1}^{n}a_{n,k}(x_k-a)+o_n(1)$$那么倘若我们可以证明$\sum_{k=1}^{n}a_{n,k}(x_k-a)=o(1)$那么命题自然成立。而前一个和当中$x_k- a\to 0$，于是我们只需要像之前版本的S-T定理的证明那样估计$S_n$即可。

首先考虑使用分段估计，对于这样的固定的$\varepsilon>0$，存在$N_{\varepsilon}$使得任意$k>N_{\varepsilon}$(当然这里也假设$n>N_{\varepsilon}$)都有$|x_k|<\varepsilon$。于是:$$\begin{aligned}|S_n|&\leq \sum_{k=1}^n|a_{n,k}x_k|\\ &=\sum_{1\leq k\leq N_{\varepsilon}}|a_{n,k}x_k|+\sum_{N_{\varepsilon}<k\leq n}|a_{n,k}x_k|\\&< M\sum_{1\leq k\leq N_{\varepsilon}}|a_{n,k}|+T\varepsilon  \end{aligned}$$
* 这里其中一个关键的放缩在于存在一个正实数$T$使得$$\sum_{N_{\varepsilon}<k\leq n}|a_{n,k}|\leq \sup_{n\in \mathbb{N}^{+}}\sum_{k\leq n}|a_{n,k}|<T<+\infty$$
所以同样的两边对$n$取上极限，我们得到$$\limsup_{n\to \infty}|S_n|\leq T\varepsilon,\forall \varepsilon>0$$因此$S_n$的极限存在且为$0$，因此命题成立。

---

在推广的S-T定理下，下面的例子也是可以直接得到答案的。


> [!example] 例子2.2
> $|\lambda|<1$序列$x_n$的极限为$a$，那么$$\sum_{k=0}^{n}\lambda^{n-k}x_k\to \frac{a}{1-\lambda}$$这是因为$\sum_{k=0}^{n}\lambda^{n-k}=\frac{1-\lambda^{n+1}}{1-\lambda}$，所以Silverman-Toepliz定理的推广版本告诉我们$$\sum_{k=0}^{n}\lambda^{n-k}(1-\lambda)x_k\to a$$从而得到结果。

^d99a95

---

下面的例子可以让我们看到“命题2.1”当中第三个条件的必要性。

> [!example] 例子2.3:去掉条件3之后的反例 
> 令$$a_{n,k}:=\begin{cases}1&(n,k)=(1,1)\\n&(n,k)=(n,n)\\1-n&(n,k)=(n,n-1)\\0&\text{otherwise}\end{cases}$$这个序列可以看成一个无穷的矩阵$A$当中的元素：$$A:=\begin{pmatrix}1&0&0&\cdots\\-1&2&0&\cdots\\ 0&-2&3&\cdots \\\vdots&\vdots&\vdots&\ddots \\0&\cdots&1-n&n\\\vdots&\vdots&\vdots&\ddots \end{pmatrix}$$这样的双重序列并不满足“命题2.1”的第三个条件，因为此时$$\sum_{k\leq n}|a_{n,k}|=2\sum_{k=1}^{n} k=n(n+1)$$令$x_k:=\frac{(-1)^k}{k}$那么$$\sum_{k\leq n} a_{n,k}x_k = a_{n,n-1}x_{n-1}+a_{n,n}x_{n}=2(-1)^n$$这个和的极限不存在，更不会等于$x_k$的极限0。

* 像这样的反例必然需要$a_{n,k}$在矩阵当中的每一列的值在正数与负数之间交替，否则$a_{n,k}\geq 0$的话“命题2.1”的第一个条件自然蕴含第三个条件，从而自动满足全部条件。



