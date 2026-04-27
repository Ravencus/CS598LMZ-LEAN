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
在概率论当中有这样一些不同的收敛，他们在一般意义下互相之间的关系如图
![[概率的各种收敛以及相互关系.png]]
这里说的弱，主要指的是依照概率测度收敛是比较弱的收敛，也就是这种收敛的结论比较弱，不够强力。或者说我们可以从别的收敛条件当中导出依照概率测度收敛。

在一般的测度论当中，我们知道$L^p$收敛会强于依测度收敛，但是在有限测度的意义下，几乎处处收敛(概率论当中称之为"几乎肯定"almost surely)也是可以导出依照测度收敛的，这是由[[Borel-Cantelli lemma及其应用]]导致的，详细参见[[有限测度空间上依测度收敛的等价命题]]。

> [!note] 弱大数定律
> 假设$X_1,...,X_n,...$是独立同分布的随机变量，并且$E|X_1|<\infty$那么令$S_n = X_1+...+X_n,\mu=E(X_1)$,那么有$$\frac{S_n}{n}\xrightarrow{P}{\mu}$$

**所谓“某种意义下的强大数定律”实际上指的是如果添加一些额外的条件，我们可以把弱大数定律升级为强大数定律，即几乎处处收敛的情形。**

那么这个版本的**额外条件就是四次矩的存在性，即$E|X_1|^4<\infty$**。在有限测度的空间里面，我们知道当我们考虑$L^p,p\geq 1$模的时候，如果$p_1<p_2$这意味着$$||X_1||_{p_1}\leq C||X_1||_{p_2}$$这里$C$与整个测度空间的大小有关，如果是概率测度这样的单位测度，则可以直接得到$$||X_1||_{p_1}\leq ||X_1||_{p_2}$$
因此这里的四次矩存在，意味着$L^4$的模是有限的，这个模要比$L^1$模要大，它本身就蕴含了弱大数定律的条件，但不仅仅如此，我们还可以导出强大数定律。

> [!note] 一种版本的强大数定律
> 假设$X_1,...,X_n,...$是独立同分布的随机变量，并且$E|X_1|^4<\infty$那么令$S_n = X_1+...+X_n,\mu=E(X_1)$,那么有$$\frac{S_n}{n}\xrightarrow{\text{ a.e. }}{\mu}$$

### 1. 此版本的强大数定律灵感的来源


> [!tip] 基本想法
> 欲得到$A_n$收敛到$A$的结果，先得到一个弱一些的收敛(比如依测度收敛)，然后想办法把这个结果加强(比如加强到一致，$L^p$或者几乎处处)。

关于$\frac{S_n}{n}\xrightarrow{P}{\mu}$的这种较弱的收敛我们已经通过Chebyshev不等式证明了所谓的"弱大数定律"。现在我们假设额外的条件想办法来加强这个不等式。

不失一般性假设期望为$0$或者说考虑$X_n'=X_n-\mu$,并且在方差存在的基础上，我们有这样的推断：
$$\begin{aligned}P\left(\left\{\omega:\left|\frac{S'_n(\omega)}{n}\right| >\varepsilon\right\}\right) &\leq P\left(\left\{\omega:\left|\frac{S'_n(\omega)}{n}\right|^2 >\varepsilon^2\right\}\right) \\ &\le \frac{V(S'_n)}{n^2\varepsilon^2}=\frac{V(X_1')}{n\varepsilon^2}\to 0\end{aligned}  $$
因此得到依照概率收敛的结论。

