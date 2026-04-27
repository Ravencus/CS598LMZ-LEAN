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
  - 调和分析
---

> [!note] Approximate identity(逼近单位)
> 对于一个$\mathbb{R}^n$上的可积的函数族$K_{\lambda}(x)\in L(\mathbb{R}^d),\lambda>0$:
> 1.  函数积分为1：$\int_{\mathbb{R}^d}K_{\lambda}(x)dx=1$ 
> 2.  绝对值的积分的一致有界性：$\int_{\mathbb{R}^d}|K_{\lambda}(x)|dx\leq A$并且$A$与参数$\lambda$无关。
> 3. 绝对值积分的任意尾部都衰减到0：对任意的$\delta>0$，$$\int_{|x|\geq\delta}|K_{\lambda}(x)|dx\to0,\text{ as }\lambda\to\infty$$
* 也可以称之为“可求和的核”（Summability Kernel）。
1. **一个简单的构造途径**：得到这种函数的一个简单办法是由一个绝对可积的，并且在整个$\mathbb{R}^d$上积分为1的函数$K(x)$经由$$K_{\lambda}(x):=\lambda^dK(\lambda x)$$来构成，其中n是由$\mathbb{R}^d$决定的。主要验证第三个条件的满足，此时$$\begin{aligned}\int_{|x|\geq\delta}|K_{\lambda}(x)|dx&= \int_{\mathbb{R}^d} \lambda^n |K(\lambda x)| \chi_{|x|\geq \delta} \,dx \\&= \int_{\mathbb{R}^d} |K(y)|\chi_{|y|\geq \lambda\delta}\,dy \to 0,\text{ as }\lambda \to \infty\end{aligned}$$第一步是[[积分的伸缩公式]]，第二步的极限是因为积分的绝对连续性，当然也可以直接用收敛定理去说明。

逼近单位元的命名是从代数的角度出发的：

> [!note] 代数
> 如果给一个线性空间配备一个封闭且具有双线性性的二元运算，那么我们这是一个"代数"(algebra).假设我们用$\cdot :V\times V \to \times V$表示这个具有双线性性的封闭的线性空间$V$上的二元运算，下面称其为乘法，那么
> * **如果乘法满足结合律**:称之为结合代数。即如果$a,b,c \in V$那么$$(a\cdot b)\cdot c = a \cdot (b\cdot c)$$
> * **如果乘法具有单位元**：称之为有单位的代数。也就是说存在一个$I \in V$使得$a \cdot I = a,\forall a \in V$.
> * **如果乘法具有交换律**: 那么称之为交换代数，也就是说$\forall a,b \in V$那么$$a\cdot b = b \cdot a$$

通常来说我们会把$L^{1}(\mathbb{R}^d)/\sim$简称为$L^{1}(\mathbb{R}^d)$,也就是说实际上我们面对的是一个在几乎处处相等的意义下的等价类组成的线性空间。这个线性空间上如果我们给它装备一个由两个函数卷积构成的二元运算，此时$(L^{1}(\mathbb{R}^d),*)$是一个代数，并且二元运算满足交换律和结合律:
1. **封闭性**,也就是说两个可积函数的卷积还是可积的。

这是因为由Fubini-Tonelli定理(具体定理叙述和理解参考[[Fubini-Tonelli定理的例子与反例]])以及Holder不等式可以推出下面的不等式

> [!note] 欧氏空间上卷积的Young不等式
> $1\leq p,q,r \leq \infty,\frac{1}{p}+\frac{1}{q} = \frac{1}{r} + 1$,那么$$||f*g||_{L^r}\leq ||g||_{L^p}||f||_{L^q}$$

此处只需要令$r=p=q=1$，那么此时就得到$$||f*g||_{L^1}\leq ||g||_{L^1}||f||_{L^1}<\infty$$
于是封闭性就得到了满足。
2. **双线性性**,也就是说$(af+bg)*h=a f*h +b g*h$，另一边也同样满足线性性。这是Lebesgue积分的线性性满足的。
3. **可交换性**,也就是$f*g=g*f$,因为在$\mathbb{R}^d$上Lebesgue测度是具有平移不变性的。
4. **满足结合律**同样由Fubini定理保证。

