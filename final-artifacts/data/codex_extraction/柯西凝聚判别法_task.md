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

> [!note] Cauchy-Condensation-test
> 序列$a_n$不增，非负，那么级数$\sum_{n\geq1}a_n$的收敛发散性质等价于$\sum_{k}2^ka_{2^k}$的收敛发散性。

### 1. 从Dyadic分解的角度证明

对于被求和对象非负的情况，判断级数是否收敛实际上可以等价于一个求和估计问题,即求和是否有界?也就是$$\sum_{n=1}^{N}a_n=O(1)\text{?}$$然后又因为，$a_n$不增且由于级数收敛的必要条件$a_n\to0$.我们想要用分段估计，并且这时候我们知道余项估计想要精确，那么$n$越小的时候估计要精确，n越大的时候估计就不必那么精确了。

于是参考[[分段估计]]为了提高估计的精度，我们可以对靠近1的部分每段更少的项，而靠近$N$的部分每段更多的项目，于是有下面的想法:

> [!tip] 对非负不增序列部分和做Dyadic分解的基本想法
> 对于部分和$\sum_{n\geq N}a_n$其中被求和对象，序列$a_n$不增，非负，那么我们可以对自然数的子集$\{1,...,N\}$做Dyadic分解，把这个集合分解为$M_N = \lfloor\log_2^{N}\rfloor$段形如$$\{2^k,...,2^{k+1}-1\}$$的集合(其中$k\in \{0,...,M_N-1\}$)，以及一段$\{2^{M_N},...,N\}$.于是$$\sum_{n\leq N}a_n=\sum_{k=0}^{M_N-1}\sum_{2^k\leq n<2^{k+1}}a_n+R_N$$于是我们可以对每一段$\sum_{2^k\leq n<2^{k+1}}a_n$做简单的估计从而估计整个部分和。

于是我们只要在每一段上做最简单的估计，即取每一段最大以及最小的值，于是:
$$\begin{aligned}\sum_{n=1}^{N}a_n&\leq\sum_{k=0}^{M_N}\sum_{2^k\leq n<2^{k+1}}a_n\\&\leq\sum_{k=0}^{M_N}2^ka_{2^k}\end{aligned}$$反过来，因此如果后者是$$\begin{aligned}\sum_{n=1}^{N}a_n&\geq\sum_{k=0}^{M_N-1}\sum_{2^k\leq n<2^{k+1}}a_n\\&\geq\sum_{k=0}^{M_N-1}2^ka_{2^{k+1}}=\frac{1}{2}\sum_{k=1}^{M_N}2^{k}a_{2^{k}}\end{aligned}$$$O(1)$的，那么前者也是$O(1)$的，如果后者是无界的，那么前者也是无界的。当然这种方法肯定不仅仅限于对于是否收敛这种粗糙的估计，还可以做更精确的估计。

### 2. 积分版本的判别法

^f9ac86

> [!note] 命题2.1:积分的凝聚判别法 
> 设函数$f:[1,+\infty)\to \mathbb{R}$满足下列的条件：
> 1. $f(x)$在该区间上是局部可积的，即对任意闭区间$[a,b]\subset [1,+\infty)$上都是黎曼可积的。
> 2. $f(x)$在该区间上非负单调不增。
> 
> 那么广义积分$\int_{1}^{+\infty}f(x)\,dx$收敛，当且仅当级数$\sum_{n=1}^{+\infty}2^n f(2^n)$收敛。
> 
> ---
> 
> 设函数$f:(0,1]\to \mathbb{R}$满足下列的条件：
>  1. $f(x)$在该区间上是局部可积的，即对任意闭区间$[a,b]\subset (0,1]$上都是黎曼可积的。
>  2. $f(x)$在该区间上非负单调不增。
>
>那么广义积分$\int_{0}^{1}f(x)\,dx$收敛，当且仅当级数$\sum_{n=1}^{+\infty}2^{-n} f(2^{-n})$收敛。

^fad841

