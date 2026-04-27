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
> [!tip] 底乘以高
> 1. **积分版本(上界)**:在测度空间$(X,\mathcal{F},\mu)$上的某个有限测度的集合$E$上对上界为$M$的函数$f$求积分，那么一个非常粗略的积分估计就是$$\left|\int_{E}f\,d\mu\right|\leq \int_{E}\left|f\right|\,d\mu\leq M\mu(E)$$
> 2. **积分版本(下界)**:在测度空间$(X,\mathcal{F},\mu)$上的某个有限测度的集合$E$上对有下界为$M$的非负函数$f$求积分，那么一个非常粗略的积分估计就是$$\int_{E}f\,d\mu \geq M\mu(E)$$
> 3. **求和版本**: 如果被求和函数$a_n$在整数的某个有限子集$E$上求和，并且有上界$M$，那么$$\left|\sum_{n\in E} a_n \right| \leq M |E| $$实际上求和版本不过是把积分版本的测度换成了特殊的counting measure.于是同样的如果被求和是非负的对象，那么也有类似的下界估计。

这当然是一个非常粗糙的估计，但也是很多估计的思路的出发点。

我们的想法非常简单，根据"误差 = 底 $\times$ 高"的想法，我们**如果想要更高的估计精度**，那么就**给更"长"的底分配更“矮”的高，给更"短"的底分配更"高"的高**，如此一来整体误差就能变小。

下面这个算术题目能给我们足够的启发，以帮助我们理解。

> [!example] 例子1：一个比喻
> 现在有两组数$\text{B}:=\{1,2,3\},\text{H}:=\{4,5,6\}$,我们现在需要给$A,B$这两个集合一个排序，使得形成一个序列$b_1,b_2,b_3$以及$h_1,h_2,h_3$使得$$b_1h_1+b_2h_2+b_3h_3$$最小。

我们这里把“底”比作集合B,而"高"比作集合A,那么最后的那个需要最小化的求和实际上就是"误差 = 底 $\times$ 高"。为了使得它最小化，我们需要给最大的b,配备最小的h,最小的b配备最大的h.其实这就是排序不等式的结果。

那么如何实现这种"错位"的配对呢？**分段估计**。
### 1. 简单分段估计

#### 1.1 赋范数空间上的简单分段

> [!tip] 简单分段估计的抽象
> 1. 我们要对一个积分$\int_{E}f\,d\mu$做估计，但是直接用"底乘高"即$\mu(E)M$太粗糙了，基本很难得到有价值的结果。
> 2. 我们发现$f$在集合$E$的两个子集$E_1,E_2$上有两种不同的特性出现，为了让估计误差更小，于是做$$\int_{E}\left|f\right|\,d\mu \leq \int_{E_1}\left|f\right|\,d\mu +\int_{E_2}\left|f\right|\,d\mu $$这样的分段处理。我们会对每一段用针对性的手法进行估计，也就是所谓的"**分而治之**"。

函数列的积分(和)也会用到分段估计

> [!tip] 分段估计在函数收敛上的运用
> 如果我们想要估计$\int_E |f_n(x)|\,d\mu(x)$的上界,然后我们发现当$x\in E_n$的时候，$|f_n(x)|<M_n$(当然$M_n$也可能是一个常数),而剩下的部分又可以很好的被控制起来，那么此时可以尝试用分段估计提升估计精度。
> 1. 如果$f_n$是$L^p$的序列，那么$$\begin{aligned}\int_E |f_n(x)|\,d\mu(x)&\leq \int_{E_n}*+\int_{E\setminus E_n}* \\ &\leq M_n\mu(E)+\frac{||f_n||_{L^p}}{M_n^p}\end{aligned}$$
> 2. 如果$|f_n|<M$是有界的函数列，那么尾部也可以用有界性结合$\mu(E\setminus E_n)$来控制。


