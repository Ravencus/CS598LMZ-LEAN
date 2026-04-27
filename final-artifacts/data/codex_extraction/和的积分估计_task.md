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
  - tool_idea
---
离散的和与连续的积分在一定误差范围内是接近的，这便给我们估计一个难以求和的对象提供了另一种思路：如果其对应的积分更容易处理的话，不妨估计其积分。

首先关于离散的和与连续的积分之间的关系，可以参考：
* [[黎曼积分与黎曼和的误差]]：这个问题中我们涉及这类问题的最简单情形，估计$$R_n:=\int_0^1f(t)\,\mathrm{d}t-\frac1n\sum_{k=0}^{n-1}f(k/n)$$黎曼积分与均匀划分的黎曼和之间的绝对误差。在这个问题的简单情形下，我们可以用“逐项估计”来得到估计。我们知道当$f\in C^2([0,1])$的时候有$$\frac1n\sum_{k=0}^{n-1}f(k/n) = \int_0^1f(t)\,\mathrm{d}t - \frac{f(1)-f(0)}{2n}+O\left(1/n^2\right)$$从这个例子便能看出，如果$f(k/n)$关于$k$的和是困难的，但$f(x)$从求定积分的角度上来说是相对简单的，那么我们完全可以把含参数和的估计转换为求积分，或者积分的估计。
* 基于以上观点，对于含参数的和$\sum_k g_n(k)$的估计，常常会考虑转换为某种$\frac1n\sum_{k=0}^{n-1}f(k/n)$的形式，然后通过积分估计来处理。但要注意的是，这个方法极其特殊，并非对于任意的$g_n(k)$的和都能奏效，所以我们需要更强力更系统的积分估计技术。不过适当的处理技巧，也能把看似不能配成$\frac1n\sum_{k=0}^{n-1}f(k/n)$的问题转换为可能。具体可以参考[[一个竞赛中的和的渐近展开问题]]以及对应的想法：[[利用已知的渐近结果求渐近展开的技巧]]。

此外积分估计相对于离散的和的估计还有一个优势，积分估计可以通过换元，把难以估计的积分转换为容易估计的积分，但是离散的和就不容易这样处理。

* [[体现积分估计相较于和的估计优势的一个问题]]:在此问题当中估计目标的和与积分没有任何一个直接是能简单估计出来的$$\begin{aligned}\sum_{k=3}^n n^{\frac{1}{\log_2 k}}&=\int_{3}^n n^{\frac{1}{\log_2x}}\,dx+O(n^{\frac{1}{\log_23}}+n^{\frac{1}{\log_2n}})\\&=\int_{3}^n n^{\frac{1}{\log_2x}}\,dx+o(n)\end{aligned}$$但是相对而言，我们针对于积分的办法会更多一些。我们对积分进行变量替换以后，可以达成积分估计的目标。但直接估计和这个目标就不容易达成了。
* [[体现积分估计相较于和的估计优势的例子2]]：在这个问题当中估计和$\frac{1}{\sqrt{n}}\sum_{k=0}^n e^{-k^2/n}$与积分$\int_{0}^n e^{-x^2/n}\,dx$有什么区别？后者可以通过积分换元变成$\sqrt{n}\int_{0}^{\sqrt{n}}e^{-y^2}\,dy$这样一个已知的积分，而前者不行。
### 1. 和的简单积分估计

^34b186
#### 1.1 简单的积分估计脱胎于逐项估计

和的简单积分估计来自于[[逐项估计]]，其基本的想法是：如果函数$f$在实数轴的某个区间$I:= [a,b]$上是单调的，不妨假设是单调减少的（函数自然是黎曼可积的，参考[[单调有界函数几乎处处连续]],以及[[黎曼积分的定义以及黎曼可积的判别]]），那么对于任意的子区间$[x_{k},x_{k+1}]\subseteq [a,b]$上，$$f(x_k)(x_{k+1}-x_k)>\int_{x_k}^{x_{k+1}}f(x)\,dx$$以及$$f(x_{k+1})(x_{k+1}-x_k)<\int_{x_k}^{x_{k+1}}f(x)\,dx$$如果$x_1:=a,x_n=b$那么我们对上面的式子进行逐项地放缩，就会得到$$\sum_{k=1}^{n-1} f(x_k)(x_{k+1}-x_k)>\int_{a}^{b}f(x)\,dx$$以及$$\sum_{k=1}^{n-1} f(x_{k+1})(x_{k+1}-x_k)<\int_{a}^{b}f(x)\,dx$$
对于一种特殊地情况，令$x_{k}:=k$，此时我们有$$\sum_{k=1}^{n-1} f(k)>\int_{1}^n f(x)\,dx$$以及$$\sum_{k=2}^{n} f(k)<\int_{1}^n f(x)\,dx$$综合起来我们可以得到$$f(1)+\int_{1}^n f(x)\,dx>\sum_{k=1}^n f(k)>f(n)+\int_{1}^n f(x)\,dx$$
一些典型的例子：