^5cab63
引理的证明主要是基于dyadic分解。我们把$[1,+\infty)$分解为$[2^n,2^{n+1}]$其中$n=0,1,\cdots$。然后我们利用$f(x)$的单调不增的性质，得到在每一个区间上的放缩$$\int_{2^n}^{2^{n+1}}f(x)\,dx\geq f(2^{n+1})(2^{n+1}-2^n)=f(2^{n+1})2^n$$另一方面$$\int_{2^n}^{2^{n+1}}f(x)\,dx\leq f(2^n)(2^{n+1}-2^n)=f(2^{n})2^n$$然后我们对$n$进行求和,然后取极限，于是得到：$$\int_{1}^{+\infty}f(x)\,dx \geq \frac{1}{2}\sum_{n=1}^{+\infty}2^nf(2^{n})$$另一方面$$\int_{1}^{+\infty}f(x)\,dx \leq f(1)+\sum_{n=1}^{+\infty}2^nf(2^n)$$
因此积分的收敛或者发散性就完全等价于对应级数的收敛与发散性质。

* 同理我们也可以对$(0,1]$区间进行dyadic拆分，分为$$I_n:=(2^{-(n+1)},2^{-n}],\quad n\geq 0$$从而对任意$x\in I_n$都有$$f(2^{-n})\leq f(x)\leq f(2^{-(n+1)})$$其余步骤与$[1,+\infty)$的情况一致。

---

> [!note] 命题2.2 
> 设$(X,\mu)$为测度空间，$1\leq p<\infty$。对可测函数$f$有$$f\in L^p \iff \sum_{k\in \mathbb{Z}} 2^{kp}\mu(\{x:|f(x)|>2^k\})<\infty$$

^5269ef

令$m_f(t):=\mu(\{|f|>t\}),\quad t>0$为此函数的分布函数,这是一个右连续且单调不增的函数。由[[layer-cake 表示]]，$$\int_{X} |f|^p \,d\mu = p\int_{0}^{\infty}t^{p-1}m_f(t)\,dt\tag{1}$$此时我们的目标就可以转向估计$f$分布函数$m_f$有关的积分。参照“命题3.1”，我们决定对$(0,\infty)$这个区间进行dyadic分解。

在每个dyadic的区间上：$$\int_{2^k}^{2^{k+1}}t^{p-1}m_f(t)\,dt\geq m_f(2^{k+1})\int_{2^k}^{2^{k+1}} t^{p-1}\,dt =(2^p-1)2^{kp}m_f(2^{k+1})$$另一个方向上$$\int_{2^k}^{2^{k+1}}t^{p-1}m_f(t)\,dt\leq m_f(2^{k})\int_{2^k}^{2^{k+1}} t^{p-1}\,dt =(2^p-1)2^{kp}m_f(2^{k})$$结合以上分析以及$(1)$我们可以知道$$\int_X |f|^p \,d\mu \asymp \sum_{k\in \mathbb{Z}}2^{kp}m_f(2^k)$$

---

> [!tip] 想法2.3
> 有的时候我们也并不是一定需要对整个积分做基于dyadic分解的放缩，我们可以只对其中某部分进行这样的操作。毕竟要求整个被积函数单调，这个条件还是太强了一些。我们可以稍微推广一下之前的估计方法，如果我们可以把被积函数看成是$\omega(t)f(t)$的形式，其中$f(t)$依旧拥有单调性以及非负性，而$\omega(t)f(t)$不一定具有单调性，但是具有非负性。那么我们可以只针对$f$，利用单调性进行放缩，把$\omega$单纯看成是积分的某种权重函数，这样也可以得到一个广义上的同阶的级数。

下面我们来看一个关于此想法的具体实践：

> [!note] 命题2.4
> 函数$f:[0,1]\to \mathbb{R}$单调不减，且非负，并且满足$$\int_0^1 \frac{f(t)}{t}\,dt<\infty$$那么一定有$f(t)\to 0$。

* 注意这里$f$的单调性是必要的，否则会存在反例。

此处按照之前的想法，$\omega(t)=\frac{1}{t}$。然后我们取$I_n:=(2^{-(n+1)},2^{-n}]$来分割$(0,1]$。然后在每个小区间上有放缩$$f(2^{-(n+1)})<f(t)\leq f(2^{-n})$$然后令$$\omega_n:=\int_{I_n}\frac{1}{t}\,dt=\log 2$$从而$$(\log 2)f(2^{-(n+1)})\leq \int_{I_n}\frac{f(t)}{t}\,dt\leq (\log 2)f(2^{-n})$$于是$$\int_0^1 \frac{f(t)}{t}\,dt\asymp \sum_{n\geq 0}f(2^{-n})$$从而我们可以从积分的收敛性，导出$f(2^{-n})$。