但是**这个代数没有单位元**！不过呢，我们有近似于单位元的对象存在，也就是逼近单位，也就是说虽然$K_n$不是单位元，但是$f*K_n$收敛到$f$。

### 1. $L^1(\mathbb{R}^d)$当中的逼近单位的常用结论

#### 1.1 三个常用结论

对于代数$(L^{1}(\mathbb{R}^d),*)$当中的逼近单位$K_{\lambda}$，有下面三个常用的关于逼近的结果:

> [!note] 逼近单位的三个基本结果
> 1. $f \in L^p(\mathbb{R}^d),1\leq p\leq \infty$，那么$f * K_{\lambda}\in L^p(\mathbb{R}^d)$并且$$||f * K_{\lambda}-f||_{L^p}\to 0,\text{ as }\lambda\to \infty$$
> 2. 如果函数$f$在$\mathbb{R}^d$上一致连续并且有界，那么$f*K_{\lambda}$也是一致连续并且有界的，并且$$f * K_{\lambda}\rightrightarrows f \text{ as }\lambda \to \infty$$
> 3. 如果函数$f$在$\mathbb{R}^d$上有界并且在开集$\Omega\subset \mathbb{R}^d$上连续，那么$f*K_{\lambda}$在$\mathbb{R}^d$上有界且一致连续，此外对于任意的紧子集$D \subset \Omega$都有$$f * K_{\lambda}\rightrightarrows f \text{ as }\lambda \to \infty$$

* 当然我们也可以从这三条结的证明中去掉整体的一致连续的假设，单纯考虑函数$f$在点$x_0$处连续，那么有$$f*K_{\lambda}(x_0)\to f(x_0)$$一个典型的例子可以参考[[逼近单位元在局部上的收敛性的一个典型例子]]。

这三个结论的基本精神是，$$||f * K_{\lambda}-f||\leq \int ||T_y\circ f-f||\cdot|K_{\lambda}(y)|\,dy $$
**如果函数在给定的范数的意义下，平移一点点对上面的积分影响不大的话，那么剩下的部分由于逼近单位元$K_{\lambda}$随着参数趋于无限的同时其尾部的积分逐渐趋于0，那么最后就能给到卷积与函数在该范数下误差的无穷小的上界，于是收敛。**

#### 1.2 对结论1的理解

$(L^p(\mathbb{R}^d),*),1< p\leq \infty$虽然不是一个代数，因为除了$p=1$的时候**其他情况下卷积没办法==总是==保证封闭性**。不过虽然无法总是保证封闭性，但是选一些特殊的对象去和$f$做卷积，还是可以保持封闭性的，比如说如果做卷积的对象是来自于$L^1(\mathbb{R}^n)$当中的逼近单位元，那么Young不等式就可以保证卷积的结果还在$L^p(\mathbb{R}^n)$当中。在这种特殊情况下，对于$1\leq p<\infty$一定有$$||f*K_{\lambda}||_{L^p}\leq ||f||_{L^p}||K_{\lambda}||_{L^1}$$这便保证了卷积这个二元运算在$L^p(\mathbb{R}^n)$当中的封闭性。

接下来是关于一致收敛性的证明。
$$\begin{aligned}||f * K_{\lambda}-f||_{L^p}&=\left|\left|\int f(x-y)K_{\lambda}(y)\,dy-f(x)\right| \right|_{L^p} \,dx\\ &= \left|\left|\int (f(x-y)-f(x))K_{\lambda}(y)\,dy\right| \right|_{L^p} \,dx \\ &\leq \int ||(T_y\circ f-f)K_{\lambda}(y)||_{L^p}\,dy\\ &= 
\int ||T_y\circ f-f||_{L^p}|K_{\lambda}(y)|\,dy \end{aligned}$$
其中第一步是很熟悉的估计$X - \int Y$形式的误差，很自然地把他们放在一个积分里面，然后对被积分的对象做估计从而使得每一步放缩的误差会相对小一些。