受到这样思路的启发，我们想到既然假设$E(|X_1|^2)<\infty$的时候，弱估计差不多到了$O(n^{-1})$的级别，我们会想，如果这个估计不是$O(n^{-1})$而是更好的$O(n^{-p}),p>1$这样的话我们就可以用Borel-Cantelli lemma给出$$P\left(\limsup_{n\to\infty}\left\{\omega:\left|\frac{S'_n(\omega)}{n}\right| >\varepsilon\right\}\right) =0$$
按照[[Borel-Cantelli lemma及其应用]]关于拓展版本的lemma1的分析，这意味着$$\frac{S'_n(\omega)}{n}\xrightarrow{\text{ a.e. }}{0}$$
于是便有这样的想法：

> [!tip] 用Borel-Cantelli引理升级依测度收敛的想法
> 想要把依测度收敛的结果升级到几乎处处收敛，在某些情况下是可行的。比如说这种测度的弱的估计足够好，好到可以满足Borel-Cantelli引理，那么便可以把依测度收敛升级为几乎处处收敛。

### 2.证明本文意义下的强大数定律
在$E|X_1|^4<\infty$的基础,不失一般性假设期望为$0$或者说考虑$X_n'=X_n-\mu$,上我们现在想要给
$$\begin{aligned}P\left(\left\{\omega:\left|\frac{S'_n(\omega)}{n}\right| >\varepsilon\right\}\right) &\leq P\left(\left\{\omega:\left|\frac{S'_n(\omega)}{n}\right|^4 >\varepsilon^4\right\}\right) \end{aligned}  $$
一个更好的上界估计。

$$E(S_n^{'4}) = E \left( \sum_{i=1}^{n} X'_i \right)^4 = E\left( \sum_{1 \leq |\alpha| \leq 4} \binom{4}{\alpha_1,...,\alpha_n}X_1^{'\alpha_1} \cdots X_n^{'\alpha_n}\right)
$$
这里我们使用了多重指标的记号，$\alpha = (\alpha_1,...,\alpha_n)$然后$|\alpha| =\alpha_1+...+\alpha_n$.此外每一项系数由多项式定理(视为二项式定理的多元推广)给出，$$\binom{4}{\alpha_1,...,\alpha_n} = \frac{4!}{\alpha_1!\cdots\alpha_2!}$$
因为独立性的假设(这就是为何这些结论独属于概率论)，因为$E(X'_{i})=0$因此但凡一项里面单独出现某个随机变量，那么这一项的期望一定是0.如此一来最后剩下来的只有$E(X_i^{'4}),E(X_i^{'2}X_j^{'2})$,那么只需要统计有多少个这样的结果就行。

1. 每一个形如$X_i^{'4}$的项其系数应该是$\binom{4}{0...,4,...0}=1$不过这里我们因为假设这些随机变量都是独立同分布的，那么在期望的意义下，我们同样不区分$X_i^{'4}$的期望。这样形式的项一共有$\binom{n}{1}=n$个，于是所有形如这样的项目的期望的总和为$$nE(X_1^{'4})$$
2. 形如$E(X_i^{'2}X_j^{'2})$的项目一共有$\binom{n}{2}=\frac{n(n-1)}{2}$种，每一种情况下其系数为$\binom{4}{0,...,2,...,2,...,0}=\frac{4!}{2!2!}=6$,因此在独立同分布的假设下，期望的总和为$$3n(n-1)E(X_1^{'2})^2$$
综上所述，$$E(S_n^{'4}) = nE(X_1^{'4})+3n(n-1)E(X_1^{'2})^2=O(n^2)$$
那么结合之前的论述，$$\begin{aligned}P\left(\left\{\omega:\left|\frac{S'_n(\omega)}{n}\right| >\varepsilon\right\}\right) &\leq P\left(\left\{\omega:\left|\frac{S'_n(\omega)}{n}\right|^4 >\varepsilon^4\right\}\right) \\ &=O\left(\frac{1}{n^2}\right) \end{aligned}  $$
当然正如[[样本期望的渐近展开系数]]当中提到的Marcinkiewicz-Zygmund不等式,实际上这里条件完全可以减弱到$E|X_1|^r,r>2$的情况，因为这样一来$P\left(\left\{\omega:\left|\frac{S'_n(\omega)}{n}\right|^{r} >\varepsilon^{r}\right\}\right)=O(1/n^{r/2})$，而后者就足以使用第二Borel-Cnatelli引理了。

总而言之，如此一来便可以使用Borel-Cantelli lemma,因为$$\sum_{n\geq 1} P\left(\left\{\omega:\left|\frac{S'_n(\omega)}{n}\right| >\varepsilon\right\}\right)<\infty$$

于是可以得到
$$\frac{S'_n(\omega)}{n}\xrightarrow{\text{ a.e. }}{0}$$

### 3.强大数定律最多能把期望的条件减弱到多少？

极端一点，能否直接把期望的存在性给去掉？然而根据[[Borel-Cantelli lemma及其应用]]当中的第二lemma，在独立性的基础上，如果期望是无穷的，即随机变量是不可积的那么$\frac{S_n}{n}$在几乎处处的意义下是不存在的或者非有限的。即强大数定律不可能成立。

> [!note] 期望存在性对强大数定律的存在性是必要的
> 如果$X_1,...,X_n,...$是独立同分布的随机变量，并且$E|X_1|=\infty$，假设$S_n = X_1+...+X_n$,那么$$P\left(\left\{\omega:\lim_{n\to \infty}\frac{S_n}{n} \text{ exists}\in(-\infty,+\infty)\right\}
> \right)=0$$

证明的主要思路是：
1. $E|X_1|=\infty$可以推出$P(|X_n|\geq n \text{ i.o.})$
2. 假设$A=\left\{\omega:\lim_{n\to \infty}\frac{S_n}{n} \text{ exists}\in(-\infty,+\infty)\right\}$我们发现$A \cap \{\omega:|X_n|\geq n \text{ i.o.}\} = \varnothing$因为如果交集里面有元素，会导致与$\omega \in A$即极限存在并有限产生矛盾。进一步因为$A \subseteq \{\omega:|X_n|\geq n \text{ i.o.}\}^{c}$那么$P(A)\leq0$,于是$A$零测度。

第一部分的技术是来自于把积分表达为分布函数的积分，然后利用被积函数的单调性给出一个求和的上界。

$$E|X_1|=\int_{0}^{\infty}P(|X_1|>t)\,dt\leq \sum_{n\geq 0}P(|X_1|> n)$$
这里注意到，随机变量是独立同分布的，因此$P(|X_1|> n)=P(|X_n|>n)$。然后由第二Borel-Cantelli lemma指出，$P(|X_n|> n \text{ i.o.})=1$.

然后第二部分的矛盾出现在，如果某个$\omega$使得$\lim_{n\to \infty}\frac{S_n(\omega)}{n} \text{ exists}\in(-\infty,+\infty)$那么由柯西收敛判定，$\forall \varepsilon>0$都存在足够大的$N_{\varepsilon}$使得$n>N_{\varepsilon}$满足$$\left|\frac{S_n}{n}-\frac{S_{n+1}}{n+1}\right|=\left|\frac{S_n}{n(n+1)}-\frac{X_{n+1}}{n+1}\right|<\varepsilon$$
由于$S_n/n$极限存在并且有界，那么对于足够大的$n$这是有界的，这意味着$S_{n+1}/(n(n+1))$是$o(1)$的量。但矛盾的地方在于，因为$\omega$又同时属于$\{\omega:|X_n|> n \text{ i.o.}\}$于是对于足够大的$n$一定有$$\left|\frac{X_{n+1}}{n+1}\right|>\frac{2}{3} \text{ i.o.}$$
这显然与上面的不等式是矛盾的，所以实际上这个交集不存在。