* [[对离散的和做积分估计]]：这个问题当中我们需要给出$$\sum_{k=1}^{n}(x_{k}-x_{k-1})(1-x_k)$$的上界估计，其中假设$0=x_0<x_1<...<x_n<1$。那么我们可以利用$f(x)=1-x$在$(0,1)$上的单调性以及非负性来做一个简单的积分估计，从而得到$$\sum_{k=1}^{n}(x_{k}-x_{k-1})(1-x_k)<\int_{0}^{x_n}f(x)\,dx <\int_{0}^{1}1-x \,dx = \frac{1}{2}$$
* [[CMO不等式中的积分估计]]：此问题中，经过一番代数处理，我们最终需要估计$$\sum_{i=1}^n (y_i-y_{i-1})\frac{1}{\sqrt{1-y_{i-1}^2}}$$其中$0=y_1<\cdots<y_n=1$。我们可以利用$f(x)=\frac{1}{\sqrt{1-x^2}}$的单调性，结合和的简单积分估计，从而得到$$\sum_{i=1}^n (y_i-y_{i-1})\frac{1}{\sqrt{1-y_{i-1}^2}}<\int_{0}^{1}\frac{1}{\sqrt{1-x^2}}\,dx=\frac{\pi}{2}$$
* [[正实数序列与自己前n项和的p次方的比值组成的级数收敛]]:这个问题当中我们需要估计部分和$$T_N=\sum_{n\leq N}\frac{a_n}{S_n^p}$$的上界，证明$T_N$是一个有界序列，从而对应级数收敛（其中$a_n>0,S_n$是$a_k$前$n$项和,$p>1$）。这里如果我们把$a_n$替换为$S_n-S_{n-1}$，那么就具有了$(S_{n}-S_{n-1})f(S_n)$的形式，于是用积分估计就是一种自然的想法。

在放缩$(x_{k+1}-x_k)f(x_{k+1})<\int_{x_k}^{x_{k+1}}f(x)\,dx$当中如果我们对$x_k=k$,那么便成为了单纯对$f(k+1)$的积分放缩，此时再按照逐项估计的操作，两边求和，那么可以得到下面的结果:

> [!note] 和的简单积分估计
> 如果函数$f:[x,y]\to\mathbb{R}$是单调函数那么求和可以被积分估计(量化版本的):$$\sum_{n\in{\mathbb{Z}}:y\leq n\leq x}f(n)=\int_{y}^{x}f(t)\,dt+O(|f(x)|+|f(y)|)$$

* 这个结果的被求和对象$f(n)$可以看成是一个算术函数(定义域为整数，值域为复数)，于是这样的估计在数论当中是有价值的。不过因为精度不怎么高，只能作为粗略的处理手段。

不失一般性，假设函数不增：$$\begin{aligned}\int_{y}^{x}f(t)dt&=\int_{\lceil y\rceil}^{\lfloor x\rfloor}f(t)dt+\int_{y}^{\lceil y\rceil}f(t)dt+\int_{\lfloor x\rfloor}^{x}f(t)dt\\&\leq\sum_{n\in{\mathbb{Z}}:y\leq n\leq x-1}f(n)+\int_{y}^{\lceil y\rceil}f(t)dt+\int_{\lfloor x\rfloor}^{x}f(t)dt\\&\leq\sum_{n\in{\mathbb{Z}}:y\leq n\leq x}f(n)+\int_{y}^{\lceil y\rceil}f(t)dt\\&\leq\sum_{n\in{\mathbb{Z}}:y\leq n\leq x}f(n)+f(y)\end{aligned}$$反过来也有$$\int_{y}^{x}f(t)dt\geq\sum_{n\in{\mathbb{Z}}:y\leq n\leq x}f(n)+f(x)$$于是$$\sum_{n\in{\mathbb{Z}}:y\leq n\leq x}f(n)=\int_{y}^{x}f(t)dt+O\left(|f(x)|+|g(y)|\right)$$