第二步是Minkovski的积分不等式。其中$T_y\circ f(x)$是把函数向右平移$y$得到的结果，实际上就是$f(x-y)$。对于固定的$f$，$$T_y(f):\mathbb{R}^d \to L^p(\mathbb{R}^d)$$是一个连续函数，也就是说$\forall z\in \mathbb{R}^d$都有，$$||T_{z+y}\circ f-T_z\circ f||_{L^p}\to 0\text{ as }y \to 0$$
(这个结论的证明可以参考[[Riemann - Lebesgue lemma的证明]]的1.4当中的命题1，更一般的版本可以参考该文章的3.2)

这样一来如果我们利用$T_z\circ f$在$z=0$处的连续性也就是说$||T_{y}\circ f-f||_{L^p}\to 0\text{ as }y \to 0$，我们可以把积分分为两个部分，考虑做一个分段估计。

$$\begin{aligned}\int ||T_y\circ f-f||_{L^p}|K_{\lambda}(y)|\,dy&= \int_{|y|<\delta_\varepsilon}*\,\,dy+ \int_{|y|\geq \delta_\varepsilon}*\,\,dy \\ &\leq \varepsilon M+2||f||_{L^p}\int_{|y|\geq \delta_\varepsilon} |K_{\lambda}(y)|\,dy \end{aligned}$$

其中第一段我们利用$T_y(f)$在$y=0$处的连续性，也就是说对任意的$\varepsilon>0$存在$\delta_{\varepsilon}$使得只要$|y|<\delta_{\varepsilon}$都有$||T_{y}\circ f-f||_p<\varepsilon$。然后逼近单位元的性质告诉我们，它是绝对可积的，假设绝对值的积分上界为M,于是得到了不等式前半部分的估计。

第二段直接考虑$||T_{y}\circ f-f||_{L^p} \leq 2||f||_{L^p}$,而最后一部分可以利用逼近单位元的尾部的特点，也就是随着$\lambda\to \infty$最后的极限为0.

于是我们令$\lambda\to \infty$我们得到$$\begin{aligned}\limsup_{\lambda\to \infty}||f * K_{\lambda}-f||_{L^p}&\leq \limsup_{\lambda\to \infty}\int ||T_y\circ f-f||_{L^p}|K_{\lambda}(y)|\,dy\\ &\leq \varepsilon M\end{aligned}$$对任意的$\varepsilon>0$成立，这说明其上极限为0，因此极限存在且为0.

#### 1.3 对结论2的理解

整个证明的想法和上一个证明的想法基本一致。只不过我们现在不是考虑$L^p$范数，而是考虑一致范数。

$$\begin{aligned}||f * K_{\lambda}-f||_{u}&\leq \int ||T_y\circ f-f||_{u}|K_{\lambda}(y)|\,dy\end{aligned}$$
这一步对于一致范数来说是比较显然的，或者说$L^p$范数的积分形式的Minkovski本身就是对一致范数的这个不等式的一个类比。

分段估计的部分也是类似的，
$$\begin{aligned}\int ||T_y\circ f-f||_{u}|K_{\lambda}(y)|\,dy&= \int_{|y|<\delta_\varepsilon}*\,\,dy+ \int_{|y|\geq \delta_\varepsilon}*\,\,dy \\ &\leq \varepsilon M+2||f||_{u}\int_{|y|\geq \delta_\varepsilon} |K_{\lambda}(y)|\,dy \end{aligned}$$

其中因为函数是一致连续的，因此$|f(x-y)-f(x)|<\varepsilon$只要$|y|<\delta_{\varepsilon}$。于是最后让$\lambda\to0$同样得到收敛，此时是在一致范数下的收敛，因此称之为一致收敛。

#### 1.4 对结论3的理解

#### 1.5 在函数连续点处点态收敛

^7126fd

> [!note] 命题1.5.1:在函数连续点处点态收敛
> 设$f\in L^{\infty}(\mathbb{R}^n\to \mathbb{R})$，$\{K_{\lambda}\}$是逼近单位元。若$x_0\in \mathbb{R}^n$是$f$的一个连续点，即$\lim_{x\to x_0}f(x)=f(x_0)$则$$\lim_{\lambda\to \infty}f*K_{\lambda}(x)=f(x_0)$$

