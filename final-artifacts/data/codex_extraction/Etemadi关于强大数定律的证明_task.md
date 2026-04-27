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
  - 概率论
---

> [!note] 强大数定律,Kolmogrov,1930
> $X_1,...,X_n,...$是一列独立同分布的随机变量，并且期望存在，即$E(|X_i|)<\infty$。那么如果假设$E(X_1)=\mu,S_n=\sum_{k=1}^{n}X_i$那么$$\frac{S_n}{n}\xrightarrow{a.e.}\mu$$

不过本文的证明不是Kolmogrov的证明，而是Etemadi 1981年给出来的一个更简单的证明。这个证明所根据的想法是典型的[[用子列来提升收敛或发散性质]]的想法。不过首先让我们简化一下问题，这里需要做两个简化。

### 1. 对问题的简化

1. **假定随机变量皆非负**：
这是因为，一个随机变量可以看成是两个非负随机变量的差。因为$X_i=X^{+}_i-X_i^{-}$,其中$X_i^{+}=\max\{X_i,0\},X_i^{-}=\max\{-X_i,0\}$。这样的话实际上如果我们可以对两个部分都证明具有几乎处处收敛的性质，那么原来的随机变量也一定具有这样的性质，因此我们只需要对非负的随机变量证明强大数定律即可。
2. **截断**：
截断指的是定义随机变量$Y_i = X_i\mathbf{1}_{|X_i|\leq i}$，而这种截断拥有更好的性质，例如方差的增长是可以被控制起来的(虽然不是有限的)，这一点在后面2.2节中，关于用Borel-Cantelli引理把依测度收敛提升为几乎处处收敛中有关键作用。

当时我们需要保证，截断以后对原来的命题是没有影响的才对，至少在几乎处处的意义下。

> [!note] 引理1
> 如果定义$T_n = \sum_{i\leq n}Y_i$那么，$$\frac{T_n}{n}-\frac{S_n}{n}\xrightarrow{a.e.}{0}$$

这是主要是因为因为$P(Y_i\neq X_i \text{ i.o.})=0$。

于是在有了这个结果以后，我们知道在概率空间$(\Omega,\mathcal{F},P)$当中几乎所有的(概率测度意义下的几乎处处)$\omega \in \Omega$它只能包含在有限多个形如$\{\omega:Y_{i}(\omega)\neq X_i(\omega)\}$的集合当中。具体来说，假设$$\Omega'=\{\omega:Y_{i}(x)\neq X_i(x) \text{ f.o. }\}$$表示那些所有的属于$\Omega$，且只属于有限多个($\text{f.o.}$意味着"finitely often")形如$\{x:Y_{i}(x)\neq X_i(x)\}$的元素组成的集合。这意味着，对于任意一个$\omega\in \Omega'$,我们都可以从中找到找到一个下标最大的使得$\omega\in \{x:Y_{N_{\omega}}(x)\neq X_{N_{\omega}}(x)\}$的$N_{\omega}$使得当$n>N_{\omega}$的时候$Y_n(\omega)=X_n(\omega)$

于是我们可以说，对任意的$\omega\in \Omega'$都有$$\left|\frac{T_n}{n}(\omega)-\frac{S_n}{n}(\omega)\right|\leq \frac{\sum_{i\leq n}|X_i(\omega)-Y_i(\omega)|}{n}\leq \frac{\sum_{i\leq N_{\omega}}|X_i(\omega)-Y_i(\omega)|}{n}$$对任意正整数$n$成立。那么两边取极限，就会得到结论,$$\frac{T_n}{n}-\frac{S_n}{n}\xrightarrow{a.e.}{0}$$
至于这里面至关重要的$P(Y_i\neq X_i \text{ i.o.})=0$是由于[[Borel-Cantelli lemma及其应用]]。因为$P(Y_i\neq X_i)=P(|X_i|>i)$，于是通过$$\begin{aligned}\sum_{i\geq 1} P(|X_i|>i)&=\sum_{i\geq 1} P(|X_1|>i)\\&\leq \sum_{i\geq 1}\int_{i-1}^{i}P(|X_1|>t)\,dt\\&= \int_{0}^{\infty}P(|X_1|>t)\,dt\\&= E(|X_1|) <\infty\end{aligned}$$
* 此处的关键是使用[[和的积分估计]]。具体地，首先注意到被求和对象$P(|X_i|>i)$是单调减少的。其次其积分是简单的，或者说对我们而言熟悉的，因为我们事先知道$$\int_{0}^{\infty}P(|X_1|>t)\,dt= E(|X_1|) <\infty$$