> [!example] 例子1.1.1
> $f(t)=\log(t)$，那么:$$\sum_{1\leq n\le x}\log(n)=x\log(x)-x+O(\log(x+2))$$

但是**如果函数不是单调的而是震荡的，那么这个估计是不成立的**：

> [!example] 例子1.1.2
> $f(t):=|\cos(2\pi t)|$，那么和$$\sum_{y\leq n\le x}\cos(2\pi n)=O(x-y)$$可是如果无视"简单积分估计"对单调性的要求，直接根据上面的结果去强行做估计就会得出$O(1)$这样的错误的估计。

* [[两种不同路径解决含参数和的估计问题]]：在这个问题当中我们的目标是得到$$S_n:=\sum_{i\leq n}\frac{1}{n+\sqrt{i}}$$的精度为$o\left(\frac{1}{\sqrt{n}}\right)$的估计。$S_n$的被求和对象是函数$f_n(x):=\frac{1}{n+\sqrt{x}}$，这是一个随着$x$增加而单调减少的函数，并且其在$[1,n]$上的定积分是简单的，可以利用Taylor展开轻易得到估计。最后我们利用上述公式中余项的表达，得知简单积分估计下，余项精度符合$o\left(\frac{1}{\sqrt{n}}\right)$，于是简单积分估计得到$$S_n=1-\frac{2}{3}\frac{1}{\sqrt{n}}+o\left(\frac{1}{\sqrt{n}}\right)$$
#### 1.2 基于简单积分估计的收敛判别法

> [!note] 级数收敛的积分判别法
> 如果说被求和函数$f:[M,+\infty)\to\mathbb{R}$可积(或者说广义黎曼积分存在)，并且函数单调减少到0,并且函数的积分$$\int_{M}^{\infty}f(t)\,dt $$是收敛的积分。那么级数$$\sum_{n\geq M}f(n)$$也是收敛的，反之亦然。

因为:$$f(n)\geq f(t)>f(n+1),t\in [n,n+1)$$于是两边同时积分，然后求和可以得到:$$f(N)+....\geq\int_{N}^{+\infty}f(t)\,dt\geq f(N+1)+....$$如果定义级数的余项，$A_N:=\sum_{n\geq N}f(n)$以及$I_N:=\int_{N}^{+\infty}f(t)\,dt$于是，$$I_N\leq A_N\leq I_N+f(N)$$也就是说，如果$I_N\to 0$,即积分是收敛的，并且$f(N)\to0$那么级数也是收敛的。

#### 1.3 利用函数的凸性做简单积分估计

> [!note] 利用函数凸性的简单积分估计
> 简单的积分估计本质上是一种[[逐项估计]]，我们利用函数的单调性，然后把函数在整数处的取值放缩为函数在长度为1的区间上的积分。按照相同的思路，有时候我们也可以利用函数的凸性来把函数逐项放缩为长度为1的区间上的积分。
> 
> 其主要参考的命题为：
> 对于在区间$[a,b]$上凸的函数而言，对任意$x_1,x_2\in [a,b]$并且满足$x_1<x_2$都有$$\frac{f(x_1)+f(x_2)}{2}\geq \frac{1}{x_2-x_1}\int_{x_1}^{x_2} f(x)\,dx$$
> * 参考[[Hermite-Hadamard不等式与函数凸性]].
> 
> 那么对每个区间利用这样的结果进行放缩，我们得到$$\sum_{k=1}^{n-1} \frac{f(x_k)+f(x_{k+1})}{2}(x_{k+1}-x_k)\geq \int_{x_1}^{x_n}f(x)\,dx$$如果$x_k=k$那么以上结果可以等价于$$\sum_{k=1}^n f(k)\geq \frac{f(1)+f(n)}{2}+\int_{1}^{n}f(x)\,dx$$
> 
> ---
> 这种估计，对于单调凸函数而言是对和的下界估计的精度改进，这种改进不是本质的，误差级别不会变但是下界要比单纯利用单调性会好上一点。
> 
> 比如我们假设$f$是严格单调减少的，单纯利用单调性得到的下界估计是$$\sum_{k=1}^n f(k)\geq f(n)+\int_{1}^n f(x)\,dx$$相对于利用凸性得到的下界估计，由于严格单调减少性$$\frac{f(1)+f(n)}{2}\geq f(n)$$于是我们知道由凸性得到的下界估计会好上一些，但不本质。
> 
> 同样的道理，如果我们假设函数严格单调增加，那么单纯利用单调性得到的下界估计是$$\sum_{k=1}^n f(k)>f(1)+\int_{1}^n f(x)\,dx$$由于严格增加性，于是$$\frac{f(1)+f(n)}{2}\geq f(1)$$因此由凸性得到的下界估计会更好一些。

