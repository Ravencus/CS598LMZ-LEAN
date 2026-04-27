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
### 0 基本想法

> [!tip] 基本的想法
> 当我们在**给定精度**下估计和$\sum X$的时候，对其中每一项做估计$$Y'\leq X\leq Y''$$从而得到$$\sum Y'\leq \sum X\leq \sum Y''$$然后我们需要保证两点：
> 1. 放缩以后的和更简单
> 2. 放缩以后的和满足我们对精度的要求
> 
> 只有同时满足这两个条件的放缩才是成功的逐项放缩。

* 其实不只是对于和，在同号的基础上，如果是乘积$\prod X$也是一样的，我们也可以对每一项进行估计，然后得到$$\prod Y'\leq \prod X\leq \prod Y''$$
比如：
* [[定义在超立方体上的对称函数的最大值]]:这里的“问题0”当中，我们想到组成乘积的每一项为$$\frac{(x-y)^2}{xy}\leq \frac{1}{2},x,y\in [1,2],x\neq y$$那么如果每一项都能取到最大值的话，岂不是整个乘积也就取到了最大值？当然后续进一步考虑的时候，发现当变量个数为奇数的时候，我们不能保证所有相邻变量互不相同，从而无法通过这样的逐项放缩的方式取到最大值。
* 类似的经验我们也能证明，对任意实数$a,b,c$都有$$(a+b+c)^2\geq 3(ab+bc+ac)$$对于这个问题，我们只要打开平方，就会发现我们只需要证明$$a^2+b^2+c^2\geq ab+ac+bc$$对于这一点，我们自然联想到$x^2+y^2\geq 2xy$，通过逐项估计就能得到最后的不等式。这里每一项取到最小值的条件是$x=y$，那么每一项都取到最小值也就得到取等条件$a=b=c$。
* 换成积分$\int X$也是一样，我们会得到$$\int Y'\leq \int X\leq \int Y''$$
### 1. 常见的用途和使用技巧
#### 1.1 需要一个由函数表示的上界

> [!tip] 想法1.1.1：基本想法
> 如果我们需要给一个和，或者一个连续的乘积$S_n$一个函数表示的上界$U_n$，使得$$S_n\leq U_n$$对$n>M$都成立。那么我们其中一种主要的想法无非就是：
> 1. $S_n$是否可以本身就非常容易求乘积或者和，并且乘积或者和是对我们而言比较简单或者熟悉的形式？比如假设$S_n=H_n$是调和数，或者其他什么我们很熟悉的特殊函数，亦或者就是多项式等等。
> 2. 如果第一个做不到，我们的想法是，是否可以通过放缩得到一个$S_n'$使得$S_n'$与$S_n$之间的误差符合要求，同时$S_n'$具有一个简单或者熟悉的表达式。为了实现第二点，我们尝试对“和”或者“乘积”的每一项做放缩，并且保证放缩后的对象对我们而言是“好求和”的。

^13ee84


> [!tip] 想法1.1.2:制造telescoping sum进行放缩的技巧（低精度，低成本）
> 如果$S_N:=\sum_{n=1}^{2N}(-1)^{n}f(n)$我们可以首先对部分和按照奇数与偶数搭配进行分组，从而表达为$$S_N:=\sum_{n=1}^Nf(2n)-f(2n-1)=\sum_{n=1}^{N} \Delta f(2n-1)$$
> * 如果此时函数具有concave性，也就是说$\Delta f(n) \geq \Delta f(n+1)$于是$$\Delta f(2n-1) \geq \frac{\Delta f(2n-1) + \Delta f(2n)}{2}=\frac{f(2n+1)-f(2n-1)}{2}$$以及$$\Delta f(2n-1) \leq \frac{\Delta f(2n-1) + \Delta f(2n-2)}{2}=\frac{f(2n)-f(2n-2)}{2}$$这样做的好处是，不等式的最右边都是telescoping sum，求和以后形式非常简单。也就是说$$\frac{f(2N+1)-f(1)}{2}\leq S_N\leq \frac{f(2N)-f(0)}{2}$$
> * 同样的，如果函数具有convex性，那么由于$\Delta^2 f(n) \geq 0$于是所有不等式反过来于是$$\Delta f(2n-1) \leq \frac{\Delta f(2n-1) + \Delta f(2n)}{2}=\frac{f(2n+1)-f(2n-1)}{2}$$以及$$\Delta f(2n-1) \geq \frac{\Delta f(2n-1) + \Delta f(2n-2)}{2}=\frac{f(2n)-f(2n-2)}{2}$$于是$$\frac{f(2N+1)-f(1)}{2}\geq S_N\geq \frac{f(2N)-f(0)}{2}$$
> 
> 常见的一些例子：
> 1. 对数函数$$\log(2n)-\log(2n-1)\geq \frac{\log(2n+1)-\log(2n-1)}{2}$$
> 2. 根号$$\sqrt{2n}-\sqrt{2n-1}\geq \frac{\sqrt{2n+1}-\sqrt{2n-1}}{2}$$
> 3. 反正切函数$$\arctan(2n)-\arctan(2n-1)\geq \frac{\arctan(2n+1)-\arctan(2n-1)}{2}$$

^d27913