简化后的命题变成了:

> [!note] 命题1:强大数定律的等价命题
> 证明$$\frac{T_n}{n}=\frac{\sum_{i\leq n}Y_i}{n}$$是几乎处处收敛到$E(X_1)=\mu$的，其中$X_1,...,X_n,...$是独立同分布的非负随机变量,$Y_i = X_i\mathbf{1}_{|X_i|\leq i}$.


> [!note] 整个证明的结构
> 1. 首先我们对$X_n$序列的版本的强大数定律做了两个简化，那么我们的目标是证明“命题1”。我们首先已经知道依测度收敛的情况，这实际上就是弱大数定律。
> 2. 接下来，我们遵照[[加强收敛性质的条件与手段#1. 利用Borel-Cantelli引理来把依测度收敛加强到几乎处处收敛]]的想法,不过原本的序列依旧是困难的，于是一开始的简化会在此发挥作用，但还不足以直接证明收敛性。于是我们尝试选择合适的子列来提升收敛性质。
> 3. 我们通过一个特殊的子列，我们可以证明“命题1”可以转换为：任取一个满足$a>1$的实数$a$,令$n_k = \lfloor a^k\rfloor$，$$\frac{T_{n_k}}{n_k}\xrightarrow{a.e.}{\mu}$$而因为子列足够好，以至于我们可以把子列的这种收敛性过渡到原本序列的收敛上。


### 2. 转换为子列的收敛性

等价命题的真题想法是按照[[用子列来提升收敛或发散性质]]来展开的。也就是说我们会首先证明其中特定的子列是几乎处处收敛的，然后通过子列收敛来证明$\frac{T_n}{n}$的收敛。子列的构造如下：

任取一个满足$a>1$的实数$a$,令$n_k = \lfloor a^k\rfloor$,我们现在的目标变成了

> [!note] 等价命题2
> 证明$$\frac{T_{n_k}}{n_k}\xrightarrow{a.e.}{\mu}$$
#### 2.1 子列与原本序列的关系
这部分我们要回答，究竟为何其子列几乎处处收敛就能导出原本的序列是几乎处处收敛的？这个子列究竟有什么特殊指出?

**假定"等价命题2"成立，现在推导"等价命题1"成立。**

这是因为，任意的正整数$n$，都包含在区间$[n_k,n_{k+1})$当中也就是$$a^k-1<\lfloor a^{k}\rfloor\leq n<\lfloor a^{k+1}\rfloor\leq a^{k+1}$$
再由于$Y_i\geq 0$，于是因为$T_i$的单调性有$$\frac{T_n}{n}\leq \frac{T_{n_{k+1}}}{n}\leq \frac{T_{n_{k+1}}}{n_{k+1}}\frac{n_{k+1}}{n}$$
如果我们两边取上极限，由于我们得到$$\limsup_{n\to\infty}\frac{T_n(\omega)}{n}\leq E(X_1)a$$几乎处处成立。同样的道理我们也可以得到
$$E(X_1)\frac{1}{a}\leq \liminf_{n\to\infty}\frac{T_n(\omega)}{n}$$
也就是说序列的上极限与下极限的商介于区间$[1,a^2]$之间。然而别忘了，一开始我们构造子列的时候，$a>1$是任取的，这便意味着上确界等于下确界。

* 这种用子列替代原本序列的做法，还可以参考[[通过子列的收敛性验证单调增加的函数列的收敛性#2.2 为什么该子列的收敛性可以过渡到序列本身的收敛性?]]中的"命题2"。

#### 2.2 证明这样的子列的收敛性

现在唯一的目标就是证明这样的子列也是收敛的。

> [!tip] 想法
> 整个证明采取的是[[加强收敛性质的条件与手段]]当中提到的做法，即**先验证依测度收敛，然后加强集中不等式的精度，以至于可以借助Borel-Cantelli引理把收敛性提升至几乎处处收敛。**

1. **是否依照测度收敛?**

其实也就是要估计$$P(|T_{n_k}-E(T_{n_k})|\geq \varepsilon n_{k})$$借助下面这个引理的情况下，我们倒是不难确认依照测度收敛。

> [!note] 引理2
> $$\sum_{k\geq 1} V(Y_k)/k^2\leq 4E(|X_1|)<\infty$$

于是显然我们可以借助$L^2$版本的Chebyshev不等式来完成，于是$$\begin{aligned}P(|T_{n_k}-E(T_{n_k})|\geq \varepsilon n_{k})&\leq \frac{V(T_{n_k})}{\varepsilon^2 n_k^2}\\&= \frac{\sum_{m\leq n_k}V(Y_{m})}{\varepsilon^2 n_k^2}\end{aligned}$$
这里由于截断后的随机变量依旧保持独立性，以及引理2，我们不难确认依测度收敛这个事实。

2. **如何加强，以至于Borel-Cantelli引理可以实现？**
我们最终的目的是要提高估计精度以至于使得$$\sum_{k\geq 1}P(|T_{n_k}-E(T_{n_k})|\geq \varepsilon n_{k})<\infty$$而我们如果用刚才的集中不等式的话，就等于是需要估计
$\sum_{k\geq 1}\frac{V(T_{n_k})}{\varepsilon^2 n_k^2}$,而我们又知道其中的$V(T_{n_k})$是可以展开为一个新的求和的，因为别忘了$$T_n:=\sum_{i\leq n}Y_i$$这不禁提示我们考虑[[和与积分换序]]当中的换序方法，因为我们把被求和当中的一部分改写为了新的求和，那么接下来就要看看换序以后是否能简化问题。

$$\begin{aligned}\sum_{k\geq 1}\frac{V(T_{n_k})}{\varepsilon^2 n_k^2}&= \frac{1}{\varepsilon^2 }\sum_{k\geq 1}\sum_{m\leq n_k}\frac{V(Y_{m})}{n_k^2}\\&= \frac{1}{\varepsilon^2 }\sum_{k\geq 1}\sum_{m\geq 1}\frac{V(Y_{m})}{ n_k^2}\mathbf{1}_{m\leq n_k}\\&=\frac{1}{\varepsilon^2 }\sum_{m\geq 1} V(Y_{m})\sum_{k\geq 1}\frac{1}{ n_k^2}\mathbf{1}_{m\leq n_k}\\&=\frac{1}{\varepsilon^2 }\sum_{m\geq 1} V(Y_{m})\sum_{n_k\geq m}\frac{1}{ n_k^2}\end{aligned}$$

这里我们交换实际上使用的是Tonelli定理(参考[[Fubini-Tonelli定理的例子与反例]]),我们不去管双重求和是否绝对收敛，只是利用非负性去交换，至于结果，只要交换后的结果是收敛的，那么结果包括交换这个行为本身都是正确的。

这里显然因为随机变量被截断成了$Y_m$，那么自然在有限测度的空间当中，方差$V(Y_m)$都是有限的。所以所有的问题现在只剩下一个，$\sum_{n_k\geq m}\frac{1}{ n_k^2}$的渐近估计是否足以支撑整个级数是收敛的。其实从这里就能看出来，$n_k$的构造就是在此处发挥作用的。此处$$\sum_{n_k\geq m}\frac{1}{ n_k^2}=O(1/m^2)$$
* 这里我们也能看出来为何要取子列。因为倘若是$\sum_{n\geq m}\frac{1}{n^2}$这样没办法保证衰减足够快速，因为这种和只能保证$\Theta(\frac{1}{m})$的衰减速度。

因此上面的级数$\sum_{k\geq 1}\frac{V(T_{n_k})}{\varepsilon^2 n_k^2}$是收敛的，因此Borel-Cantelli引理的条件成立，因此$$\frac{T_{n_k}}{n_k}-\frac{E(T_{n_k})}{n_k}\xrightarrow{a.e. }{0}$$
而我们由控制收敛定理可以知道知道$E(Y_i)\to{E(X_1)}=\mu$，那么$\frac{E(T_{n_k})}{n_k}\to \mu$,如此一来就可以知道$$\frac{T_{n_k}}{n_k}\xrightarrow{a.e. }{\mu}$$