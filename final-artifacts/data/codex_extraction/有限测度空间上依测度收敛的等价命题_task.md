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
> [!note]  有限测度空间上依照测度收敛的充要条件
> 在***有限测度***空间上，函数列$X_n$是一列可测函数，那么$X_n \xrightarrow{\mu}{X}$等价于任意子列$X_{n(m)}$都存在一个子列的之列$X_{n(m_k)}$几乎处处收敛到$X$

### 1. 证明
#### 1.1 充分性

从依测度到任何子列都有几乎处处收敛的子列这一步主要依靠[[Borel-Cantelli lemma及其应用]]来完成。

更常见的叙述是，$X_n \xrightarrow{\mu}{X}$能导出存在一个几乎处处收敛的子列。这里既然函数列依照概率收敛，那么其任意子列也依照概率收敛到$X$,而这些子列都存在一个几乎处处收敛的子列，因此证明便结束。

但是为何依概率收敛能导出存在一个几乎处处收敛的子列呢？因为按照定义函数列的子列$X_{n(m)}$依照概率收敛到$X$说的是，对于任意的$\varepsilon>0,\delta>0$存在$N_{\varepsilon,\delta}$使得任意$n(m)>N_{\varepsilon,\delta}$都有$$\mu(\{\omega:|X_{n(m)}(\omega)-X(\omega)|\geq \varepsilon\})<\delta$$
那么假设我们取$\delta_k=\frac{1}{2^k}$那么按照定义存在$N_{\varepsilon,\delta_k}$使得任意$n(m)>N_{\varepsilon,\delta_k}$那么取$n(m_k) \geq  N_{\varepsilon,\delta_k}+1$并且$n(m_k)>n(m_{k-1})$，从而满足$$\mu(\{\omega:|X_{n(m_k)}(\omega)-X(\omega)|\geq \varepsilon\})<\frac{1}{2^k}$$对任意$\varepsilon>0$成立。而因为$\sum_{k\geq 1}\frac{1}{2^k}<\infty$因此由[[Borel-Cantelli lemma及其应用]]当中的拓展版本的lemma，得到$$X_{n(m_k)}\xrightarrow{\text{ a.e. }}{X}$$
#### 1.2 必要性

2. 反过来，如果子列都存在处处收敛的子列的话，实际上可以构造$$y_n=\mu(|X_n-X|\geq \varepsilon),\forall \varepsilon>0$$注意这里***有限测度的条件就非常重要***了，因为如果测度是无穷的，虽然可测函数的条件可以保证集合$\{\omega:|X_n-X|\geq \varepsilon\}$是可测的，但是如果测度无穷，那么就没有办法定义$y_n$的值。

现在$X_n$的收敛性质可以通过这个构造传递给$y_n$，因为$X_{n(m_k)}$几乎处处收敛到$X$，那么等于是任意$y_n$的子列$y_{n(m)}$都存在一个子列$y_{n(m_k)}$收敛到0.这意味着$y_n\to 0$，即 $X_n \xrightarrow{\mu}{X}$.

最后关于$y_n$的那个论述来自于拓扑空间(此处$y_n \in \mathbb{R}$)当中序列的极限性质。

> [!note]  Urysohn subsequence principle
> 如果$y_n$属于拓扑空间当中的集合，并且任意子列$y_{n(m)}$都存在一个收敛到拓扑空间当中元素$y$的子列$y_{n(m_k)}\to y$，那么$y_n\to y$.

假设$y_n$并不收敛到$y$,那么存在一个包含$y$的开集$U$使得对于任意$N_m$总是存在$n>N_m$满足$y_n \not \in U$。我们可以取满足$n(m)>N_m$并且满足$n(m)>n(m-1)$的序列$y_{n(m)}$为这样一个子列，满足$y_{n(m)} \not \in U$。由于假设，任意子列都有收敛到y的子列，这显然矛盾。$y_{n(m)}$的任意子列都不属于y的这个邻域$U$,也就谈不上收敛。

#### 1.3 非有限测度空间上的反例

> [!example] 反例1
> 假设命题成立不需要测度空间是有限的，那么在实数的Lebesgue测度空间上考虑函数列$f_n(x):=(x+1/n)^2$。这个函数列处处收敛到$x^2$,因此它的子列以及子列的子列都是处处收敛到$x^2$的。但是这个序列并不依Lebesgue测度收敛到$x^2$，因为对充分小的$\varepsilon$$$\{x\in \mathbb{R}:(x+1/n)^2-x^2\geq \varepsilon\}=[\frac{n\varepsilon}{2}-\frac{n}{2},+\infty)$$对任意的$n\in \mathbb{N}$而言这个集合的测度都是无穷的。因此该序列不会依测度收敛到$x^2$,这就与命题矛盾了。

### 2. 应用1

> [!question] 问题
> 对于连续函数$f:\mathbb{R}\to \mathbb{R}$的连续映射，$X_n$是概率空间当中的一列随机变量，那么$X_n$在什么条件下的收敛可以使得$f(X_n)$保持这种收敛性？
> 

#### 2.1 逐点收敛成立

如果$X_n(\omega)\to X(\omega)$逐点收敛，那么由连续性，这是显然的。
不过逐点收敛的条件太强了，太难以满足了，接下来考虑弱一些的情况。

#### 2.2 几乎处处收敛成立

如果$X_n(\omega)\xrightarrow {\text{a.e.}}X(\omega)$即几乎处处收敛，这依旧是满足的。
这个性质在有限测度的空间当中是很容易成立的，因为几乎处处收敛意味着$P(\{\omega:X_n(\omega)\to X(\omega)\})=1$而在这些使得收敛成立的$\omega$的情况下，连续函数同样保持收敛，即$$\{\omega:X_n(\omega)\to X(\omega)\} \subseteq \{\omega:f(X_n(\omega))\to f(X(\omega))\}$$
这意味着，后者的测度至少为1，然而概率测度最多为1，因此后者的测度只能是1.这就意味着几乎处处收敛的保持。
#### 2.3 依照概率收敛成立

> [!note] 依照概率收敛在连续映射下保持不变
> 假设$f:\mathbb{R}\to \mathbb{R}$是一个连续映射，那么
> $$X_n(\omega)\xrightarrow {\text{P}}X(\omega) \implies f(X_n) \xrightarrow {P}{f(X)}$$

这个结果恰好使用依测度收敛的充要条件。首先对于任意的子列$X_{n(m)}$都存在一个几乎处处收敛的子列$X_n(m_k)\to X$，由函数的连续性，这意味着$f(X_n)$的任意子列都存在一个几乎处处收敛到$f(X)$的子列$f(X_{n(m_k)})$，由充要条件，这意味着$f(X_n)$依照测度收敛。

按照这个论断，假设$X_n \xrightarrow{P}{\infty}$，同时$f(\infty)$存在，那么以上结论依旧成立。