* [[Re0微积分2：自然底数e及其快速计算#1. 极限的存在性与级数收敛判别]]当中的"命题1"当中我们需要证明$$1+\frac{1}{2!}+\cdots+\frac{1}{N!}<3$$对任意正整数$N$成立。于是根据基本的想法我们，需要对每一项找到一个上界，并且所有这些上界的和是“好求和”的。一个想法就是，制造一个Telescoping sum:$$a_n:=\frac{1}{n(n-1)\cdots 1}\leq \frac{1}{n(n-1)}$$因为Telescoping sum总是比较简单的。
* [[部分积的上界估计与Gautschi不等式#^b1fe7b]]中：正是利用了对数函数的concave性得到$$\begin{aligned}S_N=-\sum_{n=1}^N \log(2n)-\log(2n-1)&\ \leq \sum_{n=1}^N\frac{\log(2n-1)-\log(2n+1)}{2}\\&=-\frac{\log(2N+1)}{2}\\&<-\frac{1}{2}\log(2N)\end{aligned}$$
* [[估计一个根式的和]]：在这个问题当中我们需要对$$S=\sum_{k=1}^{40}\sqrt{400+k}$$做一个误差尽可能小，视最后情况而定但总之预计误差不会超过1的一个估计。我们发现，如果利用放缩$$\sqrt{400+k}>\sqrt{400}$$后者是非常容易求和的，并且后者的和是整数。然后我们还需要估计二者误差的累积情况，因为我们需要累积误差是小于1的。不过这个逐项放缩是成功的，因为最后的累积误差是小于1/2的。
* [[n个连续的阶乘之积有多少个因子]]：当中我们需要给出数论函数$\log(D(n))$做出估计，误差精度要求是$o(n)$。在做了一番分析以后，我们得到$$\log(D(n))=\sum_{p\leq n}\log(E_p(n)+1)$$而其中$E_p(n)=\frac{n^2}{2(p-1)}+O(n)$。此时我们的一个比较自然的尝试就是对每一项做估计。因此我们得到$$\log(E_p(n)+1)=2\log(n)-\log(p-1)+O(1)$$那么真正要处理的部分就是$\log(p-1)$的和。这种对数的$p\leq n$的素数的部分和，对我们而言是较为熟悉的。因为这就是Chebyshev的theta函数，并且误差精度我们可以做到$o(n)$因此逐项估计算是可行的方案。


#### 1.2 对含参数部分和/积分求极限

> [!tip] 想法1.2.1
> 这主要是求含参数的部分和的极限，因为如果和当中不带参数，那么部分和可以写成$T_n:=\sum_{k=0}^{n-1}f(k)$的形式，这个和的极限就是级数$\sum_{k\geq 0}f(k)$，这是一个求级数的closed form的表达问题，而不是对部分和的渐近估计问题。而真正需要做渐近估计的是，形如$$S_n=\sum_{k=0}^{n-1}f_n(k)$$的形式。而如果我们要求积分的话，我们相当于是要得到$$S_n=A+o(1)$$形式的渐近结果，也就是要求我们在做逐项估计的时候，需要保证每一项的误差经过求和的累积以后，不能超过$o(1)$。

注意使用逐项估计，然后把估计的结果求和的之前我们必须保证这种求和是合法的。

* [[从几个极限问题去理解Landau符号]]：这里需要做渐近展开的对象$S_n:=\sum_{k\leq n}\sin(k/n^2)$就是一个典型的例子，这里我们是对被求和对象使用$\sin(x)$的Taylor展开$\sin(x)=x+o(x)$完成的。此外这篇笔记里面还有关于Landau符号对应的$\varepsilon-N-\delta$语言的命题的严格解释。我们可以看到这个渐近问题当中为了保证$\sin(x)$的高阶导数是有界的，这是一定的，因此这里无需考虑分段估计。
* [[和的估计的一个典型案例#2. 观点2：逐项放缩]]：此处我们为了求$$S_n:=\sum_{k=1}^n \frac{1}{n^2}\sqrt{(n+k)(n+k+1)}$$的极限，因此需要做一个误差精度至少$o(1)$的估计。我们认为根号不太好，于是尝试利用被求和对象关于$k$的单调性去除根号$$n+k<\sqrt{(n+k)(n+k+1)}<n+k+1$$去除根号以后的上下界和特别简单，并且误差也是不超过$o(1)$的，于是问题圆满完成。
* [[收敛的连乘积的上界估计与糖水不等式#2. 用Taylor展开来做逐项估计]]：我们通过Taylor展开结合其余项来得到合适于放缩的不等式。
* [[对一个含参数的和的估计以及控制收敛定理#2. 计算极限]]：此问题中我们需要对$$S_n:=\sum_{k=0}^{n-1}\left(1-\frac{k}{n}\right)^n$$求极限。我们想的是，利用Taylor展开得到逐项的估计$$\begin{aligned}f_n(k)&= e^{-k}+O\left(\frac{k^2}{e^kn}\right)\end{aligned}$$但是这里面有一个问题，这个过程中需要用到两次Taylor展开，我们需要保证$k$的取值在两次Taylor展开当中都能保证目标的高阶导数在展开的邻域当中是有界的。因为这样的要求，因此我们进行了分段估计,分为两段:$$I_1=\{0,...,\lfloor \sqrt{n}\rfloor-1\},I_2=\{\lfloor \sqrt{n}\rfloor,\cdots,n-1\}$$这样第一段能成立上面的渐近估计，并且可以求和，第二段不满足，不过也可以逐项估计，只不过做得更为粗糙而已，不过没有关系，后一段每一项衰减非常快速。
* [[对一个含参数的和的估计以及控制收敛定理2]]：当中我们要求$$ S_n:=\sum_{k=1}^n \frac{5^{\frac{k}{n}}}{n+\frac{1}{k}}$$的极限。我们想要利用的逐项估计是$$f_n(k)=\frac{5^{k/n}}{n}\left(1-O\left(\frac{1}{nk}\right)\right)$$而这个逐项估计因为当$n$足够大的时候，$\frac{1}{nk}<1/2$,因此Taylor展开的一阶导数是有有界的，因此最后是可以求和的而不必像上面的例子一样进行分段估计。

下面还有一种对含参数的和的$1/p$求极限的问题，这种问题对精度的要求很低，可以通过下面的特定的放缩解决：

> [!tip] 基本想法1.2.2
> * 最简单的情形：
> 
> 对于求$$\left(\sum_{i\leq n}y_i(p)\right)^{1/p},p\to +\infty$$的极限，其中$y_i(p)\geq 0$。此时我们只需要关注其中最大的那一项的极限。不妨设最大的一项为$y_k(p)$，那么实际上我们只需要关注$y_k(p)^{1/p}$的极限。假设$y_k(p)^{1/p}\to A$那么：
> $$y_k(p)\leq \sum_{i\leq n}y_i(p)\leq ny_k(p)$$那么由于$$\lim_{p\to +\infty}y_k(p)^{1/p}=\lim_{p\to +\infty}(ny_k(p))^{1/p}=A$$那么最终的极限就是$A$。
> * 如果求和上限会随着参数变化而变化：
> 
> 甚至如果组成和的项目并非固定的，即我们把求和上限$n$替换为$n_p$一个随着$p$增加而增加到无穷的序列。那么此时，只要$n_p^{1/p}\to1$,即$n_p$增长不会太快，那么我们依旧只需要关注给定的$p$，$n_p$个组成和的项目中最大的一个，依旧假设为$y_k(p)$。此时$$y_k(p)\leq \sum_{i\leq n_p}y_i(p)\leq n_py_k(p)$$而因为$n_p^{1/p}\to1$，所以最后的极限依旧是$y_k(p)^{1/p}$的极限。
> * 加权并不影响极限：
> 
> 所谓加权，就是一列非负实数$\omega_1,\cdots,\omega_n$，使得我们原本要考虑的和从$\sum_{i\leq n}y_i(p)$变成了$\sum_{i\leq n}\omega_i y_i(p)$,也就是说我们要考虑的极限为$$\lim_{p\to +\infty}\left(\sum_{i\leq n}\omega_i y_i(p)\right)^{1/p}$$此时的放缩变成了$$\omega_ky_k(p)\leq \sum_{i\leq n}y_i(p)\leq y_k(p)\sum_{i\leq n}\omega_i$$因此最后的极限依旧是$A$。

^a88fe1

* 一个简单的例子，求极限：$$\lim_{n\to \infty}(1+n)^{1/n}$$其中和的部分就是$1+n$，而其中最大的一项就是$n$，由于$n^{1/n}\to 1$，因此按照上面提到的想法，最后的极限就是1.
* 另外一个简单例子，求极限$$x_n:=\sqrt[n]{1+\sqrt{2}+\sqrt[3]{3}+\cdots+\sqrt[n]{n}}$$按照上面的想法，我们只需要关注$1,\sqrt{2},\cdots,\sqrt[n]{n}$当中最大的一项。此时虽然组成和的项目，以及项目的数量会随着参数$n$的变化而变化，但是对于给定的$n$，最大的一项就是$\sqrt[3]{3}$，斌不会随着$n$而变化。此外，求和上限$n$开n次根号的结果，$n^{1/n}\to 1$。于是按照上面的想法，我们只考虑最大的一项，从而$$\sqrt[3]{3}\leq x_n^n\leq n\sqrt[3]{3}$$于是最后的极限为$$\lim_{n\to +\infty}x_n=1$$
* [[与无穷范数有关的一个含参数积分的极限]]：其中“问题1”的“引理2”中我们需要证明$$\lim_{p\to \infty}(x_1^p+\cdots+x_n^p)^{\frac{1}{p}}\to \max\{x_1,\cdots,x_n\}$$令$M=\max\{x_1,\cdots,x_n\}$,于是$M^p$就是我们需要关注的最大的一项,而这一项开$p$次根号，极限自然也就是$M$。
* [[Power mean及其性质]]:此处我们需要考虑加权$p$次平均值的极限$$\lim_{p \rightarrow +\infty} M_{p}(x_1,...,x_n;w_1 \cdots w_n) = \max\{x_1,...,x_n\}$$问题和上一个问题极其类似，只不过是添加了权重系数而已，而上面的想法告诉我们，权重系数并不影响结果。
#### 1.3 判断和/积分的收敛性

在1.2节中我们提到$$T_n:=\sum_{k=0}^{n-1}f(k)$$的形式的部分和，想要用逐项估计去求极限是没有任何可能的，但是用于判断级数是否收敛还是有一定的可能的。

##### 1.3.1 绝对收敛的判断

> [!tip] 想法1
> 我们要判断一个级数是否绝对收敛，实际上我们就是要得到部分和$T_n=\sum_{k=0}^{n-1}|f(k)|$的精度要求为$O(1)$的估计，也就是说我需要知道$T_n$是否是有界的。如果我们打算用逐项估计来进行这件事，这就要求我们对于$|f(k)|$的估计的逐项误差$r_k$其部分和$\sum_{k=0}^{n-1}r_k=O(1)$才行。

* 假设我们需要判断$$\displaystyle{\prod_{p}}{\frac{1}{1-p^{-s}}},\text{Re}(s)>1$$的收敛性。我们可以首先把问题转换为和的估计问题，$$\prod_{p\leq x}{\frac{1}{1-p^{-s}}} = -\sum_{p\leq x} \log(1-p^{-s})$$然后利用$\log(1+y)=y+O(y^2)$的这个渐近结果，这个结果对于任意有界的$y$都是成立的因此$$\begin{aligned}-\sum_{p\leq x} \log(1-p^{-s})&=\sum_{p\leq x}p^{-s}+O\left(\sum_{p\leq x}p^{-2s}\right)\\&= O(1)\end{aligned}$$于是乘积在$Re(s)>1$的部分是绝对收敛的。
* [[Dirichlet核不是逼近单位，Fejer核是逼近单位元]]：的问题中，我们需要证明$$\int_{0}^{\pi}\frac{\left|\sin\left((N+\frac{1}{2})t\right)\right|}{t}dt$$不是有界的。而鉴于这里的周期性，于是我们结合按照周期的分段，然后对每一段进行逐项估计。其中逐项估计的关键步骤是$\int_{0}^{\pi} \frac{\sin(s)}{k\pi +s}\,ds$这个对象我们对被积分对象的其中一部分做了渐近，而不是对全部做渐近，从而使得做积分以后结果会变得简单。此处$$\int_{0}^{\pi} \frac{\sin(s)}{k\pi +s}\,ds=\frac{2}{\pi k}+O\left(\frac{1}{k^2}\right),k>0$$前面指的简单就是此处，如果我们对$\frac{1}{k}$求和就会得到调和数，从而最终得到$$\int_{0}^{\pi}\frac{\left|\sin\left((N+\frac{1}{2})t\right)\right|}{t}dt=\frac{2}{\pi}\log(N)+O(1)$$的估计。

> [!tip] 想法2
> 另一种想法是，如果我们可以给和$\sum_{k\geq 1} |f(k)|$的被求和对象$|f(k)|$一个$g(k)$的上界，并且级数$\sum_{k\geq 1}g(k)$的收敛性判断对我们而言是简单的或者已知的，并且判断结果是收敛的，那么我们就可以断定$\sum_{k\geq 1} |f(k)|$的收敛性。反过来如果需要证明并非绝对收敛，那么我们只需要找一个发散的下界组成的级数。
> * 积分同理。


* [[证明函数项级数几乎处处绝对收敛]]：当中我们需要证明$$f(x):=\sum_{n\geq 1}\frac{|a_n|}{\sqrt{|x-r_n|}}$$几乎处处有限。而我们的思路是判断此函数在任意的长度为$1$的开区间$I$上的积分是否是绝对可积并利用[[和与积分换序]]的手段，问题被转换为判断级数$$\sum_{n\geq 1} |a_n|\int_{I}\frac{1}{\sqrt{|x-r_n|}}\,dm(x)$$是否绝对收敛的问题。而我们的方法无非就是逐项估计积分$$\int_{I}\frac{1}{\sqrt{|x-r_n|}}\,dm(x)\leq 2\int_{0}^{1/2}\frac{1}{\sqrt{x}}\,dm(x)$$从而利用$\sum_{n\geq 1}|a_n|<\infty$的条件断定此级数一定是绝对收敛的，从而得到$f(x)$的几乎处处有限的性质。此处逐项估计的方法，还是遵从，放大以后的上界对我们而言要么是简单的，要么是熟悉的。此处$\frac{1}{\sqrt{x}}$的积分对我们而言就是简单的，并且也是熟悉的。


##### 1.3.2 一致收敛的判断

##### 1.3.3 交错级数收敛性判断


### 3. 执行逐项估计的技术
#### 3.1 逐项与分段估计结合

> [!tip] 动机的阐述
> 设想一下我们要估计部分和$\sum_{n\leq N}f_N(n)$的上界，但是$[1,N]\cap \mathbb{Z}=E_1\cup E_2$而被求和对象$f_N(n)$在$E_1,E_2$上有着截然不同的行为。在这种情况下，我们如果贸然对$f_N(n)$做上界估计，比如$|f_N(n)|\leq g_N(n)$会导致两种情况:
> 1. 因为简单的$g_N(n)$很难同时捕捉$f_N(n)$在两个集合上不同的行为，导致$\sum_{n\leq N}f_N(n)$的上界估计$\sum_{n\leq N}g_N(n)$整体的误差太大以至于不能达到我们的预期。
> 2. 如果$g_N(n)$可以同时捕捉$f_N(n)$在两个集合上不同的行为，那么也就意味着$g_N(n)$不会太过于简单，这使得$\sum_{n\leq N}g_N(n)$的估计难度和$\sum_{n\leq N}f_N(n)$差不多。
> 
> 因此要解决这两个问题，要么不使用逐项估计而是用别的方法，要么先使用分段估计，然后针对每一段再使用逐项估计。
> * 当然也别忘记了[[分段估计#2. 可数分段]]当中提到的可数分段，特别是估计和或者积分的对象当中涉及某种部分的周期性的时候。



下面是一些具体的例子：
* [[对误差的分析从而改进分段估计]]：在这个问题当中我们需要估计$$S_n:=\sum_{k\leq n}n^{1/k}$$最低精度要求是$o(n)$。在假设逐项估计的“高”难以优化的基础上，我们想到用分段估计来优化逐项估计的"底"。具体来说，我们通过误差分析，发现形如$$S_n=n+\sum_{2\leq k\leq n}n^{1/k}=\sum_{2\leq k<n^{1/3}}n^{1/k}+\sum_{n^{1/3}\leq k\leq n}n^{1/k}$$的拆分就能实现我们的估计目标。
* [[用分段估计解决几个序列的极限问题]]：这里面的几个例子让我们看到，基本上一般我们是先决定做分段估计，然后在处理细节的时候再配合合适的逐项估计从而完成整个解答。
* [[Dirichlet核不是逼近单位，Fejer核是逼近单位元]]：当中估计$$\int_{0}^{\pi}\frac{\left|\sin\left((N+\frac{1}{2})t\right)\right|}{t}dt$$的时候显然需要考虑到周期性的问题，因此这里的逐项估计必须建立在按照周期的自然分段的基础上。
* [[Stirling渐近公式及不等式#4.更精确的不等式关系]]：其中我们需要得到关于$$\begin{aligned}R(n)&=-
\frac{1}{3}\int_{n}^{+\infty}B_{3}(\{t\})\frac{1}{t^3}<0\end{aligned}$$的不等式。被积分对象当中含有$\{t\}$这个周期为1的函数，于是我们的想法就是利用周期性进行自然分段，然后考虑逐项估计，看看是否和当中的每一项都是负的。
* [[对一个含参数的和的估计以及控制收敛定理#1.4 尝试用Euler-Maclaurin求和改进积分估计]]当中，和上面的例子一样，我们需要证明Euler-Maclaurin求和公式的余项非负。那么因为余项当中其中一部分带有周期1的函数，我们考虑加强命题，通过周期的自然分段结合逐项估计，证明求和的每一项都是非负的。

#### 3.2 光滑函数的Taylor展开

> [!tip] 想法3.2.1
> 如果我们需要对部分和$\sum_{n\leq N}f\circ g_N(n)$做渐近展开，同时$f(x)$又是一个具有一定的光滑性的函数，那么我们可以利用其Taylor展开，比如当$|x|<\delta$的时候$$f(x)=a_0+a_1x+o(x)$$并且对任意的$n\leq N$都有$|g_N(n)|\to 0$,那么部分和的渐近展开就可以写作$$a_0N+a_1\sum_{n\leq N}g_N(n)+o\left(\sum_{n\leq N}g_N(n)\right)$$然后剩下的问题就是搞清楚$\sum_{n\leq N}g_N(n)$的估计。
> * 此外，通过对Taylor展开的具体的余项进行正负号的分析，我们可以从中导出不等式来，这对于一些需要求具体的上界或者下界的问题非常有用。


> [!question] 3.2.2:需要注意的一个问题
> 适用Taylor展开做逐项估计的时候，我们说的是函数$f(x)$在点$x=x_0$的邻域即某个$|x-x_0|<\delta$的时候，存在一个常数$C_{\delta}$使得$R_n(x):=f(x)-P_n(x)$满足$$|R_n(x)|\leq C_{\delta}|x-x_0|^{n+1}$$其中$P_n(x)$是一个$n$阶多项式。如果我们用Lagrange余项来表示这个$R_n(x)$那么$$|R_n(x)|=\left|\frac{f^{(n+1)}(\xi)}{(n+1)!}(x-x_0)^{n+1}\right|$$如果我们要保证$C_{\delta}$与$x$的选择没有任何关系，我们就必须要保证$\delta$的选取能够保证在此范围内的$x$都能够保证$x,x_0$之间的$\xi$使得$|f^{(n+1)}(\xi)|\leq M$。
> 
> 如果需要求和的所有$k$当中并非所有都能满足这一点要求，那么可以考虑使用分段估计，估计不满足这样的$k$对应的$f_n(k)$的和的估计是在目标精度以内的。

* [[从几个极限问题去理解Landau符号]]：这里需要做渐近展开的对象$S_n:=\sum_{k\leq n}\sin(k/n^2)$就是一个典型的例子，这里我们是对被求和对象使用$\sin(x)$的Taylor展开$\sin(x)=x+o(x)$完成的。此外这篇笔记里面还有关于Landau符号对应的$\varepsilon-N-\delta$语言的命题的严格解释。我们可以看到这个渐近问题当中为了保证$\sin(x)$的高阶导数是有界的，这是一定的，因此这里无需考虑分段估计。此外[[从几个极限问题去理解Landau符号#4. 使用Landau符号的时候常见的错误]]当中也强调了“3.2.2”当中的问题。
* [[对误差的分析从而改进分段估计#2. 基于Taylor展开的逐项估计]]：在这个问题当中我们需要估计$$S_n:=\sum_{k\leq n}n^{1/k}$$目标精度为$o(n)$。其中我们发现被求和对象实际上是可以Taylor展开的：$$e^{\frac{\log(n)}{k}}=1+\frac{\log(n)}{k}+\frac{1}{2}\left(\frac{\log(n)}{k}\right)^2 \exp(\xi_{k,n})$$此处注意，因为$e^x$展开当中的$x$会越来越大，并不是在有界的范围里面展开，因此此处余项用Lagrange余项的Taylor展开，避免Landau符号产生的误解。在结合了分段估计的策略以后，通过对起始位置的$k$的选择，最终得到了我们想要的估计。
* 求含参数的和的极限：$$\lim_{n\to \infty}\sum_{k=1}^{n}\log(1+\frac{k}{n^2})$$这里被积分对象是光滑的，并且对于足够大的$n$所有的$0<\frac{k}{n^2}<1/2$于是，利用Taylor展开来进行逐项估计得到$$\log(1+\frac{k}{n^2})=\frac{k}{n^2}+O\left(\frac{k^2}{n^4}\right)$$然后求和把误差累积起来，得到渐近$$\frac{1}{2}+O(1/n)$$于是含参数和的极限就是$\frac{1}{2}$。
* [[利用基于Taylor展开的逐项估计判断级数收敛的例子1]]:在这个问题当中我们需要确定参数$a,b$取什么值的时候序列$$u_n:=\log(n)+a\log(n+1)+b\log(n+2)$$对应的级数是收敛的。因为序列的表达式对应着光滑的函数，因此我们可以利用Taylor展开对$u_n$进行逐项估计，从而把级数的部分和转换为我们熟悉的部分和的形式，即要判断的级数的部分和何以表示为$$\begin{aligned}S_N=(1+a+b)A_N+(a+2b)H_N+R_N\end{aligned}$$其中$A_N,H_N$的增长情况我们都是熟悉的，而$R_N$对应的级数是绝对收敛的，因此它完全不影响部分和$S_N$的极限存在与否。于是问题就变得容易处理了。
* [[收敛的连乘积的上界估计与糖水不等式#2. 用Taylor展开来做逐项估计]]：其中，我们通过Taylor展开结合其余项来得到合适于放缩的不等式。
* [[对一个含参数的和的估计以及控制收敛定理#2. 计算极限]]：其中，我们对$$S_n:=\sum_{k=0}^{n-1}\left(1-\frac{k}{n}\right)^n$$求极限。我们想的是，利用Taylor展开得到逐项的估计$$\begin{aligned}f_n(k)&= e^{-k}+O\left(\frac{k^2}{e^kn}\right)\end{aligned}$$但是这里面有一个问题，这个过程中需要用到两次Taylor展开，我们需要保证$k$的取值在两次Taylor展开当中都能保证目标的高阶导数在展开的邻域当中是有界的。因为这样的要求，因此我们进行了分段估计,分为两段:$$I_1=\{0,...,\lfloor \sqrt{n}\rfloor-1\},I_2=\{\lfloor \sqrt{n}\rfloor,\cdots,n-1\}$$这样第一段能成立上面的渐近估计，并且可以求和，第二段不满足，不过也可以逐项估计，只不过做得更为粗糙而已，不过没有关系，后一段每一项衰减非常快速。
* [[对一个含参数的和的估计以及控制收敛定理2]]：当中我们要求$$ S_n:=\sum_{k=1}^n \frac{5^{\frac{k}{n}}}{n+\frac{1}{k}}$$的极限。我们想要利用的逐项估计是$$f_n(k)=\frac{5^{k/n}}{n}\left(1-O\left(\frac{1}{nk}\right)\right)$$而这个逐项估计因为当$n$足够大的时候，$\frac{1}{nk}<1/2$,因此Taylor展开的一阶导数是有有界的，因此最后是可以求和的而不必像上面的例子一样进行分段估计。
* [[判断一个类交错级数的收敛性]]：当中我们需要判断$$\sum_{n\geq 2}\frac{(-1)^n}{\sqrt{n}+(-1)^n}$$的收敛性。我们利用函数$\frac{1}{1+x}$的Taylor展开做逐项估计以后得到其部分和的估计$$S_N=\sum_{2\leq n\leq N}\frac{(-1)^n}{\sqrt{n}} -\sum_{2\leq n\leq N}\frac{1}{n}+O\left(\sum_{2\leq n\leq N}\frac{1}{n^{3/2}}\right)$$这样便很容易看出$S_N$实际上是无界的。
* [[两种不同路径解决含参数和的估计问题#2. 基于Taylor展开的逐项估计]]:这个问题当中我们需要估计$$S_n:=\sum_{i\leq n}\frac{1}{n+\sqrt{i}}$$要求的精度为$o\left(\frac{1}{\sqrt{n}}\right)$。我们直接对其中被求和对象借助换元法进行Taylor展开，得到$$\frac{1}{n+\sqrt{i}}=\frac{1}{n}-\frac{\sqrt{i}}{n^2}+o\left(\frac{\sqrt{i}}{n^2}\right)$$然后借助$$\sum_{i\leq n}\sqrt{i}=\frac{2}{3}n^{3/2}+O(\sqrt{n})$$最后得到$S_n$的估计。

此方法的局限性：

* [[不适用于逐项估计求和的极限的例子]]:在这个例子当中，我们求含参数和的极限$$\sum_{k=1}^{n}\frac{1}{n+f(k)}$$其中$f(k):=\frac{2k(k-1)}{2k-1}$。如果我们考虑$$\frac{1}{n+f(k)}=\frac{1}{n}\frac{1}{1+\frac{f(k)}{n}}$$并利用$1/(1+x)$的Taylor展开来进行逐项估计，那么想要达到求极限的整体精度，我们需要保证$\sum_{k=1}^n f^2(k)$是一个$o(n^3)$的和。但这根本做不到。因此在此问题当中，上面的技术失效了。


---

积分的逐项估计也是非常类似的思路：

> [!tip] 想法3.2.3
> 当我们想要对一族含参数的积分做渐近展开$$I_n:=\int_E f(x_0+g_n(x))\,d\mu(x)$$其中$f$在$x_0$附近足够光滑，而$g_n(x)\to 0$。
> 
> 若$f$在某个小邻域$|u|\leq \delta$内可以写出Taylor展开$$f(x_0+u)=\sum_{j=0}^{m}\frac{f^{(j)}(x_0)}{j!}u^j+R_{m+1}(u),\quad |R_{m+1}(u)|\leq C_{\delta}|u|^{m+1}$$并且$g_n(x)$落在该邻域内，那么把展开式两边进行逐项积分得到$$I_n=\sum_{j=0}^{m}\frac{f^{(j)}(x_0)}{j!}\int_Eg_n^j(x)\,d\mu(x)+\int_ER_{m+1}(g_n(x))\,d\mu(x)$$于是问题被转换为估计两类对象：
> 1. 主项$\int g_n^{j}\,d\mu(x)$
> 2. 余项$\int_ER_{m+1}(g_n(x))\,d\mu(x)$
> 
> 如果$f$的Taylor展开的余项$R_{m+1}$的符号确定，那么我们可以把以上渐近展开变成积分不等式的上界或下界估计。

* 当然也并不是说一定要把含参数积分看成是$\int_E f(x_0+g_n(x))\,d\mu(x)$的形式。因为我们最终的目的只是要让被积分对象足够简单，以至于积分结果的渐近展开很容易获得。有时候只需要展开被积函数的一部分才是让整个被积分对象简单的情况。比如说$$\int_0^1 \frac{\log(1+\frac{x}{n})}{x}\,dx$$展开利用$\log(1+u)$的Taylor展开来展开$\log(1+x/n)$，就可以让整个被积分对象足够简单了。

> [!example] 例子3.2.4: 
> $p>0$证明
> $$\int_0^1 \frac{1}{1+x^p}>\frac{p}{p+1}$$

* 根据函数$\frac{1}{1+u}$在$u=0$处的Taylor展开$$\frac{1}{1+u}=1-u+R_3(u)$$其中根据函数在$u=0$处的二阶导数判断可知$R_3(u)>0$对任意$u\in (0,1]$成立。从而$$\int_0^1 \frac{1}{1+x^p}>\int_0^1 1-x^p\,dx = 1-\frac{1}{p+1}=\frac{p}{p+1}$$
* 我们还可以展开更多项，从而得到更精确的下界，比如我们可以利用$$\frac{1}{1+u}>1-u+u^2-u^{3}$$从而$$\begin{aligned}\int_0^1 \frac{1}{1+x^p}\,dx&>\int_0^1 (1-x^p+x^{2p}-x^{3p})\,dx\\& = 1-\frac{1}{p+1}+\frac{1}{2p+1}-\frac{1}{3p+1}\end{aligned}$$由于$\frac{1}{2p+1}-\frac{1}{3p+1}=\frac{p}{(1+2p)(1+3p)}>0$因此新的下界要比原本的$1-\frac{1}{p+1}=\frac{p}{p+1}$更好一些。


> [!example] 例子3.2.5
> 计算$$I_n:=n\int_0^1 \log\left(1+\frac{e^x}{n}\right)\,dx$$

* 由于函数在$f(u):=\log(1+u)$在$u=0$处可以根据带Lagrange余项的Taylor展开$$f(u)=u+\frac{f''(\xi_u)}{2}u^2,\quad \xi\in (0,u)$$由于$$f''(\xi)=\frac{1}{(1+\xi)^2}\leq 1$$因此对任意$u>0$都有$$f(u)=u+R(u),\quad |R(u)|\leq \frac{1}{2}u^2$$然后我们带入$u=\frac{e^x}{n}$于是得到$I_n$的一个渐近估计$$\begin{aligned}I_n&=(e-1)+n\int_0^{1}R(e^x/n)\,dx\\&\end{aligned}$$其中$$\begin{aligned}\left|n\int_0^{1}R(x/n)\,dx\right|&\leq n\int_0^1 |R(e^x/n)|\,dx\\&\leq \frac{e^2}{4n}\end{aligned}$$于是$$I_n=e-1+O(1/n)$$于是极限自然是$e-1$。


一些类似的问题：
* 证明$$\int_0^1 \log(1+x^5)\,dx > \frac{1}{10}$$
* 证明对任意正整数$n$都有$$\int_0^1 e^{-nx^2}\,dx >\frac{1}{2\sqrt{n}}$$不妨换个元，令$u=nx^2$然后再进行Taylor展开，然后估计下界。
* 令$$J_n:=\int_0^1 \frac{\log(1+\frac{x}{n})}{x}\,dx$$计算极限$$\lim_{n\to \infty}n\left|nJ_n-1\right|$$答案是$\frac{1}{4}$，因为其中$J_n$的渐近展开为$$J_n = \frac{1}{n}-\frac{1}{4n^2}+O(1/n^3)$$



---

什么时候仅仅基于Taylor展开的逐项估计不成功？

1. 当光滑性不够的时候：比如[[逼近单位元在局部上的收敛性的一个典型例子]]当中，函数$f$只是黎曼可积，根本不具有光滑性的信息，因此Taylor展开失败。
2. 

#### 3.3 比值的逐项估计



#### 3.4 连分数逼近
#### 3.5 从式子中分裂出telescoping sum

关于Telescoping sum要如何制造，具体可以参考:[[制造telescoping sum求和或求乘积]]。

* [[Re0微积分2：自然底数e及其快速计算#1. 极限的存在性与级数收敛判别]]：其中的"命题1"当中我们需要证明$$1+\frac{1}{2!}+\cdots+\frac{1}{N!}<3$$对任意正整数$N$成立。于是根据基本的想法我们，需要对每一项找到一个上界，并且所有这些上界的和是“好求和”的。一个想法就是，制造一个Telescoping sum:$$a_n:=\frac{1}{n(n-1)\cdots 1}\leq \frac{1}{n(n-1)}$$因为Telescoping sum总是比较简单的。
#### 3.6 中值不等式/Lipschitz性质

* [[给模1均匀分布的序列增加一个算术平均值渐近为0的序列]]：这个问题当中关键的逐项估计是得到$$e(x)=e^{2\pi i x}=1+O(x),\forall x \in \mathbb{R}$$其思路就是，考虑$y=0$这个固定的点，然后$$|e(x)-e(y)|\leq \sup_{x\in \mathbb{R}}|e'(x)||x-y|$$这样放缩的目的是为了得到$$e(kx_n)e(ky_n)=e(kx_n)+O(|y_n|)$$联系到逐项估计最重要的精神：放缩以后的和是更好估计的。而现在我们得到的两个被求和对象其和我们都是知道的，并且都是符合精度要求的，因此问题便解决了。

#### 3.7 结合隐函数定理

* [[对含参数方程根的估计#1. 从隐函数的渐近展开切入]]：在这个问题当中我们需要估计和$$A(s):=\sum_{k=1}^{N(s)-1}\frac{1}{x_kx_{k+1}}$$其中$x_k(s)$是含参数的方程$\cos(x)=sx$的从小到大的第$k$个正实根。一个基本的思路就是对$x_k(s)$做渐近展开从而进行逐项估计，而此处渐近展开的路径就是通过隐函数定理，把$x_k(s)$视为隐函数。

### 4. 差的估计中的逐项估计

> [!tip] 基本想法
> * 当我们需要对形如$|(\sum X) - Y|$做估计的时候，逐项估计通常是不错的选择，因为直接整体对$Y$做估计通常会造成很大的误差，并且不能适配$\sum X$中$X$的变化，可是如果我们能把$Y$展开为一个和使得$Y=\sum Y'$那么$$|\sum X-Y|\leq \sum|X-Y'|$$然后对$\sum|X-Y'|$做分段估计+逐项估计等操作。(积分也是如此)
> * 其次这个想法也可以和[[分段估计]]配合起来使用。比如说如果我们不容易把$Y$展开为某个合适的和的形式，但是我们可以通过插入一个相似的中间对象$Z$，其中$Z$满足:$Z=\sum Z'$并且其中$\sum Z'$非常适合与$\sum X$做逐项估计,以及$|Z-Y|$的误差是符合我们整个问题对误差的精度要求的，那么问题就可以变成$$\begin{aligned}\left|\sum X -Y\right|&\leq \left|\sum X-Z \right|+\left|Z -Y\right|\\&\leq \left|\sum X-\sum Z' \right|+\left|Z -Y\right|\\&\leq \sum |X-Z'|+|Z-Y|\end{aligned}$$那么因为以上的好的条件，那么最后两项可以被很好地控制起来，以至于最后我们可以控制整体的精度，从而完成对$\left|\sum X -Y\right|$的估计。

* [[IMC上的一个渐近分析的问题]]中我们需要对$$S_N=\frac{1}{N^2}\sum_{n\leq N} n\log(n)-\frac{1}{2}\log(N)$$做渐近估计。因为这显然是$\sum X - Y$的类型的估计。对于此问题的第一个做法就是使用上面的想法首先得到$$\begin{aligned}\frac{1}{2}\log(N)&=\frac{1}{N^2}\sum_{n\leq N}n\log(N)+O\left(\frac{\log(N)}{N}\right)\\&= \frac{1}{N^2}\sum_{n\leq N}n\log(N)+o(1)\end{aligned}$$然后我们就可以在和当中做逐项的更为精细的估计了。
* [[黎曼积分与黎曼和的误差]]:在这个问题当中我们需要对$$R_n:=\int_0^1f(t)\,\mathrm{d}t-\frac1n\sum_{k=0}^{n-1}f(k/n)$$做精度为$o(1/n)$的估计。因为这并不是一个标准的和或者积分的估计，我们想到可以通过对积分区间进行均匀切割的方式，把$R_n$变成一个标准的和的估计问题。最后可以对每一段的被积分对象$f(t)-f(k/n)$做Taylor展开，这样便可以进行逐项估计，从而得到我们最终想要的估计结果。
* [[approximation to the identity]]当中基本每一个命题都用到了上面的想法。比如说估计$||f * K_{\lambda}-f||_{L^p}$要求精度是$o(1)$。那么利用$K_{\lambda}(x)$是逼近单位元的性质，实际上我们是对$$\int ||T_y\circ f-f||_{L^p}|K_{\lambda}(y)|\,dy$$做估计其中$T_y\circ f=f(x-y)$。当然后面还有别的手段，比如分段估计等等。
* [[柯西积分公式]]的证明当中，我们需要$$\left|f(a) - \frac{1}{2\pi i}\int_{\Gamma} \frac{f(z)}{z-a} dz\right| < \varepsilon  $$对任意的$\varepsilon$成立。为了误差的减少，我们把内容合并到一起，为逐项估计做准备，即估计$$\frac{1}{2\pi}\left|\int_{\Gamma}\frac{f(z)-f(a)}{z-a}\right|\,dz$$而我们注意到在局部，由于函数在$a$处可微，于是可以在余项上做文章，因为只要$z$靠近$a$足够近就有$$\left|\frac{f(z)-f(a)}{z-a}-f'(a)\right|\leq \varepsilon$$不过这个不等式只能在局部成立，未必在$\Gamma$包含的圆盘内成立。好在结合柯西定理，$\Gamma$与围绕$a$的半径任意小的圆周都是同伦的。于是问题等价于估计$\frac{1}{2\pi}\left|\int_{\gamma_{r}}\frac{f(z)-f(a)}{z-a}\right|\,dz$，而这个积分是局部的，利用三角不等式就完成了逐项估计。
* [[Riemann-Stieltjes积分]]:在定理3.1.1的证明当中，我们需要在证明$fg$黎曼可积的情况下，证明$f$关于$\alpha(x):=\alpha(a)+\int_{a}^{x}g(t)\,dt$是Riemann-Stieltjes积分可积。于是我们需要估计Riemann-Stieltjes和$S_f(P,\xi,\alpha)$与积分$I:=\int_{a}^b fg\,dx$之间的差的误差是否是任意小，也就是估计:$$|S_f(P,\xi,\alpha)-I|$$这是一个符合$\sum X -Y$形式的和的估计。然而$I$是不能写成某个和的形式的，因为它本身是一个黎曼积分。不过黎曼积分与黎曼和之间可以任意接近，而黎曼和与Riemann-Stieltjes和之间是比较适合逐项估计的，因此$$\begin{aligned}|S_f(P,\xi,\alpha)-I|&\leq |I-S_{fg}(P,\xi)|+|S_{fg}(P,\xi)-S_f(P,\xi,\alpha)|\\&< \frac{1}{2}\varepsilon+|S_{fg}(P,\xi)-S_f(P,\xi,\alpha)|\end{aligned}$$后者可以很自然地进行逐项估计，最终被$g$的振幅与划分的子区间长度的乘积的和控制起来，而$g$又是黎曼可积的，利用黎曼可积的“黎曼判别”于是就可以完成整个估计。