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
  - 考研
  - 微积分
---
### 1. 序列的柯西收敛判别

#### 1.1 序列柯西收敛判别的证明

> [!note] 定理1.1.1:数列的柯西判别
> 实数列$x_n$收敛到实数$x$，当且仅当对于任意$\varepsilon>0$存在正整数$N_{\varepsilon}$使得任意$n,m>N_{\varepsilon}$都成立$$|x_n-x_m|<\varepsilon$$

* 实际上这也是实数完备性的证明。因为实数完备性讲的是，任何柯西列都存在极限，并且极限是一个实数（非扩展实数系当中）。

下面是“定理1.1.1”的证明。

---

首先我们证明，如果序列收敛到某个实数$x$，那么一定符合柯西判别。

序列收敛意味着，对于任意的$\varepsilon>0$，存在正整数$N_{\varepsilon}>0$使得任意$k>N_{\varepsilon}$都有$$|x_k-x|<\varepsilon$$那么对于任意$n,m>N_{\varepsilon}$,我们就可以控制利用三角不等式控制$|x_n-x_m|$，从而得到$$|x_n-x_m|<|x_n -x|+|x_m-x|<2\varepsilon$$从而证明收敛的序列都是满足柯西判别的。

然后我们需要证明，满足柯西判别条件的序列都是收敛的序列。这就必须首先回答一个问题，极限$x$从何而来？

极限$x$从区间套定理当中而来。

> [!note] 定理1.1.2:区间套定理:实数版本
> 实数$\mathbb{R}$当中的一列下降的闭区间套的交集非空。

* 所谓下降的闭区间套，指的是一列区间的序列$I_n:=[a_n,b_n]$其端点由两个序列$a_n,b_n$构成，并且序列满足$$a_{n}\leq a_{n+1}\leq b_{n+1}\leq b_n$$从区间的角度上来看则可以表示为$$I_{n+1}\subseteq I_n\subseteq\cdots\subseteq I_1$$"定理1.2"指的是，所有这些区间的交集$\cap_{n\geq 1}I_n$不为空集。

> [!note] 证明的主要计划
> 证明的动机，实际上与[[函数与序列的上下极限]]当中的"命题1.1"有关。序列满足柯西判别的条件，实际上满足了序列有界性的条件，以及上下极限相等的条件，这就是为何这样的序列会存在极限的原因。
> 
> 具体来说，如果序列满足柯西判别的条件，那么我们可以定义$$a_n:=\inf_{k\geq n}x_k,b_n:=\sup_{k\geq n}x_k$$此时定义$I_n:=[a_n,b_n]$，那么$I_n$可以构成一个"定理1.2"当中所要求的下降的区间套。因此这个区间套的交集当中存在一个实数$x$，其满足对任意足够大的$n$都满足$$a_n\leq x\leq b_n$$同时，当$k\geq n$的时候$a_n\leq x_k\leq b_n$，因此$$|x_k-x|\leq b_n-a_n$$然而柯西列的条件向我们保证了$b_n-a_n \to 0$。因此我们可以由此得到关于$|x_k-x|$上界的任意小的控制，从而证明序列收敛到$x$。

因此实际上我们现在关键要验证的步骤就是，柯西列的条件可以导致$b_n-a_n \to 0$。

这是一定的，因为柯西列告诉我们对于任意的$\varepsilon>0$,存在一个正整数$N_{\varepsilon}'$使得任意$k,m>N_{\varepsilon}'$都有$|x_k-x_m|<\varepsilon$。而如果现在我们固定$m_0=N_{\varepsilon}'+1$，并且令$k>m_0$，那么$$x_{m_0}-\varepsilon<x_k<x_{m_0}+\varepsilon$$因此此时如果$n>m_0$那么由于$k\geq n\geq m_0$于是$$b_n:=\sup_{k\geq n}x_k\leq x_{m_0}+\varepsilon$$同理可证明$$a_n\geq x_{m_0}-\varepsilon$$因此我们知道只要$n\geq m_0$那么$$b_n-a_n\leq 2\varepsilon$$那么最后我们简化一下中间的逻辑，令$N_{\varepsilon}=N_{\varepsilon}'+2$那么对于任意$\varepsilon>0$只要$k>N_{\varepsilon}$那么（导出$k\geq n\geq m_0$）$$|x_k-x|\leq b_n-a_n\leq 2\varepsilon$$最后只需要调整一下$\varepsilon$的选取就是极限的定义，因此序列极限存在。


