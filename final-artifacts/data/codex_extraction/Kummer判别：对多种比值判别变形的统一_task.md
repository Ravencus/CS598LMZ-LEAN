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
  - 考研
  - 大学数学竞赛
---

> [!note] 定理0:Kummer判别（19世纪）
> 对于正项级数$\sum_{n\geq 1}a_n$，以及一个辅助序列$\xi_n>0$定义$$\rho_n:=\xi_n\frac{a_n}{a_{n+1}}-\xi_{n+1}$$假设$\rho_n$极限存在并且为$\rho$那么：
> 1. 如果$\rho>0$那么级数收敛。
> 2. 如果$\rho<0$并且$\sum_{n\geq 1}\frac{1}{\xi_n}$发散，那么级数发散。
* 为了应对$\rho$并不存在的情况，Kummer判别还可以扩展为：
   1. 如果$\liminf_{n\to \infty }\rho_n >0$原级数收敛。
   2. 如果$\limsup_{n\to \infty }\rho_n <0$，同时$\sum_{n\geq 1}\frac{1}{\xi_n}$发散，那么级数发散。
* 对应视频[【会员提问】Kummer判别是怎么回事](https://www.bilibili.com/video/BV1e8dGYTEFg/).
### 1. Kummer判别的历史背景

在18世纪的时候d'Alembert给出了级数收敛的比值判别法(ratio test)，不过后来人们发现了这个判别法的弱点，当$$L:=\lim_{n\to \infty} \left|\frac{a_{n+1}}{a_n}\right| =1$$的时候比值判别法就无法判断级数收敛与否。比如典型的：$$\sum_n 1,\sum_n \frac{1}{n^2}$$
于是为了处理比值判别法在$L=1$时候失效的情况，后来一系列数学家对比值判别法进行了扩展。

比如19世纪早期，瑞士数学家Raabe给出了他的判别：

> [!note] 定理1.1：Raabe's test
> 对于正项级数$\sum_n a_n$定义$$R_n:= n\left(\frac{a_n}{a_{n+1}}-1\right)$$如果$R_n$极限存在并且为$L$，那么
> 1. 如果$L>1$那么级数收敛。
> 2. 如果$L<1$那么级数发散。

* 对于级数$\sum_{n\geq 1}\frac{1}{n^p}$而言，$$R_n=n\left(\frac{(n+1)^p}{n^p}-1\right)=\frac{(1+\frac{1}{n})^p-1}{\frac{1}{n}}$$于是我们知道，对于$p>0$，$R_n\to p$。也就是说，如果$p>1$按照Raabe判别，级数收敛，而如果$p<1$级数发散。
* Raabe判别就是告诉我们，如果$\frac{a_n}{a_{n+1}}=1+o(1)$那么d'Alembert判别无法告诉我们收敛与否。但这没关系，如果我们可以得到更详细的渐近展开$$\frac{a_n}{a_{n+1}}=1+\frac{L}{n}+o(\frac{1}{n})$$那么渐近展开$\frac{1}{n}$的这一项系数与$1$之间的关系能决定正项级数是否收敛。当然$L=1$的时候，收敛与发散性质还需要进一步考察更精确的余项的信息来决定。

下面我们看一个Raabe判别真正能发挥用处的例子：

> [!example] 例子1.2
> 如果我们要级数$\sum_{n\geq 1}\frac{(2n-1)!!}{(2n)!!}\frac{1}{2n+1}$的收敛与发散性。
> 
> 首先，因为$a_n$是具有明显的乘法结构的，因此自然会想要考虑比值判别法。然而直接尝试我们就会发现$$\frac{a_n}{a_{n+1}}=\frac{2n+2}{2n+1}\frac{2n+3}{2n+1}\to 1$$因此d'Alembert的判别失效了。不过由于$$\frac{a_n}{a_{n+1}}=1+\frac{3}{2}\frac{1}{n}+O(1/n^2)$$于是Raabe判别法告诉我们由于$\frac{1}{n}$这一项的渐近系数$\frac{3}{2}>1$于是级数收敛。

* 如果我们稍微修改一下“例子1.2”，把要考虑的级数变成$$\sum_{n\geq 1}\frac{(2n-1)!!}{(2n)!!}\frac{4n+3}{2n+2}$$那么由于$$\frac{a_n}{a_{n+1}}=1+\frac{1}{2}\frac{1}{n}+O(1/n^2)$$那么Raabe判别又会告诉我们，此时级数发散。

那么既然是考虑$\frac{a_{n+1}}{a_n}$的渐近展开的渐近系数，那么倘若$$\frac{a_n}{a_{n+1}}=1+\frac{1}{n}+o(1/n)$$也就是当Raabe判别失效的时候，我们又当如何？下面是Gauss给出的回答：

> [!note] 定理1.3：Gauss's test
> 对于正项级数$\sum_n a_n$，如果$$\frac{a_n}{a_{n+1}}=1+\frac{1}{n}+O\left(\frac{1}{n^r}\right),r>1$$那么级数发散。


> [!example] 例子1.4
> 级数$\sum_{n\geq 1}\frac{n!e^n}{n^{n+p}}$在$p>\frac{3}{2}$的时候是收敛的，$p\leq \frac{3}{2}$的时候是发散的。首先，因为级数的$a_n$具有明显的乘法结构，因此考虑比值判别法。经过上面的分析我们知道，比值判别的精髓在于给出$\frac{a_n}{a_{n+1}}$的渐近展开，此处$$\frac{a_n}{a_{n+1}}= 1+(p-1/2)\frac{1}{n}+O(1/n^2)$$于是结合目前已知的比值判别法：
> 1. $p>\frac{3}{2}$的时候，由于$p-1/2>1$那么Raabe判别告诉我们，级数收敛。
> 2. $p=\frac{3}{2}$的时候因为$p-1/2=1$那么根据Guass判别，级数发散。
> 3. $p<\frac{3}{2}$的时候因为$p-1/2<1$那么Raabe判别告诉我们，级数发散。

那么如果$$\frac{a_n}{a_{n+1}}=1+\frac{1}{n}+r_n$$其中虽然$r_n = o(1/n)$，但是却衰减比任意的$\frac{1}{n^r},r>1$都慢，此时Gauss判别也失效了，我们又该如何？这时候Bertrand和De Morgan给出了他们的答案：

> [!note] 定理1.5:Bertrand-De Morgan's test
> 对于正项级数$\sum_n a_n$，并且$$\frac{a_n}{a_{n+1}}=1+\frac{1}{n}+\frac{L}{n\log(n)}+o\left(\frac{1}{n\log(n)}\right)$$
> 那么：
> 1. 如果$L>1$那么级数收敛。
> 2. 如果$L<1$那么级数发散。


> [!example] 例子1.6：Bertran级数
> 正项级数$$\sum_{n\geq 2}\frac{1}{n^{\alpha}\log(n)^{\beta}}$$称之为Bertrand级数。此级数的收敛&发散性与参数$\alpha,\beta$的关系如下：
> 1. $\alpha >1$的时候无论$\beta$是多少，级数收敛。
> 2. $\alpha<1$的时候无论$\beta$是多少，级数发散。
> 3. $\alpha=1$的时候，级数收敛当且仅当$\beta>1$。
> 
> 此处我们只关注第三条，考虑证明级数$\sum_{n\geq 2} \frac{1}{n\log(n)^{\beta}}$的收敛&发散性质。其中$\beta\leq 0$的时候级数显然发散，现在考虑$\beta>0$，此时$$\begin{aligned}\frac{a_n}{a_{n+1}}&=\frac{n+1}{n}\left(\frac{\log(n+1)}{\log(n)}\right)^{\beta}\\&=\frac{n+1}{n}\left(1+\frac{1}{n\log(n)}+O\left(\frac{1}{n^2\log(n)}\right)\right)^{\beta}\\&=\frac{n+1}{n} \left(1+\frac{\beta}{n\log(n)}+O\left(\frac{1}{n^{2\beta}\log(n)^{\beta}}\right)\right)\\&= 1+\frac{1}{n}+\frac{\beta}{n\log(n)}+O\left(\frac{1}{n^{2\beta}\log(n)^{\beta}}\right)\end{aligned}$$那么Bertrand判别告诉我们当$\beta>1$的时候级数是收敛的，$\beta<1$的时候级数是发散的。至于$\beta=1$的时候，级数$\sum_{n\geq 2} \frac{1}{n\log(n)}$的发散性，我们可以利用[[柯西凝聚判别法]]或者[[和的积分估计#1. 和的简单积分估计]]来进行判断。当然整个Bertrand级数我们都可以用以上两种基于和的估计的方法来解决，而不用考虑比值判别。

最后，Kummer 于19世纪中期，利用“定理1”统一了以上的比值判别。
1. 比值判别：令$\xi_n =1$，$$\rho_n=\frac{a_n}{a_{n+1}}-1$$如果此序列$\frac{a_n}{a_{n+1}}$极限存在为$L$，如果$L>1$也就是Kummer判别中$\rho>0$于是级数收敛，而如果$L<1$就是Kumer判别中$\rho<0$，此时$\sum_n \frac{1}{\xi_n}=\sum_n 1$是一个发散的级数，于是根据Kumer判别原本的级数也发散。于是我们便得到了比值判别。
2. Raabe判别：令$\xi_n = n$，$$\begin{aligned}\rho_n&=n\frac{a_n}{a_{n+1}}-(n+1)\\&=n\left(\frac{a_n}{a_{n+1}}-1\right) -1 \end{aligned}$$如果此序列$n\left(\frac{a_n}{a_{n+1}}-1\right)$极限存在为$L$，如果$L>1$也就是Kummer判别中$\rho>0$于是级数收敛，而如果$L<1$就是Kumer判别中$\rho<0$，此时$\sum_n \frac{1}{\xi_n}=\sum_n \frac{1}{n}$是一个发散的级数，于是根据Kumer判别原本的级数也发散于是级数发散。于是我们便得到了Raabe判别。
3. Bertrand判别：令$\xi_n = n\log(n)$,$$\begin{aligned}\rho_n&=n\log(n)\frac{a_n}{a_{n+1}}-(n+1)\log(n+1)\\&= \log(n)\left[n\left(\frac{a_n}{a_{n+1}}-1\right)-1\right]+(n+1)\log\left(1-\frac{1}{n+1}\right)\\&\end{aligned}$$如果$\log(n)\left[n\left(\frac{a_n}{a_{n+1}}-1\right)-1\right]$的极限存在并且为$L$，如果$L>1$也就是Kummer判别中$\rho>0$于是级数收敛，而如果$L<1$就是Kumer判别中$\rho<0$,此时$\sum_n \frac{1}{\xi_n}=\sum_n \frac{1}{n\log(n)}$是一个发散的级数，于是根据Kumer判别原本的级数也发散于是级数发散。于是我们便得到了Bertrand判别。
4. Gauss判别：我们依旧令$\xi_n = n\log(n)$，由上面的推导我们知道$$\begin{aligned}\rho_n= \log(n)\left[n\left(\frac{a_n}{a_{n+1}}-1\right)-1\right]+(n+1)\log\left(1-\frac{1}{n+1}\right)\\&\end{aligned}$$此时按照高斯判别的假设，存在$r>1$使得$$\frac{a_n}{a_{n+1}}=1+\frac{1}{n}+O\left(\frac{1}{n^r}\right)$$那么$\rho_n$的极限存在且为$-1$,此时$\sum_n \frac{1}{\xi_n}=\sum_n 1$是一个发散的级数，于是根据Kumer判别原本的级数也发散。

### 2. Kummer判别的证明

下面我们证明Kummer判别法：

首先按照假设$\rho_n$的极限存在假设为$\rho$，如果$\rho>0$，那么也即是说存在一个$c>0$，以及一个正整数$N$使得任意$n>N$都有$\rho_n>c$，也就是说$$\xi_n\frac{a_n}{a_{n+1}}-\xi_{n+1}>c$$因为$a_n$是正项级数，于是
$$\xi_na_n -\xi_{n+1}a_{n+1}>ca_{n+1}>0$$

也就是说我们得到了序列$a_{n+1}$的一个上界估计，那么我们想到了[[逐项估计]]，如果上界组成的级数收敛，那么级数$\sum_n a_n$自然收敛。而上界的级数实际上是序列$\xi_n a_n$的差分，根据[[序列差分的估计蕴含着序列本身的估计]]当中的想法，如果$\xi_na_n$的极限存在，那么其差分的级数也是收敛的。而$\xi_n a_n$，这个序列当$n>N$的时候是单调减少的，并且具有下界$0$，于是这个序列的极限是存在的。于是级数$\sum_n a_n$收敛。

反过来，如果$\rho<0$，那么存在一个$c<0$，以及一个正整数$N$使得任意$n>N$都有$\rho_n<c<0$，仿照上面的操作得到$$\xi_na_{n}-\xi_{n+1}a_{n+1}<ca_{n+1}<0$$此时我们知道$\xi_na_n$是一个单调增加的序列。不过这个时候，单凭这一点，我们还无法得到级数$\sum_n a_n$的发散性。因此我们需要添加一个条件，这也就是为何Kummer判别第二条当中需要$\sum_n \frac{1}{\xi_n}$发散的原因。由于，序列$\xi_n a_n$是单调增加的，并且为正实数，于是存在一个下界$\xi_n a_n >r>0$对任意足够大的n成立。于是$$\sum_{n\geq N} a_n =\sum_{n\geq N} \frac{a_n\xi_n}{\xi_n}\geq r\sum_{n\geq N} \frac{1}{\xi_n}$$后者发散，因此原本的级数也是发散的。


此外，结合证明过程以及[[函数与序列的上下极限]]中的“命题1.1”，对于$\rho_n$极限不存在的时候，我们可以把Kummer判别法改成：

1. 如果$\liminf_{n\to \infty }\rho_n >0$原级数收敛。
2. 如果$\limsup_{n\to \infty }\rho_n <0$，同时$\sum_{n\geq 1}\frac{1}{\xi_n}$发散，那么级数发散。
