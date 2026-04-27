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
  - 微积分
---
### 1. 关于黎曼积分的一些基本概念和命题

> [!note] 黎曼和的概念
> 对于$[a,b]$上的实值函数$f$而言，点列$P$ $$a=x_0<x_1<\cdots <x_n=b$$称之为$[a,b]$的一个划分(partition)，记$|I_i|=x_i-x_{i-1}$为第$i$个子区间的长度，$\xi_i^{*}\in [x_{i-1},x_i]$是当中任意的一点,记所有固定的这样的每个区间的代表元的集合为$\xi:=\{\xi_1^{*},...,\xi_n^{*}\}$。此时我们称$(P,\xi)$是闭区间$[a,b]$上的一个带标志点的划分（tagged partition）。那么函数$f$在区间$[a,b]$上关于带标志点的划分$(P,\xi)$的黎曼和定义为:$$S_f(P,\xi):=\sum_{i=}^{n} f(\xi_i^{*})|I_i|$$

定义这种划分对应的最大的一个区间的长度，记为$\lambda(P)$,那么黎曼积分就被定义为:

> [!note] 实数的闭区间上黎曼积分的定义
> 对任意的$\varepsilon>0$，都存在一个$\delta_{\varepsilon}$使得任意$\lambda(P)<\delta_{\varepsilon}$的带标志点的划分$(P,\xi)$都有$$|I-S_f(P,\xi)|<\varepsilon$$此时函数$f$被称之为区间$I$上的黎曼可积函数，其黎曼和的极限就称之为函数在闭区间$[a,b]$上的黎曼积分。用符号表示为$$\int_{a}^{b}f(x)\,dx:=\lim_{P;\lambda(P)\to 0}S_f(P,\xi)$$
> 

如果是高维的情况,比如$\mathbb{R}^2$那么我们可以推广区间的概念，用长方形的区域替代区间。因为所谓$x \in [a,b]$我们可以理解为是有两个实数$a,b$中间包含所有满足不等式$a\leq x\leq b$的实数。那么如果是二维的情况，我们大可以选择两组数$a_1,a_2$以及$b_1,b_2$然后定义二维的区间$$I:=\{(x,y)\in \mathbb{R}^2:a_1\leq x\leq b_1\text{ and }a_2\leq y\leq b_2\}$$这实际上就是一个长方形。而对于更高维度的情况，我们也可以定义类似的概念。

> [!note] 黎曼和的一般定义
> 令$a:=(a_1,\cdots,a_n),b:=(b_1,\cdots,b_n)$是$\mathbb{R}^n$当中的两个向量，定义$$I_{a,b}:=\{x=(x_1,\cdots,x_n)\in \mathbb{R}^n:a_i\leq x_i\leq b_i\}$$为一个超长方体。$$|I|=\prod_{i=1}^n(b_i-a_i)$$称之为长方体$I$的体积。
> 
> $P$称之为$I_{a,b}$的一个划分，如果我们可以把$I$表示为一系列有限个更小的互相不相交的子超立方体的并，即$$I_{a,b}=\bigcup_{k=1}^mI_k$$如果我们在每个$I_k$当中选取一个点$\xi_k\in \mathbb{R}^n$，并且令$\xi:=\{\xi_1,\cdots,\xi_k\}$，那么我们称$(P,\xi)$为$I_{a,b}$上带标志点的划分。
> 
> 现在考虑$I_{a,b}\to \mathbb{R}$上定义的有界函数$f(x)$，我们把和$$S_f(P,\xi):=\sum_{k=1}^m f(\xi_k)|I_k|$$称之为函数$f$在区间$I_{a,b}$上的按照带标志点的划分$(P,\xi)$的黎曼和。

那么和一维的情况一样，我们依旧可以定义划分$P$的“最大长度”$\lambda(P)$

这里我们借用$\mathbb{R}^n$当中某个集合的直径的说法，$$d(E):=\sup_{x,y\in E}||x-y||$$那么$\lambda(P)$可以被定义为$$\lambda(P):=\max\{d(I_k),k=1,\cdots,m\}$$
于是我们可以定义$I_{a,b}$上的黎曼可积：

> [!note] 实数的闭区间上黎曼积分的定义
> $$\int_{I_{a,b}}f(x)\,dx:=\lim_{P;\lambda(P)\to 0}S_f(P,\xi)$$或者用$\varepsilon-\delta$的的语言来表述就是:
> 
> 对任意的$\varepsilon>0$，都存在一个$\delta_{\varepsilon}$使得任意$\lambda(P)<\delta_{\varepsilon}$的带标志点的划分$(P,\xi)$都有$$|I-S_f(P,\xi)|<\varepsilon$$此时$I$就称之为函数在超长方体$I_{a,b}\subset \mathbb{R}^n$上的黎曼积分。

那么既然是极限，自然就问，极限是否存在呢？所以所谓黎曼可积，指的就是:

> [!note] 黎曼可积的定义
> 对于$I_{a,b}$上的黎曼可积的有界函数$f$,如果极限$$\lim_{P;\lambda(P)\to 0}S_f(P,\xi)$$是存在的，那么就称之为$I_{a,b}$上的黎曼可积函数。