例子:
* [[证明一个由变上限含参数积分给出的函数列一致收敛]]：一个典型的例子，我们需要估计$f_n(x):=\int_{0}^{x}f(t^n)\,dt,x\in [0,1],n\geq 1$与极限函数$f(0)x$之间的一致范数。考虑到$f$是单位闭区间$[0,1]$上一致连续的函数，因此采取分段估计。
* [[用分段估计解决几个序列的极限问题]]：这里是典型的具有代表性的，考虑和的分段估计的问题。题目中无非就是利用序列例如$x_k \to A$这一点，也就是在$k>N_{\varepsilon}$的所谓尾部$|x_k-A|<\varepsilon$成立。于是显然我们需要把问题分为，尾部以及剩余部分两个部分，然后对两个部分做针对性的估计。同样类似的问题还有[[Silverman–Toeplitz定理]]。
* [[对误差的分析从而改进分段估计#3. 和的积分估计]]：第三节当中，我们需要估计含参数积分$$\int_{\frac{\log(n)}{n}}^{\frac{\log(n)}{2}}\frac{e^t}{t^2}\,dt$$我们发现被积分函数在靠近区间两个端点处的行为非常不一样，那么这个时候就非常有必要区别对待靠近左右端点处的估计，这样才能让误差尽可能地小。在实际的操作中，我们对于$[1,\frac{\log(n)}{2}]$这一段，采用的是简单的逐项估计。而在$[\frac{\log(n)}{n},1)$这一段当中则是采用更为精细的基于Taylor展开的逐项估计。
* [[体现积分估计相较于和的估计优势的一个问题]]:在这个问题当中，我们最终是要估计$$I_n:=\int_{3}^n n^{\frac{1}{\log_2x}}\,dx$$这样一个含参数的积分。通过换元法，我们发现被积函数可以写成我们想要的估计形式。但是这种展开需要满足$\frac{t}{\log(n)}<c<1$才能成立。于是分段估计就是必要的操作了。
* [[黎曼可积的Lebesgue判别#2. 如果函数几乎处处连续，那么黎曼可积]]:其中，我们需要证明当函数几乎处处连续的时候，函数黎曼可积，即对于任意的$\varepsilon$我们都可以找到划分$P_{\varepsilon}$使得$U(f,P_{\varepsilon})-L(f,P_{\varepsilon})<\varepsilon$。很快我们就会发现，我们有必要分开处理两个部分，因为如果一个划分包含$C_r$那么此区间上区间长度的总和可以任意小，但如果此区间不包含任何$C_r$当中的元素，那么情况又会不同，这些区间上函数的振幅可以非常小。所以分段估计$U(f,P_{\varepsilon})-L(f,P_{\varepsilon})$这个和是非常必要的。
* [[Weierstrass逼近定理的概率途径证明#2.2 这样做的本质是什么?]]：当中，我们需要估计$$\int_{\Omega}|f(p)-f(Y_n)|\,dP $$并证明这个积分为关于n的无穷小。而我们已经知道$Y_n \xrightarrow{P}{p}$,以及函数$f$的一致连续性。在这个问题当中我们把$\Omega$一分为二，$$\Omega_1:=\{\omega:|Y_n(\omega)-p|<\delta_{\varepsilon}\}$$以及$$\Omega_2:=\{\omega:|Y_n(\omega)-p|\geq \delta_{\varepsilon}\}$$在第一段里面，"高度"非常小，同时"底部"是有限测度的。而第二段里面，“高度”虽然很大但是"底部"很小呀！这样互相抵消之下，最后整体的误差就很小了。
* [[样本期望的渐近展开系数]]：其中“lemma1”当中我们需要估计$$\int_{\Omega} R(\overline{X}_n,\overline{Y}_n)\,dP$$其中$R(x)$是一个二元函数，其满足当$\sqrt{(x-1/2)^2+(y-1/3)^2}<\delta$的时候$$R(x,y)=o\left[\left(x - \frac{1}{2}\right)^2 +\left(y - \frac{1}{3}\right)^2 \right]$$此外随机变量$\overline{X}_n,\overline{Y}_n$分别依测度收敛到$1/2,1/3$.于是这里的分段估计的意味就非常明显了，这就如同上一个例子当中的“一致连续性”。即第一段利用问题本身的特性，剩下不满足问题本身特性的部分，恰好被随机变量依概率收敛给控制起来。估计不满足问题条件的集合的概率测度由类似于Chebyshev的不等式估计，不过此处用的是Hoeffding不等式。
* [[approximation to the identity#1. $L 1( mathbb{R} d)$当中的逼近单位的常用结论]]中关于逼近单位元的三个基本结论中，三个结论的证明方法都类似。基本都需要处理$$\int ||T_y\circ f-f||_{L^p}\cdot|K_{\lambda}(y)|\,dy = \int_{|y|<\delta_\varepsilon}*\,\,dy+ \int_{|y|\geq \delta_\varepsilon}*\,\,dy $$这样一个估计，其中分段的原因是因为对于逼近单位元而言，其"高度"最高的部分主要是集中在$y=0$附近，而$|y|$越大其高度在积分的意义下就越是小。于是很自然的会考虑这种两段式的分段处理。
* [[approximation to the identity#1. $L 1( mathbb{R} d)$当中的逼近单位的常用结论]]：当中关于逼近单位元的三个基本结论中，我们都需要估计$\int ||T_y\circ f-f||_{L^p}\cdot|K_{\lambda}(y)|\,dy$，我们发现第一段因为$T_y\circ f$在$y=0$处的连续性，因此估计不错。第二段可以利用逼近单位元的尾部的性质做针对性的估计。

对于下界估计，假设$f$是非负$E$上可积的函数，于是同样有:
$$\int_E f\,d\mu\geq \int_{E_1}f\,d\mu+\int_{E_2}f\,d\mu $$
此时如果我们可以找到一个合适的集合$E_1$使得$f$的值基本集中在$E_1$当中，那么我们可以在不让误差显著增加的情况下去掉后面的部分。特别是在考虑积分的极限的下界估计中，比如当我们发现一个非负函数在极限过程中其值集中在$E_{r}:=\{x:f(x)\geq r\}$当中，那么就可以用估计$$\int_E f\,d\mu  \geq \int_{E_r}f\,d\mu\geq \mu(E_r)r$$
此时如果我们已经知道$\mu(E_r)$的估计，那么在极限问题中，这个估计也许就能达求积分极限的下界估计的目的。例如:

* [[函数p范数与无穷范数之间的关系]]：当中，我们需要求$||f||_{L^p}$的下界估计，从而让我们了解当$p\to \infty$的时候的范数的极限行为。根据无穷范数的定义，对任意的$\varepsilon >0$都存在一个$\delta_{\varepsilon}>0$有:$$\mu\left(\left\{x:|f(x)| >\|f\|_{L^{\infty}} -\varepsilon\right\}\right)\geq\delta_{\varepsilon}$$于是我们相当于知道$\left\{x:|f(x)| >\|f\|_{L^{\infty}} -\varepsilon\right\}$这个集合的测度的下界估计，因此可以采取上面的策略得到p范数的下界估计$$\int|f|^pd\mu \geq \delta_{\varepsilon}
(\|f\|_{L^{\infty}} -
\varepsilon)^p$$这样的估计对于此处分析p范数的极限行为是合适的，因为$$\liminf_{p \to \infty} ||f||_p \geq
\|f\|_{L^{\infty}} - \varepsilon,\forall \varepsilon
>0$$
* [[由一个级数收敛证明另一个有关级数的收敛问题#1. 问题1]]：我们已知$\sum_{n=1}^{N}nx_n=O(1)$需要说明$\sum_{n=1}^{N}x_n\log(1/x_n)=O(1)$。那么如果我们假设二者其实是有一定的关系的，或者说按照[[利用已知的渐近结果求渐近展开的技巧]]中的想法，我们假设二者是某种相似的结构然后想要得到差的估计的上界估计:$$\sum_{n\leq N}|nx_n-x_n\log(1/x_n)|=O(1)$$如果这一点可以达成，那么问题其实就结束了。而上面的结果是可以用分段估计去做的。我们想到可以把$[1,N]\cap \mathbb{Z}$这个集合分成两个部分，分别是$|nx_n-x_n\log(1/x_n)|\leq nx_n$以及剩下的部分。前者肯定是可以被$O(1)$控制起来的，而后者会被$ne^{-n}$控制起来，因此问题便解决了。

#### 1.2 分布函数的简单分段估计

> [!note] 此上下文中分布函数的定义
> $(X,\mathcal{F},\mu)$是一个测度空间,$f:X\to \mathbb{C}$是一个$(\mathcal{F},\mathcal{B}(\mathbb{C}))$的可测函数,也就是$\mathcal{B}(\mathbb{C})$当中元素关于映射$f$的原像是$\mathcal{F}$当中的元素。定义$$\lambda_f(a):=\mu(\{x:|f(x)| >a\})$$

当我们的问题可以归结为对这样的分布函数做估计的时候，我们有时候可以利用分布函数的一些性质：

> [!note] 这种分布函数的基本性质
> 1. $\lambda_f$是一个单调减少并且右连续的函数。
> 2. 如果$|f|\leq |g|$那么$\lambda_f \leq \lambda_g$
> 3. 如果$|f_n|\uparrow |f|$那么$\lambda_{f_n}\uparrow \lambda_f$
> 4. 如果$f = g+h$那么$\lambda_f(a)\leq \lambda_g(a/2)+\lambda_h(a/2)$
> 5. 如果$f = gh$那么$\lambda_f(a)\leq \lambda_g(\sqrt{a/2})+\lambda_h(\sqrt{a/2})$

利用这些性质我们可以实施对分布函数的分段估计。

* [[弱大数定律]]当中，我们需要证明$$\lambda_{\frac{S_n}{n}}(\varepsilon):=P\left(\left\{\omega:\left|\frac{S_n(\omega)}{n}\right|\geq \varepsilon\right\}\right)=o(1)$$其中$S_n:=X_1+\cdots+X_n$，$\{X_n\}$是一列独立同分布的，绝对可积的，期望为0的随机变量。我们通过"截断"随机变量的方式，使得$$X=X_{\leq M}+X_{>M}$$这样我们就令$S_{n,1}=\sum_{i\leq n}X_{i,\leq M},S_{n,2}=\sum_{i\leq n}X_{i,> M}$于是可以对分布函数做分段估计$$\lambda_{\frac{S_n}{n}}(\varepsilon)\leq \lambda_{\frac{S_{n,1}}{n}}(\varepsilon/2)+\lambda_{\frac{S_{n,2}}{n}}(\varepsilon/2)$$而前者可以用二次矩版本的Chebyshev不等式控制，后者则可以用一次矩版本的Chebyshev不等式结合控制收敛定理控制。

#### 1.3 分段从而控制住求和（求积分）变量

> [!tip] 想法1.3.1
> 在一个和（或积分）的估计$\sum_I X$当中，当我们考虑[[逐项估计]]的时候，我们想象一个底乘以高的模型。此时如果我们想要改进逐项估计的精度，但是又发现我们不能改善“高”也就是$X$的估计，那么我们还可以考虑改善底，也就是做一个分段估计。

下面我们看一个玩具模型：

> [!example] 例子1.3.2(一个玩具模型)
> 假设我们现在要估计和$S_N:=\sum_{N<n\leq N^2}\frac{1}{n^2+1}$。当然和的积分估计可以告诉我们$S_N \asymp \frac{1}{N}$。但这里我们假装不知道这个做法，我就就是要用逐项估计来解决问题。于是我们想到当$N<n\leq N^2$的时候有$$\frac{1}{n^2+1}<\frac{1}{N^2}$$于是直接逐项估计我们得到$$S_N<\frac{1}{N^2}\times (N^2-N)=1-\frac{1}{N}=O(1)$$我们带着答案去审视这个估计就会发现，这个估计距离真正理想的结果差太远了，它甚至不是一个无穷小量。于是我们引入分段估计来着手改造它，我们可以引入一个$(N,N^2] \cap \mathbb{N}$的分段点，比如$N^{3/2}$好了。那么此时我们结合分段估计，再来做一次逐项估计就会得到$$\begin{aligned}S_N&:=\sum_{N<n\leq N^2}\frac{1}{n^2+1}\\&= \sum_{N<n\leq N^{3/2}}\frac{1}{n^2+1}+\sum_{N^{3/2}<n\leq N^{2}}\frac{1}{n^2+1}\\&<\frac{1}{N^2}\times (N^{3/2}-N)+\frac{1}{N^3}\times \left(N^2-N^{3/2}\right)\\&= \frac{1}{\sqrt{N}}-\frac{1}{N^{3/2}}=O\left(\frac{1}{\sqrt{N}}\right)\end{aligned}$$虽然如果对比“标准答案”这个精度还是有很大差距，但是的确比直接进行逐项估计改善了很多精度。**在很多真正的问题（并非玩具模型）当中，我们可能没有一个类似于“和的积分估计”相对于该例子这样的如此理想的工具，但是我们依旧可以通过选择合适的断点来一定程度上优化估计精度。**


下面是一些具体的例子：

* [[对误差的分析从而改进分段估计]]：在这个问题当中我们需要估计$$S_n:=\sum_{k\leq n}n^{1/k}$$最低精度要求是$o(n)$。在逐项估计的“高”也就是$n^{1/k}$的上界，难以优化的假设下，我们想到用分段估计来优化逐项估计的"底"。具体来说，我们通过误差分析，发现形如$$S_n=n+\sum_{2\leq k\leq n}n^{1/k}=\sum_{2\leq k<n^{1/3}}n^{1/k}+\sum_{n^{1/3}\leq k\leq n}n^{1/k}$$的拆分就能实现我们的估计目标。
* [[Dirichlet's hyperbola trick]]:这个方法当中我们需要估计双重求和$$F(x):=\sum_{\begin{aligned}q,d&\leq x\\qd&\leq x \end{aligned}}g(d)h(q)$$同样因为算术函数局部性质复杂从而难以有很好的对“高”的估计。于是为了精度，以及把双重求和变成累次求和的需求，我们用一个$1\ll y\ll x$来对和进行分段估计，得到$$\begin{aligned}F(x)&= \sum_{\begin{aligned}q,d&\leq x\\qd&\leq x \end{aligned}}g(d)h(q)\\&= \sum_{d\leq y}\sum_{q\leq x/d}g(d)h(q)+\sum_{q\leq \frac{x}{y}}\sum_{d\leq x/q}g(d)h(q)-\sum_{d\leq y}\sum_{q\leq \frac{x}{y}}g(d)h(q) \end{aligned}$$这样做了以后，逐项估计当中的“底”就从$x$变成了远小于$x$的$y$或者$\frac{x}{y}$。例如Dirichlet在估计divosor function的和的时候（参考[[对算术函数平均值的渐近#2. Divisor sum function]]就令$y=\sqrt{x}$，从而在估计的时候底变成了更小的$\sqrt{x}$从而减少了估计误差。


另外一种情况是：

> [!tip] 想法1.3.2
> 当我们对一个和或者积分做逐项估计的时候我们发现其余项并不能得到统一的控制。那么这个时候一个很自然的想法就出现了：我们把变量所在的集合或者区间进行划分（或截断），从而使得至少其中一部分的余项可以被统一地控制，剩下那部分我们再想别的办法。

* [[求一个分子带log分母为阶乘的含参数和的渐近展开]]:在这个问题当中我们需要对$T_n:=\sum_{k \geq 0} \frac{\log(1+\frac{(-2)^k}{n})}{k!}$进行精度为$o(1/n)$的估计。我们首先想到借助$\log(1+x)$的Taylor展开，这样可以对$T_n$做一个逐项估计。但是很快我们发现并非所有$k$都能使得$\log(1+(-2)^k/n)$的余项被统一地控制起来，于是我们想到了进行分段估计。为了使得$\log(1+x)$的余项得到统一控制，我们用$t_n:=\log_2(n)$对$k$进行截断，使得$$T_n=\sum_{k< t_n} +\sum_{k\geq t_n}$$然后前半段我们用$\log(1+x)$的Taylor展开做逐项估计，后半段我们只需要用最简单的逐项估计便可轻松达到$o(1/n)$的精度。
* [[对含参数方程根的估计#1. 从隐函数的渐近展开切入]]：在这个问题当中我们需要估计和$$A(s):=\sum_{k=1}^{N(s)-1}\frac{1}{x_kx_{k+1}}$$其中$x_k(s)$是含参数的方程$\cos(x)=sx$的从小到大排列的第$k$个根，$N(s)$是总共的正根的数量。在这个问题的第一种做法当中，我们通过隐函数定理得到了方程的根的渐近$$x_k(s)=x_k(0)+x_k'(\xi_{k,s})s,x_k'(t)=-\frac{x_k(t)}{\sin(x_k(t))+t}$$要估计和$A(s)$，我们希望$|x_k'(t)|$有一个可以被较好控制起来的上界。但是我们发现，当$k$接近$N(s)$的时候$|x_k'(t)|$不能被很好地控制。于是我们想到把求和变量$k$限制在一个更小的范围内，从而强行控制住$|x_k'(t)|$。于是我们便有了一个分段估计的计划，令$k\leq N(s)^{2/3}$从而在这一段中实现$|x_k'(t)|<Ck$从而$$x_k(s)=x_k(0)+O(ks)$$至于剩下的一部分，我们可以用$x_k(s)$的一个粗糙估计来完成。

#### 1.4 在奇点附近分段

> [!tip] 想法1.4.1
> 这种一般出现在含参数的和或者积分的估计问题当中，特别是需要求含参数和或者积分的极限的问题。假设$$I_n:=\int_E f_n(x)\,dx$$然后$f_n(x)$在$E$上存在一个奇点$x_0\in E$，其余部分$f_n$有界，并且除去奇点以外$f_n(x)\to 0$。也就是说，这个含参数的积分的极限基本由$f_n$在奇点附近的行为决定。于是这个时候我们可以通过对$E$进行划分$$E=U(x_0)\cup (E\setminus U(x_0))$$于是积分估计变成估计$$I_n=\int_{E\setminus U(x_0)}+\int_{U(x_0)}$$两部分。两部分我们需要用不同的方式去估计，从而使得精度尽可能提高。

* [[关于含参数积分估计的玩具模型#3. 分段估计]]:在这个问题当中我们需要估计$$I_n:= \int_{0}^{1}\frac{x^n}{1+x}\,dx$$要求最低的估计精度为$o(1/n)$。之所以采用分段估计，是认识到对于任意的$\varepsilon>0$，积分$$n\int_{0}^{1-\varepsilon} \frac{x^n}{1+x}\,dx \to 0$$这是有界收敛定理告诉我们的。这也就意味着，整个$nI_n$大部分的值实际上都集中在靠近于$1$的部分。因此这两部分我们分开处理也是一种自然的想法。我们的计划是考虑一个$1-\varphi(n)$其中$\varphi(n)\to 0$此时：$$nI_n=\int_0^{1-\varphi(n)}\frac{nx^n}{1+x}\,dx+\int_{1-\varphi(n)}^{1} \frac{nx^n}{1+x}\,dx$$我们对这两段用不同的方法进行估计。第一段只需要最简单的逐项估计，而第二段则需要用到基于Taylor展开的逐项估计，最终我们便能得到$I_n$的精度为$O(1/n^2)$级别误差的估计。当然如果我们只需要$o(1/n)$级别的误差，我们只需要分段为$$nI_n = \int_{0}^{1-\varepsilon} \frac{nx^n}{1+x}\,dx +\int_{1-\varepsilon}^1 \frac{nx^n}{1+x}\,dx$$就可以了。其中第一段由于有界收敛所以为$o(1)$，我们只需要估计第二段并得到$\frac{1}{2}+o(1)$的结果即可。当然因为这样牺牲了精度，估计所需要克服的困难也下降许多。（一般初等分析的考试中，这种精度的问题更为常见，要求得到$O(1/n^2)$这种精确的余项的情况较为少见。）

### 2. 可数分段

> [!tip] 对可数分段的表述
> 所谓可数分段其实就是分组求和。假设我们可以把求和或者积分的集合$X$表示为可数个不相交的子集的并，即$$X=\bigcup_{k\geq 1}A_k$$然后我们考虑基于$A_k$的分组求和/求积分：
> 1. 如果是测度$\mu$上的积分，我们可以理解为$$\int_X f(x)\,d\mu(x)=\sum_{k\geq 1}\int_{A_k}f(x)\,d\mu(x)$$
> 2. 如果是$\mathbb{N}$上的求和，那么我们可以理解为$$\sum_{n\geq 1}f(n)=\sum_{k\geq 1}\sum_{n\in A_k}f(k)$$
> 同时，还要求$\int_{A_k}f(x)\,d\mu(x),\sum_{n\in A_k}f(k)$比原来的对象明显更好处理，更容易做估计。那么把问题转换为后者去考虑，则称之为“基于$f$的可数分段的估计”。

* 为什么一定需要保证$\int_{A_k}f(x)\,d\mu(x),\sum_{n\in A_k}f(k)$比原来的对象明显更好处理，更容易做估计?否则的话，对于和$\sum_n f(n)$而言我们可以把自然数写成是单点集的可数并，那么这种情况下$a_k=f(k),|A_k|=1$,相当于没有做任何处理。
* 显而易见，周期函数立刻就能显现出可数分段。因为按照其周期进行分段，使得函数在每个周期内取值都一样，这样很容易使得分组以后的求和/积分比原来要好处理得多。即便被求和/积分的对象并不完全是周期函数，而是其中一部分是周期函数，那么也可以考虑基于周期的分段。至少函数的其中一部分的值会找每个周期内呈现一样的值的分布，多少也能简化整个被求和/积分的对象。比如说$$\int_{n}^{+\infty}B_{3}(\{t\})\frac{1}{t^3}$$其中$B_3(\{t\})$是一个周期为$1$的函数，但是$\frac{1}{t^3}$却不是，不过至少每个周期里面$B_3(\{t\})$的值是一样的，所以考虑按周期分段依旧是“有利可图”的。
* 带有$(-1)^n$的级数，例如$\sum_n \frac{(-1)^n}{n}$或者$\sum_n \frac{(-1)^n}{\sqrt{n}+(-1)^n}$，如果相邻两项凑成一组的方式重新求和，可能会比原来要好处理很多，往往新的求和其中主要的部分的被求和对象是不变号的。比如如果$\frac{(-1)^n}{n}$的奇数和偶数凑一起再求和，那么级数就变成了$\sum_k \frac{1}{2k(2k-1)}$果然好处理很多。当然[[基于分部求和法的和的估计]]也是一种常用的处理方法。
* 带有$\lfloor x\rfloor$的级数，至少在$[x,x+1)$里面，被求和对象/积分当中某个部分是不变的。比如级数$\sum_n (-1)^{{\lfloor\sqrt{n}\rfloor}}\frac{1}{n}$,至少在$[k^2,(k+1)^2)\cap \mathbb{Z}$当中，$(-1)^{{\lfloor\sqrt{n}\rfloor}}\frac{1}{n}$的值是不会变号的。


1. [[分部求和的想法，Dirichlet-Abel收敛判别法的推广#例子4 $ sum_{n geq1} frac{(-1) { lfloor sqrt{n} rfloor}}{n}$收敛]]：其中，为了利用分部求和以使用推广的Dirichlet-Abel判别，我们需要估计$$B_N=\sum_{n\leq N}
  (-1)^{\lfloor\sqrt{n}\rfloor}$$其中的floor函数导致当n介于两个平方数之间$[k^2,(k+1)^2-1]$的时候，被求和对象会简单很多，得到$$B_N=\sum_{k\leq
  \lfloor\sqrt{N+1}\rfloor-1} (-1)^k(2k+1)+ O(\sqrt{N})$$接下来的估计就比较容易了。
2. [[Dirichlet核不是逼近单位，Fejer核是逼近单位元#1. Dirichlet核并非逼近单位元]]：其中我们需要估计$$\int_{0}^{\pi}\frac{\left|\sin\left((N+\frac{1}{2})x\right)\right|}{x}dx$$的下界。这是典型的被积分对象里面含有周期函数，因此通过换元然后按照周期进行可数分段。这个问题里面我们通过换元法，把积分转换为了$$\int_{0}^{(N+1/2)\pi}\frac{\sin(t)}{t}dt$$于是可数分段$[k\pi,(k+1)\pi)$，最后不完整的周期单独做估计就好了。还有这几个问题，也都是类似的想法：
* [[关于一个含参数积分极限的两个策略的方法]]：当中的方法2正是一摸一样的策略。因为$f(*,\sin(u))$其中带有一个明显的具有周期性的部分，因此像渐近分析这种要求精度的定量问题，分段估计就是自然的想法。[[类似于傅里叶系数的一个积分估计]]当中第二种方法也是类似的估计方法。
* [[由Euler-Maclaurin求和估计得到Stirling逼近结果]]：当中遇到$\int_{n}^{+\infty}B_{3}(\{t\})\frac{1}{t^3}=\sum_{k\geq n}\int_{k}^{k+1}\frac{B_3(t-k)}{t^3}dt$这也是非常自然的处理，因为$\{t\}$是周期为1的函数，因此按照周期分段估计是自然的操作。
* [[证明一个具有部分周期性的含参数积分的非负性]]：当中我们为了估计$\int_{0}^{2k\pi}e^{-y^2}\sin(y)\,dy$,我们很自然地对积分区域做出了周期性地划分，然后进行分段估计，要求每一段都是正数，这样便证明了整体为正。

#### 2.2 Dyadic分解

详细情况见[[Dyadic分解]]，该分解的一个核心在于，如果我们假设被求和或者积分的对象在求和或者积分的集合上变化很剧烈，为了降低误差，达到分段估计里面的"错位",或者说"田忌赛马"的效果，我们让分段当中的每一段也就是底的长度进行指数级别的变化，这样才能适配被求和/积分对象的剧烈变化。