对任意固定的$\varepsilon>0$，根据函数的连续性,存在对应的$\delta_{\varepsilon}$使得$$|f(x_0-y)-f(x_0)|<\varepsilon,\quad \forall |y|<\delta_{\varepsilon}$$那么对于$f*K_{\lambda}(x_0)-f(x_0)$这样一个积分估计，很自然地会采取$|y|<\delta_{\varepsilon}$以及$|y|\geq \delta_{\varepsilon}$的两段式的分段估计。$$\begin{aligned}|f*K_{\lambda}(x_0)-f(x_0)|&\leq \int_{\mathbb{R}^n}|f(x_0-y)-f(x_0)|\cdot |K_{\lambda}(y)|\,dy\\&=\int_{|y|<\delta_{\varepsilon}}*+\int_{|y|\geq\delta_{\varepsilon}}*\end{aligned}$$其中$$\int_{|y|<\delta_{\varepsilon}}* \leq \int_{|y|<\delta_{\varepsilon}}\varepsilon |K_{\lambda}(y)|\,dy\leq \varepsilon A$$第二段$$\int_{|y|\geq\delta_{\varepsilon}}*\leq 2
||f||_{L^{\infty}}\int_{|y|\geq \delta_{\varepsilon}}  |K_{\lambda}(y)|\,dy\to 0$$于是$$\limsup_{\lambda \to \infty} |f*K_{\lambda}(x_0)-f(x_0)|\leq A\varepsilon$$由于以上不等式对任意$\varepsilon>0$成立，从而命题得证。

---