当然，对于非长方体的定义域$E\subset \mathbb{R}^n$，我们可以稍加变通，只要$d(E)<\infty$即一个有界的集合，那么我们就可以考虑一个长方体$E\subset I_{a,b}$,然后我们考虑$f$定义在$I_{a,b}$上，然后考虑新的函数$$f(x)1_{E}(x)$$的黎曼和，以及黎曼积分。

### 2. 黎曼可积的判别

#### 2.1 柯西判别

因为所谓黎曼积分就是黎曼和的极限，而函数在闭区间上是否黎曼可积，就是极限是否存在的问题，因此我们立刻就能想到，极限存在的柯西判别：

> [!note] 定理2.1.1:黎曼可积的柯西判别
> 函数$f:[a,b]\to \mathbb{R}$是黎曼可积的，当且仅当对任意$\varepsilon>0$,存在一个$\delta_{\varepsilon}>0$使得任意满足$\lambda(P'),\lambda(P'')<\delta_{\varepsilon}$的划分$(P',\xi'),(P'',\xi'')$都有$$|S_f(P',\xi')-S_f(P'',\xi'')|<\varepsilon$$

下面这个定理与柯西判别是类似的：

> [!note] 定理2.1.2：黎曼可积的夹逼定理
> 函数$f:[a,b]\to \mathbb{R}$黎曼可积，当且仅当对任意的$\varepsilon>0$存在两个黎曼可积函数$\alpha_{\varepsilon},\beta_{\varepsilon}$满足$$\alpha_{\varepsilon}\leq f\leq \beta_{\varepsilon}$$并且$$\left|\int_a^b \alpha_{\varepsilon}(x)-\beta_{\varepsilon}\,dx\right|<\varepsilon$$


当$f$是可积函数的时候，上述引理重的结果是平凡的，因为我们只需要令$f=\alpha_{\varepsilon}=\beta_{\varepsilon}$即可满足要求。

接下来我们需要证明，如果引理3的结果被满足，那么$f$满足柯西判别的结果，从而$f$可积。具体来说，$\varepsilon>0$，令$\delta_{\varepsilon}>0$为使得任意的满足$\lambda(P)<\delta_{\varepsilon}$的划分$P$都有$$\left|\int_{a}^b \alpha_{\varepsilon}(x)\,dx -S_{\alpha_{\varepsilon}}(P,\xi)\right|<\varepsilon$$以及$$\left|\int_{a}^b \beta_{\varepsilon}(x)\,dx -S_{\beta_{\varepsilon}}(P,\xi)\right|<\varepsilon$$这样的$\delta_{\varepsilon}$总是存在的，因为我们假设$\alpha_{\varepsilon},\beta_{\varepsilon}$都是可积的函数。于是我们可以控制$S_f(P,\xi)$：$$S_{\alpha_{\varepsilon}}(P,\xi)\leq S_f(P,\xi)\leq S_{\beta_{\varepsilon}}(P,\xi)$$从而$$\int_{a}^b \alpha_{\varepsilon}(x)\,dx-\varepsilon<S_f(P,\xi)<\int_{a}^b \beta_{\varepsilon}(x)\,dx+\varepsilon$$
于是对于任意的带标志点的且半径小于$\delta_{\varepsilon}$的划分$(P',\xi'),(P'',\xi'')$我们考虑分段估计，于是有$$\begin{aligned}|S_f(P',\xi')-S_f(P'',\xi'')|&<\left|\int_a^b \alpha_{\varepsilon}(x)-\beta_{\varepsilon}\,dx\right|+\varepsilon \\&<2\varepsilon \end{aligned}$$于是$f$可积。

#### 2.2 黎曼判别

下面这个称之为“黎曼判别”的可积性判别法相对于柯西判别要更为简单一些。

> [!note] 定理2.2.3:黎曼判别
> 一个有界函数$f$在闭区间$[a,b]$上黎曼可积，当且仅当对任意的$\varepsilon>0$存在一个$\delta_{\varepsilon}>0$使得对任意的满足$\lambda(P)<\delta_{\varepsilon}$都有$$\sum_{i=1}^n \omega_f([x_{i-1},x_i])(x_i-x_{i-1})<\varepsilon$$

* 这里$\omega_f(E)$称之为函数在集合$E$上的振幅(oscillation)，具体内容及其证明参考：[[证明黎曼可积的黎曼判别]]。

#### 2.3 达布判别

> [!note] 函数黎曼可积的达布等价条件
> 长方体$I_{a,b}\subset \mathbb{R}^n$上的函数$f$黎曼可积，等价于，对任意的$\varepsilon>0$存在划分$P_{\varepsilon}$从而使得$$\sum_{k=1}^{n_{\varepsilon}} (M_k-m_k)|I_k|$$其中$\{I_k\}_{k=1}^{n_{\varepsilon}}$是划分$P_{\varepsilon}$产生的子长方体（$\mathbb{R}$上的时候称之为区间，有时候为了方便都统一称之为区间），$M_k,m_k$分别是$I_k$上函数$f$的上确界和下确界。

#### 2.4 Lebesgue判别

> [!note] 黎曼可积的Lebesgue等价条件，Lebesgue& Vitali 1907
> 闭区间$[a,b]$上的有界函数$f$黎曼可积当且仅当函数$f$是在此闭区间上几乎处处连续的。

* 证明可以参考：[[黎曼可积的Lebesgue判别]]。