* 如果我们尝试估计$H_n:=\sum_{k=1}^n \frac{1}{k}$的下界，直接利用函数$f(x):=\frac{1}{x}$的单调性，我们得到$$H_n\geq \frac{1}{n}+\log(n)$$如果我们注意到这是一个单调减少的凸函数的话，我们会得到下界估计$$H_n\geq \frac{n+1}{2n}+\log(n)$$相较于精确的渐近结果$$H_n=\log(n)+\gamma +O\left(\frac{1}{n}\right)$$其中欧拉常数$\gamma \approx 0.577$。利用凸性得到的下界估计，至少证明了$H_n$的常数项是大于等于$\frac{1}{2}$的。相对于单纯利用单调性得到的估计会更好。 ^f34762
* [[对一个含参数的和的估计以及控制收敛定理#1.3 尝试3：改进简单的积分估计1]]：尝试利用单调性得到下界估计，但是下界的还差一点。于是就尝试利用凸性改进一下下界。


#### 1.4 未必能使用简单积分估计的情况

这里我们说的不是“例子1.1.2”当中的不满足单调性所以不能用的情况，而是满足所有条件，但是结果到不到预期的情况。这种情况具体来说可以分为:

---

积分真的是简单(或者至少是我们比较熟悉)的吗？

比如问题[[收敛的连乘积的上界估计与糖水不等式]]，[[部分积的上界估计与Gautschi不等式]]当中似乎被求和对象都是满足单调性的，是可以采取简单的积分估计的，但是其积分根本就不是一个简单的或者熟悉的结果，反而还需要对被积函数做放缩，那么为何不直接[[逐项估计]]?

---

另一种情况就是精度不足的时候。因为简单积分估计能提供的精度是有限的。

* [[Stirling渐近公式及不等式]]:在这个问题当中我们的最终目的是证明$$S_n:=\sum_{k\leq n}\log(k)=n\log(n)-n+\frac{1}{2}\log(n)+\log(\sqrt{2\pi})+O(1/n)$$但是如果考虑简单积分估计，我们能达到的精度的极限只有$O(\log(n))$，也就是说我们甚至不能知道渐近结果当中$\log(n)$的渐近系数，更别提渐近当中的常数项以及无穷小的项。因此针对于这种高精度的问题，我们需要更复杂更强力的工具。
* [[自然数的r次幂的部分和估计]]：这个问题当中我们要证明如果$r>0,r \neq 1$那么$$\sum_{k=1}^n k^{-r}=\zeta(r)+\frac{1}{1-r} n^{1-r}+\frac{1}{2} n^{-r}-\frac{r}{12} n^{-r-1}+O\left(n^{-r-3}\right)$$如果我们单纯利用简单积分估计，那么我们保证的精度只有$O(n^{-r+1})$，远远达不到我们要求的精度。



#### 1.5 更多的案例
* [[从一个光滑函数部分和的渐近问题开始]]：这个例子为什么适合积分估计？因为积分确实够简单，一下子就能找到原函数$$\int_{1}^{n+1} \frac{1}{\sqrt{n^2+t}}\,dt=2\sqrt{n^2+n+1}-2\sqrt{n^2+1}$$这个例子当中1的部分就是想要说明，如果我们直接用简单估计的误差上限的结果，然后在进行计算之前，带入误差公式发现误差上限直接就能满足我们的问题对精度的要求，那么这说明简单估计一定能成功。但是反过来，如果达不到要求，也未必一定不能成功。因为简单积分估计的误差是误差上限估计，而不是下限。
* [[一个竞赛中的和的渐近展开问题#2.1 简单积分估计]]：其中的做法，采用了简单的积分估计。因为首先，单调性满足，其次积分也的确不困难，最后根据误差公式，其误差也是符合要求的。
* [[Etemadi关于强大数定律的证明#1. 对问题的简化]]：当中第一节中的简化命题中，我们需要证明$P(Y_i\neq X_i \text{ i.o.})=0$。其中$Y_i=X_i1_{|X_i|\leq i}$是对$X_i$的一个截断。这等价于证明级数$\sum_{i\geq 1} P(|X_i|>i)$是收敛的。此处的关键是使用简单的积分估计。具体地，首先注意到被求和对象$P(|X_i|>i)$是单调减少的。其次其积分是简单的，或者说对我们而言熟悉的，因为我们事先知道$$\int_{0}^{\infty}P(|X_1|>t)\,dt= E(|X_1|) <\infty$$
* [[证明一个部分和被一个参数控制起来]]：当中我们需要证明当$\lambda>1$的时候$$S_N:=\sum_{n\leq N}\frac{1}{(n+1)n^{\frac{1}{\lambda}}}<\lambda$$一开始考虑逐项估计，发现可以放缩成我们相对熟悉的对象$\frac{1}{n^{\frac{1}{\lambda}+1}}$的和。这个和我们相对熟悉是因为它的积分简单，适合做积分估计，最后的结果当然也表明，积分放缩的精度是满足问题需求的。


### 2.如果函数是光滑的，那么则有更好的估计，即Euler-Maclaurin求和估计

如果函数是光滑的，那么估计可以更精确一些(Euler-Maclaurin)：

> [!note] Euler-Maclaurin求和估计
> 1.  整数的情况:(这里面主要是奇数的Bernoulli数是0，所以可以消去)$$\sum_{k=m}^{n}f(k)=\int_{m}^{n}f(t)dt+\frac{f(m)+f(n)}{2}+\sum_{r=1}^{\lfloor p/2\rfloor}\frac{B_{2r}}{(2r)!}\left(f^{(2r-1)}(n)-f^{(2r-1)}(m)\right)+\frac{(-1)^{p+1}}{p!}\int_{m}^{n}B_{p}(\{t\})f^{(p)}(t)dt$$
> 2.  更一般的情况：$$\sum_{y<k\leq x}f(k)=\int_{y}^{x}f(t)dt+\sum_{k=1}^{p}\frac{(-1)^k}{k}\left(B_k(\{x\})f^{(k-1)}(x)-B_k(\{y\})f^{(k-1)}(y)\right)+\frac{(-1)^{p+1}}{p!}\int_{y}^{x}B_{p}(\{t\})f^{(p)}(t)dt$$
> 3. 最简单的情形:$$\begin{aligned}\sum_{y<k\leq x}f(k)&=\int_{y}^{x}f(t)dt-\left(B_1(\{x\})f(x)-B_1(\{y\})f(y)\right)+\int_{y}^{x}B_1(\{t\})f'(t)dt\\&=\int_{y}^{x}f(t)dt-\{x\}f(x)+\{y\}f(y)+\int_{y}^{x}\{t\}f'(t)dt\end{aligned}$$

* **关于一个单位周期内Bernoulli多项式的估计**:


> [!note] 一个周期内Bernoulli多项式的估计
> $$|B_{p}(\{t\})|\leq \frac{2p!}{(2\pi)^p}\zeta(p)$$

使用得较为频繁的有:
$$B_1(x)=x-1/2,B_2(x)=x^2-x+1/6$$
使用上面的结果可以得到估计:
$$|B_{1}(\{t\})|\leq 1/2,|B_{2}(\{t\})|\leq 1/6$$
#### 2.1 E-U求和估计的一些案例


* [[黎曼积分与黎曼和的误差]]：在这个问题当中我们需要得到$$R_n:=\int_0^1f(t)\,\mathrm{d}t-\frac1n\sum_{k=0}^{n-1}f(k/n)$$的精度至少为$O(1/n^2)$的估计。我们换一个角度，从$\frac1n\sum_{k=0}^{n-1}f(k/n) \to\int_0^1f(t)\,\mathrm{d}t$切入问题，那么问题可以视为一个针对与含参数的和$$S_n:=\frac1n\sum_{k=0}^{n-1}f(k/n)$$的估计。于是我们令$g_n(k):=f(k/n)$，运用二阶的Euler-Maclaurin求和公式我们得到$$\begin{aligned}\sum_{k=0}^{n-1}g_n(t)&=\int_{0}^{n-1}g_n(t)\,dt+\frac{g_n(0)+g_n(n-1)}{2}\\&+\frac{g_n'(0)-g_n'(n-1)}{12}-\frac{1}{2}\int_{1}^{n-1}B_{2}(\{t\})g_n^{''}(t)\,dt\end{aligned}$$对这个结果做一些简单的换元以及逐项估计以及最后余项考虑Riemann-Lebesgue引理便可得到最终结果。
* [[由Euler-Maclaurin求和估计得到Stirling逼近结果]]：当中利用Euler-Maclaurin求和估计得到了$\sum_{1\leq k\leq n}\log(k)$的渐近估计，不过这个工具的一个缺点也暴露出来，渐近式子当中会存在一个常数项，虽然我们可以通过带Bernoulli多项式的一个积分去表达这个常数，比如此处$$C=1+\frac{1}{3}\int_{1}^{+\infty}B_{3}(\{t\})\frac{1}{t^3}dt-\frac{1}{12}$$不过这个积分估计其大小的时候并不方便，于是这里例子里面我们采用别的方法，例如Wallis公式得到了这个常数的一个紧凑的表达方式:$$C=\log\left(\sqrt{2\pi}\right)$$
* [[对部分和渐近展开的常数项做估计]]：当中我们用类似的方法得到了常数项的表达$$\begin{aligned}C&=2\log(2)-2\text{arcsinh}(1)+\frac{9}{16\sqrt{2}}-\frac{A}{6}\end{aligned}$$其中$A=\int_{1}^{\infty}B_3(\{t\})f^{(3)}(t)\,dt$,这里没有得到$A$的Closed form的表达，不过可以借助对Bernoulli多项式的在一个周期里面的上界估计来完成对其的一个估计。
* [[自然数的r次幂的部分和估计]]：当中也是利用Euler-Maclaurin求和估计去估计形如$\sum_{k=1}^n k^{-r},r\in\mathbb{R}$的和。其中我们又会发现一些得到渐近展开常数项的经验：
1. 当$\sum_{k=1}^n k^{-r}$收敛的时候，比如$r>1$的时候，我们可以利用绝对收敛的级数$\sum_{k=1}^{\infty} k^{-r}=\zeta(r)$去得到渐近展开的常数项。也就是说，我们完全可以把对$\sum_{k\leq n} k^{-r}$的渐近展开，通过$$\sum_{k\geq 1}-\sum_{k>n}$$的方式转换为对$\sum_{k>n}k^{-r}$的渐近展开。
2. 当$\sum_{k=1}^n k^{-r}$不绝对收敛的时候，比如$r<1$的时候，我们是通过对$r>1$的时候涉及的$\zeta(s)$的解析延拓完成的。


### 3. 连续的部分和估计

> [!note] 连续版本的分部求和
> 1.  假设我们要估计一个求和函数:$$S(x):=\sum_{y<n\leq x}g(n)f(n)$$其中$f:[y,x]\to\mathbb{C}$是一个连续可微的函数，而$g:\mathbb{N}\to\mathbb{C}$只要求是一个算术函数。
> 2.  如果我们可以对其中的算术函数的部分，给出一个求和估计，并且这个求和估计"还不错".$$A(x):=\sum_{n\leq x}g(n)$$
> 3.  于是我们可以尝试下面的分部求和公式，试着让原来的$S(x)$有一个更简单的形式：$$S(x)=\sum_{y<n\leq x}g(n)f(n)=A(x)f(x)-A(y)f(y)-\int_{y}^{x}A(t)f'(t)dt$$
> 
> 这样做的好处是，因为$A(x)$的估计还不错，所以最后的积分的估计"理应也还可以"，从而导致最后求和的估计会比原来的表达更简单一些。


#### 3.1 一些具体的案例

* **把一个复杂的求和问题分解为简单的求和估计问题:**
这是分部求和的一个用法。虽然我们可以直接对一个被求和对象使用Euler-Maclaurin求和公式，但是如果被求和对象比较复杂，不管是做积分估计还是求导数都比较复杂。不过如果我们已经知道其中一个部分的结果，那么就可以利用已知的结果来完成这件事。

1. [[连续分部求和法的基本用法#1. 问题1]]:其中，由于被求和对象两个组成部分都是可微的。因此理论上我们任选一个做分部求和都是可以的，但其实也是有差别的。选的好才能发挥分部求和的优势，如果选的不好，比如笔记中展示的选择$$B(x)=\sum_{n\leq x}\log(n)$$作为已知的求和。那么最后还不如直接使用Euler-Maclaurin求和更直接。
* **被求和函数只有部分是可微的**：
这种情况下如果使用Euler-Maclaurin求和是不满足条件的。选择分部求和法，只有一种选择，那就是先估计出不可微的那部分的求和，然后利用分部求和法。
1. [[连续分部求和法的基本用法#2. 问题2]]:其中，我们只知道其中一个部分是可微的，而另外一部分的求和估计我们是知道的。那么这个时候就没得选。