* 此处的证明，如果$K_{\lambda}$是紧支的逼近单位元，那么对函数$f$的假设可以从$L^{\infty}$替换为$L^1_{loc}$。比如对于[[通过添加参数让目标更光滑化#^39a891]]当中说的Mollifier，$\psi_{\lambda}$不仅是一个逼近单位元，并且支撑落在$B(0,1/\lambda)$中。那么对于足够大的$\lambda$，大到使得$B(0,1/\lambda)\subset B(0,\delta_{\varepsilon})$那么整个$\int_{|y|\geq\delta_{\varepsilon}}*$的部分就是0，所以当$\lambda\to \infty$的时候这部分一定是等于0。$f$的局部可积主要是保证$$f*\psi_{\lambda}(x_0)=\int_{\mathbb{R}^n} f(x_0-y)\psi_{\lambda}\,dy=\int_{|y|\leq \frac{1}{\lambda}} f(x_0-y)\psi_{\lambda}(y)\,dy$$要保证这个是有意义的，那么也就是要保证$$\int_{|y|\leq \frac{1}{\lambda}} |f(x_0-y)|\,dy<\infty$$也就是说$f$在$x_0$附近局部可积。

### 2. 好的逼近单位元

把在$L^1(\mathbb{R}^n)$的逼近单位元里面挑一类性质更好的对象出来，我们称之为good approximate identity,或者"好的逼近单位元".

> [!note] 好的逼近单位元
> 1.  函数积分为1：$\int_{\mathbb{R}^d}K_{\lambda}(x)dx=1$ 
> 2.  函数全局的控制：$K_{\lambda}(x)=O(\lambda^{n})$
> 3.  尾部的控制:
> $$K_{\lambda}(x)=O\left(\frac{1}{\lambda^{\varepsilon_0} |x|^{n+\varepsilon_0}}\right)$$

现在要证明good kernel首先是逼近单位，也就是说它当然满足逼近单位的定义也满足上面的三个结论。

1. **验证函数绝对可积**

采用的基本方法是分段估计,这里如何分段是讲究的$$\begin{aligned}\int_{\mathbb{R}^d}|K_{\lambda}(x)|dx&=\int_{|x|\leq\frac{1}{\lambda}}|K_{\lambda}(x)|dx+\int_{|x| >\frac{1}{\lambda}}|K_{\lambda}(x)|dx\\&=O(\lambda^n\frac{1}{\lambda^n})+O\left(1\right)\\&=O(1)\end{aligned}$$这里用到一个基本结论，$$\int_{|x| >r,x\in\mathbb{R}^d}\frac{1}{|x|^{n+\varepsilon_0}}dx=O\left(\frac{1}{r^{\varepsilon_0}}\right)$$  
2. **验证尾部可以逐渐根据参数趋于0**：$$\int_{|x|>\delta}|K_{\lambda}(x)|dx=O\left(\int_{|x|>\delta}\frac{1}{\lambda^{\varepsilon_0} |x|^{n+\varepsilon_0}}\right)=O\left(\frac{1}{\lambda^{\varepsilon_0}\delta^{\varepsilon_0}}\right)=o(1)$$
**这种好的逼近单位的获取方式**：

我们知道对于逼近单位而言，我们可以通过一个积分为1的绝对可积的函数$K(x)$的伸缩获得，$$K_{\lambda}(x):=\lambda^nK(\lambda x)$$那么这里我们只需要让$K(x)$满足一个额外的增长条件，就可以得到好的逼近单位元,$$|K(x)|=O\left(\frac{1}{1+|x|^{n+\varepsilon_0}}\right)$$

#### 2.1 好的逼近单位好在哪?

> [!note] 几乎处处收敛的性质
> 如果$K_{\lambda}$是$L^1(\mathbb{R}^d)$当中的好的逼近单位元,$f\in L^p(\mathbb{R}^d),1\leq p\leq \infty$那么$$f*K_{\lambda}(x)\to f(x) \text{ for a.e. }x$$

实际上可以确定，这里如果点是Lebesgue点，那么收敛性质就会成立。而我们知道$\mathbb{R}^n$上几乎处处都是Lebesgue点(具体参数和定理证明可以参考[[Lebesgue微分定理]])，因此只要能证明在Lebesgue点上收敛成立，上面命题便成立。

证明的主要的策略和上面的毕竟单位元的三个基本结论是一致的。进行分段估计：
$$I_1+I_2=\int_{|y|<\eta}|f(x-y)-f(x)||K_{\lambda}(y)|dy+\int_{|y|\geq\eta}|f(x-y)-f(x)||K_{\lambda}(y)|dy$$

 **$I_2$部分余项的估计**：
 考虑Holder不等式，
 $$\begin{aligned}\int_{|y|\geq\eta}|f(x-y)-f(x)||K_{\lambda}(y)|dy&\leq\int_{|y|\geq\eta}\left(|f(x-y)|+|f(x)|\right)|K_{\lambda}(y)|dy\\&=\int\left(|f(x-y)|+|f(x)|\right)|K_{\lambda}(y)|\chi_{|y|\geq\eta}(y)dy\\&\leq||f||_p||\chi K_{\lambda}||_q+|f(x)|||\chi K_{\lambda}||_1\end{aligned}$$
 1. $p=1$时，$q=\infty$$$||\chi K_{\lambda}||_{\infty}=O\left(\frac{1}{\lambda^{\varepsilon}}\right)$$
 2. $p>1$,$q<\infty$的时候$$||\chi K_{\lambda}||_{q}=O\left(\frac{1}{\lambda^{\varepsilon}}\int_{|y|\geq\eta}\frac{1}{|y|^{n+\varepsilon}}\right)=O\left(\frac{1}{\lambda^{\varepsilon}}\right)$$因此$I_2=O\left(\frac{1}{\lambda^{\varepsilon}}\right)$ 
 于是现在剩下的工作就是搞定$I_1$的估计。
 
 **[[Dyadic分解]]来得到$I_1$的估计**
 
 但此时的一个问题是，我们不能像做逼近单位元的依范数收敛那样做，因为虽然当$|y|$很小的时候在$L^p$范数的意义下$||f(x-y)-f(x)||_{L^p}$会非常小，但是直接比较绝对值那就未必了。当然在逼近单位元的三个命题的2，3当中我们做出了一些妥协，要求函数是有界的，连续的甚至是一致连续的，那么的确可以做到不错的收敛。但是现在我们的假设仅仅是$f \in L^p$，那么这一套就行不通了。

一个好消息是，好的逼近单位元分别在$|y|$靠近0处，和$|y|$靠近$\infty$处给出了估计。并且核函数$|K_\lambda(y)|$大致上也是越接近$y=0$越大越靠$y=\infty$越小，那么我们实际上可以考虑做更精确的分段，考虑dyadic分段。

我们可以看成是$\frac{|y|}{\eta}\in[0,1)$的范围内的估计，然后把这个区间分解为$\frac{|y|}{\eta}\in [2^{-k},2^{-k+1})$这样的一层层球壳，其中$k\in\{1,...,M_{\lambda}\}$.此时对$|f(x-y)-f(x)|$的控制此时我们想到利用Lebesgue点，因为对$L^p(\mathbb{R}^n)$的函数而言，几乎所有(几乎处处)$\mathbb{R}^n$当中的点都是Lebesgue点也就是满足估计,$$\int_{B_r(x)}|f(x-y)-f(x)|\,dy\leq \varepsilon m(B_r(x))=o(r^n)$$于是便有了最后的这个方案。（这里一开始我们并不能确定要分多少个区间合适，但是我们知道和取极限的参数 $\lambda$有关系）于是$I_1$可以被估计为,$$\begin{aligned}I_1&=\int_{|y|<\eta}|f(x-y)-f(x)||K_{\lambda}(y)|dy\\&=\sum_{k=1}^{M_{\lambda}}\int_{\eta2^{-k}\leq|y|<\eta2^{-k+1}}|f(x-y)-f(x)||K_{\lambda}(y)|dy+\int_{|y|<\eta2^{-M_{\lambda}}}|f(x-y)-f(x)||K_{\lambda}(y)|dy\end{aligned}$$
**分开估计$|f(x-y)-f(x)|$与$|K_{\lambda}(y)|$这两个对象**。后者可以用的衰减特性做估计，前者可以用Lebesgue point满足的性质估计，即函数在自变量差的绝对值小于$r$的球内积分是球体积的高阶无穷小。
  
其中$\eta2^{-k}\leq|y|<\eta2^{-k+1}$内$|K_{\lambda}(y)|\leq C_1\frac{2^{k(n+\varepsilon)}}{\lambda^{\varepsilon}\eta^{n+\varepsilon}}$，当$|y|<\eta2^{-M_{\lambda}}$的时候$|K_{\lambda}(y)|\leq C_2\lambda^n$。此时因为对于任意的$\delta>0$都有

$$\begin{aligned}\int_{|y|<\eta2^{-M_{\lambda}}}|f(x-y)-f(x)||K_{\lambda}(y)|dy&\lesssim \lambda^n\int_{|y|<\eta2^{-M_{\lambda}}}|f(x-y)-f(x)|dy\\&\lesssim \delta(\lambda\eta2^{-M_{\lambda}})^n\end{aligned}$$这里我们要使得$\lambda\eta2^{-M_{\lambda}}$是有界的，比如$\lambda\eta2^{-M_{\lambda}}<1$于是$M_{\lambda}>\log_2^{\lambda\eta}$并且取整数。这样一来余项便是$o(1)$的。

$$\int_{\eta2^{-k}\leq|y|<\eta2^{-k+1}}|f(x-y)-f(x)||K_{\lambda}(y)|dy=o\left(\frac{2^{k(n+\varepsilon_0)}}{\lambda^{\varepsilon_0}}2^{-kn+n}\right)=o\left(\frac{2^{k\varepsilon_0}}{\lambda^{\varepsilon_0}}\right)$$于是求和加起来以后我们需要确定，$o\left(\frac{1-2^{M_{\lambda}}}{\lambda^{\varepsilon_0}}\right)$,考虑到$\lambda\eta2^{-M_{\lambda}}<1$我们可以知道$$o\left(\frac{2^{M_{\lambda}}-1}{\lambda^{\varepsilon_0}}\right)=o\left(\eta^{\varepsilon_0}-\frac{1}{\lambda^{\varepsilon_0}}\right)=o(1)$$于是最后我们可以得到想要的结果.

### 3. 一些著名的例子

* 