---

在一般的度量空间当中我们也会谈论柯西列，并且柯西判别可以推广为：

> [!note] 定理1.1.3
> 令$(a_n)$是度量空间$(X,d)$当中的序列，如果序列满足：对任意的$\varepsilon>0$都存在正整数$N_{\varepsilon}$使得对任意$m,n>N_{\varepsilon}$都有$$d(a_m,a_n)<\varepsilon$$那么就称这是该度量空间当中的一个柯西列。
> 
> 完备度量空间当中的柯西列都收敛，且极限唯一。

#### 1.2 序列的柯西判别的用法

^e811c6

一个基于[[用子列来提升收敛或发散性质#1. 用子列来加速收敛或发散]]的“想法1.1”并结合"柯西收敛判别"来证明序列并非收敛的技巧：

> [!tip] 想法1.2.1
> 1. 找到一个并不满足柯西收敛判别的子列。
> 2. 找到两个收敛的子列,$a_n,b_n$使得$|b_n-a_n|>\varepsilon_0$。这里面的一种特殊的做法是，找到两个收敛到不同结果的子列。

^cc9289

* 关于策略1：因为一个收敛的序列其所有子列都是收敛的，所以如果一个序列存在一个不收敛的子列，那么这个序列一定是不收敛的。
* 关于策略2的特殊做法：我们假设$a_n\to a,b_n\to b$不失一般性假设$b>a$，那么对一个固定的$0<\varepsilon_0 <\frac{b-a}{4}$，存在一个$N_{\varepsilon_0}$使得任意$n>N_{\varepsilon_0}$都有$$a-\varepsilon_0<a_n<a+\varepsilon_0<b-\varepsilon_0<b_n<b+\varepsilon_0$$于是$$|a_n-b_n|>(b-a)-2\varepsilon_0>\frac{b-a}{2}$$而$\{a_n\},\{b_n\}$均为$\{x_k\}$的子列，那么自然$x_k$并不满足柯西判别条件，从而并非收敛序列。

> [!example] 例子1.2.2:调和数列发散
> 定义调和数列$$H_n:=\sum_{k\leq n}\frac{1}{k}$$现在我们来证明这个序列是发散的。我们现在忘记[[和的积分估计]]这个工具，单纯从"想法1.2.1"这个角度入手这个问题。所以我们现在的任务就是估计$|H_n-H_m|$的下界，但是我们发现这样的和增长很慢，下界不容易估计。于是我们本着，既然序列可能是发散的，那么不妨借助一个子列，从而让它发散地更快一些，更易于暴露其发散性质一些（这个想法参考[[用子列来提升收敛或发散性质#1.1 对于收敛序列，用子列来加速收敛或发散]]）。因此我们考虑子列$H_{2^n}$，结合[[逐项估计]]我们发现$$|H_{2^{n+1}}-H_{2^n}|=\sum_{k=1}^{2^n}\frac{1}{2^n+k}>\frac{2^n}{2^n+2^n}=\frac{1}{2}$$因此通过柯西判别，我们知道$H_{2^n}$这个子列是发散的。


> [!example] 例子1.2.3
> 序列$x_n:=(-1)^n$发散。因为我们可以找到两个收敛到不同结果的子列:$x_{2k}=1,x_{2k+1}=-1$，因此序列是发散的。

但是我们未必一定要寻找收敛的子列，有时候我们只需要保证两个子列之间的误差具有一个正的下界即可，特别是寻找收敛的子列比较困难的时候。

> [!example] 例子1.2.4
> 序列$x_n:=\sin(n)$的极限不存在。因为我们总是可以在$$I_{A,k}:=(2k\pi+\frac{\pi}{4},2k\pi+\frac{2\pi}{3}),I_{B,k}:=(2k\pi+\frac{5\pi}{4},2k\pi+\frac{5\pi}{3})$$中分别找到两个不同的正整数$n_k,m_k$。相应的因为函数$\sin(x)$在这两个集合上的取值分别为区间$(\frac{\sqrt{2}}{2},1)$以及$(-\frac{\sqrt{2}}{2},-1)$因此$$|\sin(n_k)-\sin(m_k)|\geq \sqrt{2},\forall k\in \mathbb{Z}^{+}$$因此柯西判别法告诉我们，序列的极限并不存在。至于为何考虑上述两个区间，其想法可以参考:[[证明正弦函数在整数上取值的序列的极限是不存在的]]其中的2.2节。

更多的例子:

* [[单调无界的正序列其差分比自身的值的和也无界]]:在这个问题当中我们需要证明当$a_n>0$并且单调增加并且无界的时候，序列$$S_n:=\sum_{k=2}^{n}\frac{a_k-a_{k-1}}{a_k}$$不收敛。因为这个问题本身没有更多的信息，这导致一系列针对具体问题的和的估计方法失效。因此这里我们选择回归到最基本的方法上，利用柯西收敛判别。那么我们实际上就是要估计，$$\sum_{k=N+1}^{M} \frac{a_k-a_{k-1}}{a_k}$$的一个正实数的下界。这里的关键在于，当$a_n$具有以上性质的时候，对任意的$a_N$可以找到一个更大的$M$使得$a_M>2a_N$，从而利用逐项估计得到我们想要的下界估计。

---

此外这里补充一个数列收敛的柯西判别的必要条件：

> [!note] 命题1.2.5:柯西列的一个必要条件
> 如果是序列$(a_n)$是柯西列，那么对于任意固定的正整数$p$都有$$|a_{n+p}-a_n|\to 0$$

^9993bc

* 这是一个必要条件，因为对任意的$\varepsilon>0$存在正整数$N_{\varepsilon}$使得对于任意的$n,m>N_{\varepsilon}$都有$|a_m-a_n|<\varepsilon$。现在我们令$m=n+p$，那么就会得到$$|a_{n+p}-a_n|<\varepsilon$$因此$|a_{n+p}-a_n|\to0$。

* 要注意的是，反过来这是不对的。比如考虑$H_n:=1+\frac{1}{2}+\cdots+\frac{1}{n}$这个序列，它不是一个柯西列。但是对于任意固定的正整数$p$都有$$H_{n+p}-H_n = \frac{1}{n+1}+\cdots+\frac{1}{n+p}\leq \frac{p}{n+1}\to 0$$究其原因，该命题当中的$p$是固定的。如果我们限制$m=n+p$，那么我们相当于限制了$m,n$之间的距离，使得二者的距离保持不变。可是原本的柯西判别中，我们要求的是$m,n$之间的距离为任意整数。

尽管以上命题只是序列为柯西列的一个必要条件，但是它依旧有一些价值。比如在我们比较确定序列不是柯西列的情况下，我们要证明这件事，那么我们只要考虑这样一个简单一些的必要条件即可。比如：

* 我们从另外一个角度看待前文提到的例子：证明$a_n:=(-1)^n$不是柯西列，从而证明其极限不存在。相较于柯西列的定义，我们可以简单验证其必要条件$$|a_{n+1}-a_n|=|(-1)^{n+1}-(-1)^n|=2$$此处我们令$p=1$，从而验证了$|a_{n+p}-a_n|$并不收敛到0，从而证明这不是一个柯西列。
* 另外一个不平凡的例子可以参考[[证明正弦函数在整数上取值的序列的极限是不存在的#2.1 思路1：与柯西列的必要条件矛盾]]：这个例子当中我们采用反证法，假设$\sin(n)$满足柯西列的必要条件，也就是$|\sin(n+1)-\sin(n)|\to 0$。但是结合三角恒等式，我们会导出一个明显的矛盾，从而证伪了这个假设，从而证明了序列$\sin(n)$不是一个柯西列。

我们可以稍微改造一下这个必要条件，从而把它变成一个充分条件：

> [!note] 命题1.2.6: 柯西列的一个充分条件
> 如果实数(复数)列$(a_n)$满足条件$|a_{n+1}-a_n|\leq b_n$并且$\sum_{n\geq 1}b_n$是一个收敛的级数，那么$a_n$是一个柯西列。

* 满足这种条件的序列还有一个名字:"有界变差的序列"。也就是说一个序列如果是有界变差的，那么序列是柯西列。
* 该命题的证明主要依仗这样的估计：对于任意的正整数$m,n$，不妨假设$m>n$于是$$\begin{aligned}|a_{m}-a_n|&\leq |a_{m}-a_{m-1}|+\cdots+|a_{n+1}-a_n|\\&\leq b_{m-1}+\cdots+b_n\\&= \sum_{k=n}^{m-1}b_k\end{aligned}$$由于级数是收敛的，那么这个级数的部分和是一个柯西列，于是对于任意的$\varepsilon>0$，存在一个正整数$N_{\varepsilon}$使得$m>n>N_{\varepsilon}$都有$\sum_{k=n}^{m-1}b_k<\varepsilon$。从而$|a_m-a_n|<\varepsilon$，于是序列$(a_n)$是一个柯西列。

这是对于必要条件"命题1.2.5"的一种加强。因为必要条件只说了$|a_{n+1}-a_n|\to 0$，但没说要以多快的速度收敛到0，然而"命题1.2.6"的必要条件讲了，只要$|a_{n+1}-a_n|$上界的衰减速度足够快以至于上界形成的级数收敛，那么这就是一个柯西列。

> [!note] 命题1.2.7: 柯西列的一个充分条件的推广
> 如果度量空间$(X,d)$当中的序列$(a_n)$满足条件$d(a_{n+1},a_n)\leq b_n$并且$\sum_{n\geq 1}b_n$是一个收敛的级数，那么$a_n$是该度量空间当中的柯西列。

^477e07

* 这样的充分条件的一个非平凡的应用案例就是[[度量空间上的不动点定理#1.1 Banach不动点定理]]：Banach不动点定理当中假设了映射是压缩映射，从而某个初值在该映射的迭代下形成的序列$x_n$满足$$d\left(x_{n+1},x_n\right)\leq qd\left(x_n,x_{n-1}\right)\leq\cdots\leq q^nd\left(x_1,x_0\right)$$其中$0<q<1$，然后因为$q^n$形成的级数收敛，因此序列$(x_n)$是一个柯西列。然后因为Banach不动点定理是在Banach空间当中讨论，因此极限一定存在且唯一，这个极限就是压缩映射对应的不动点。
* 我们可以看一个具体的例子：假设实数列满足递归表达$$a_{n+1}=\cos(a_n),a_1=0$$那么这个序列是柯西列，因为它满足Banach不动点定理。当然我们也可以手动验证，思路就是验证它是否满足柯西列的充分条件，即考察其差分的衰减速度：$$|a_{n+1}-a_n|=|\cos(a_n)-\cos(a_{n-1})|$$然后对$\cos(x)$应用中值定理，存在一个介于由$a_n,a_{n-1}$为端点的开区间中的一个值$\xi_n$满足$$|\cos(a_n)-\cos(a_{n-1})|=|\sin(\xi_n)|\cdot|a_n -a_{n-1}|$$由于$a_n\in[0,1]$因此$|\sin(\xi_n)|\leq \sin(1)=q<1$，因此我们知道$$|a_{n+1}-a_n|\leq q^{n-1}|a_2-a_1|$$这个衰减速度足以使得$(a_n)$是柯西列了。



#### 1.3 函数列逐点收敛的柯西判别

> [!note] 函数列逐点收敛的柯西判别
> 函数列$f_n(x):X\to \mathbb{C}$逐点收敛到函数$f(x):X\to \mathbb{C}$当且仅当对于任意固定的$x_0$以及任意的$\varepsilon>0$存在正整数$N_{\varepsilon,x_0}$使得任意$n,m>N_{\varepsilon,x_0}$都成立$$|f_n(x_0)-f_m(x_0)|<\varepsilon$$

实际上函数列的逐点收敛中，当$x=x_0$固定下来以后我们可以定义$y_n:=f_n(x_0)$，如此一来整个判别无非就是序列的柯西收敛判别罢了。
### 2. 一致收敛的柯西判别

> [!note] 一致收敛的柯西判别
> 函数列$f_n(x):X\to \mathbb{C}$一致收敛到函数$f(x):X\to \mathbb{C}$当且仅当对于任意$\varepsilon>0$存在正整数$N_{\varepsilon}$使得任意$n,m>N_{\varepsilon}$都成立$$\sup_{x\in X}|f_n(x)-f_m(x)|<\varepsilon$$

* 如果一致收敛，那么必定满足柯西判别：此处我们把问题转换为估计问题，那么我们需要估计的对象为$\sup_{x\in X}|f_n(x)-f_m(x)|$，假设函数列一致收敛到$f(x)$,那么我们可以利用三角不等式搭建一个“桥梁”,对任意$x\in X$任意正整数$m,n$都有：$$|f_n(x)-f_m(x)|\leq |f_n(x)-f(x)|+|f_m(x)-f(x)|$$然后我们对两边取上确界，得到$$\sup_{x\in X}|f_n(x)-f_m(x)|\leq \sup_{x\in X}|f_n(x)-f(x)|+\sup_{x\in X}|f_m(x)-f(x)|$$而一致收敛的条件告诉我们，对于任意$\varepsilon>0$存在$N_{\varepsilon}$只要$n,m>N_{\varepsilon}$那么我们就有$$\sup_{x\in X}|f_n(x)-f_m(x)|\leq2\varepsilon$$只要调整一下$\varepsilon$的选取，那么我们的目标就算达到了。

剩下的部分我们需要证明，如果函数列满足柯西判别，那么函数列一致收敛。现在的问题是，如果我们要证明一致收敛，收敛的极限从何而来？

> [!note] 一致收敛的极限从何而来?
> 这个极限可以从逐点收敛而来。因为我们已经证明了函数列逐点收敛的柯西判别。既然现在函数列$f_n(x)$对于每个固定的$x$都满足逐点收敛的柯西判别，那么就必然存在一个极限函数，假设为$f(x)$，那么接下来我们只要估计$\sup_{x\in X}|f_n(x)-f(x)|$，如果能把这个对象找到一个任意小的上界，那么一致收敛就能被证明。

事实上我们可以对柯西判别条件$\sup_{x\in X}|f_n(x)-f_m(x)|<\varepsilon$的$m$直接求极限，从而得到$$\sup_{x\in X}|f_n(x)-f(x)|\leq \varepsilon$$从而直接得到一致收敛的结果。然而这样真的严谨吗？接下来我们来证明，为何这个操作是严谨的。

令$S_{n,m}:=\sup_{x\in X}|f_n(x)-f_m(x)|$按照上确界的定义，对于任意$\delta>0$存在$x_{\delta}\in X$从而$$S_{n,m}-\delta<|f_n(x_{\delta})-f_m(x_{\delta})|\leq S_{n,m}$$此时对于固定的$x_{\delta}$,我们可以对$m$取上极限,令$\limsup_{m\to \infty}S_{n,m}:=S_n$,从而得到$$S_n-\delta\leq |f_n(x_{\delta})-f(x_{\delta})|\leq S_n$$那么按照上确界的定义，实际上我们得到$$\sup_{x\in X}|f_n(x)-f(x)|=S_n$$而由于柯西判别的条件，对任意$\varepsilon>0$存在$N_{\varepsilon}$只要$n>N_{\varepsilon}$那么$S_n\leq \varepsilon$因此$$\sup_{x\in X}|f_n(x)-f(x)|\leq \varepsilon$$最后只要调整一下$\varepsilon$一开始的选取，我们就达到了目的。

* 这个结果可以用来证明$C(X\to \mathbb{C};||\cdot||_u)$是完备的。因为一致收敛的连续函数序列其极限函数也是连续的，借助一致收敛的柯西判别便可得到其完备性。

### 3. $L^p$空间当中的柯西收敛判别

> [!note] Lp空间的柯西收敛判别
> $\mu$是装备在$X$上的$\sigma-$finite的测度。函数列$$f_n(x)\in L^p(X\to \mathbb{C},\mu),\infty\geq p\geq 1$$的极限存在,即存在一个$f \in L^p$使得$||f_n-f||_{L^p}\to 0$，当且仅当$\forall \varepsilon>0$存在正整数$N_{\varepsilon}$使得任意$n,m>N_{\varepsilon}$都有$$||f_n-f_m||_{L^p}<\varepsilon$$

* 首先如果函数列$L^p$收敛到某个极限函数$f$，那么上述结果是一定成立的，通过$L^p$范数的三角不等式可以得到。
* 反过来，如果函数列是一个柯西列，那么一定存在一个$f\in L^p$作为其极限函数。换句话说，此处的$L^p$空间是一个完备赋范数空间，即Banach空间。这实际上就是[[Riesz-Fischer定理]]的内容。