一般来说这种$f(x_n)\to 0,x_n\downarrow 0$并不足以导出$f(t)\to 0$，但是如果$f$
具有单调性以及非负性，那就另当别论。此时对任意$\varepsilon>0$，由于存在正整数$N_{\varepsilon}$使得任意$n>N_{\varepsilon}$都有$0\leq f(2^{-n})<\varepsilon$。那么我们只要令$M_{\varepsilon}:=2^{-N_{\varepsilon}}$那么只要$t<M_{\varepsilon}$，就能满足$\lfloor \log_2 \frac{1}{t}\rfloor>N_{\varepsilon}$从而$$0\leq f(t)\leq f(2^{-\lfloor \log_2^{1/t}\rfloor})<\varepsilon$$从而$f(t)\to 0$。



### 3. 典型的例子

一个简单的例子：
*  [[使用Dyadic分解估计调和数的下界]]:我们可以通过Dyadic分解的方式，类似于上面的证明，得到调和数的一个下界估计从而证明其发散。当然也可以直接使用凝聚判别，把级数转换为$\sum_k 1$的形式，然后利用敛散性的等价，直接得到发散的结论。

这个收敛判别的优势在于可以加速级数的收敛或者发散，从而使得判断其收敛或者发散性质变得更为容易。

> [!question] 问题3.1
> 证明级数$\sum_{n}\frac{1}{n\log(n)}$是发散的。

^d315a5

由上面的判别法，我们知道这个级数是与$$\sum_k \frac{2^k}{k2^k\log(2)}=\sum_k\frac{1}{k\log(2)}$$相同级别的，那么后者发散，进而导致前者发散。

这里我们就能看得出来，其实级数$\sum_{n}\frac{1}{n\log(n)}$是比级数$\sum_n\frac{1}{n\log(2)}$发散更慢的级数，因此更难判断一些，但是柯西的这个判别法可以让发散的级数发散的更快一些，从而使得判断其发散性更加容易。

> [!example] 例子3.2
> 证明$\sum_n \frac{1}{n\log^2(n)}$是收敛的。

这个级数与$\sum_n\frac{1}{n^2\log^2(2)}$是同级别的，而这个级数是收敛的，因此上面的级数也是收敛的。

从这个例子当中我们能看出来，该判别法还能让收敛级数收敛的更快，这也能让判断变得更为容易一些。

> [!example] 例子3.3
> 已知正实数序列$a_n$是单调增加的，并且级数$\sum_{n\geq 1}\frac{1}{a_n}$是收敛的，证明$\sum_{n\geq 1}\frac{n}{a_1+\cdots+a_n}$也是收敛的。

首先我们的出发点是估计级数的部分和，只要部分和有界即可。然后我们能通过举例知道，并非所有的单调正实数列组成的形如$\sum_{n\geq 1}\frac{n}{a_1+\cdots+a_n}$的级数都是收敛的，因此我们相当于是利用$\sum_{n\geq 1}\frac{1}{a_n}$收敛的性质来制造级数部分和的上界估计。

这里我们想到使用Dyadic分解,按照上面的分析，我们考虑部分和$$\begin{aligned}\sum_{n=1}^{N}\frac{n}{S_n}&\leq\sum_{k=0}^{M_N}\sum_{2^k\leq n<2^{k+1}}\frac{n}{S_n}\\&\leq\sum_{k=0}^{M_N}\frac{2^k}{a_{2^k}}\end{aligned}$$
此处第二行由$a_n$的单调性得到。最后的和一定是有界的，因为$a_n$单调增加导致$\frac{1}{a_n}$单调减少并且为正，从而柯西凝聚判别告诉我们$\sum_n \frac{1}{a_n}$的收敛性等价于$\sum_{k}\frac{2^k}{a_{2^k}}$的收敛性，因此部分和序列$\sum_{n=1}^{N}\frac{n}{S_n}$是有界的，因此级数收敛。

* 实际上“例子3.3”当中$a_n$的单调性的条件是多余的。在去掉单调性的条件下，我们可以借助[[Carleman不等式#1. 非负序列和的Carleman不等式]]来对目标和进行[[逐项估计]]，详细参考[[Carleman不等式#1.2 一些典型的应用]]当中的“命题1.2.1”。