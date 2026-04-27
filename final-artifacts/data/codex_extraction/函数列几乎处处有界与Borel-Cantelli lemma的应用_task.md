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
  - 概率论
---

> [!question] 问题
> $f_n(x)$是定义在$[0,1]$上的可测函数列，并且函数列几乎处处有限，证明存在一个正实数列$c_n$使得
> $$\frac{f_n(x)}{c_n}\to0\text{ a.e. }x$$

### 1. 基于Borel-Cantelli引理的证明

> [!tip] 主要想法
> 按照[[Borel-Cantelli lemma及其应用#1. 此lemma在序列的几乎处处收敛上的应用]]当中常用引理2的想法，我们无非就是需要证明存在一个正实数列$c_n$对某个$\varepsilon_n\downarrow 0$的序列定义$$A_{n}:=\left\{x\in [0,1]:\left|\frac{f_n(x)}{c_n}\right|\geq \varepsilon_n\right\}$$从而使得其Lebesgue测度$m(A_{n})$衰减足够快,以至于$$\sum_{n\geq 1}m(A_{n})<\infty$$而$c_n,\varepsilon_n$自然是要从函数列几乎处处有界这条信息得到。


我们可以把某个函数$f$几乎处处有限表示为某种集合列的上极限的形式。定义$F_k:=\{x\in [0,1]:|f(x)|\geq k\}$,那么$$f \text{ 几乎处处有界}\iff m(\limsup_{k\to \infty}F_k)=0$$那么对于本问题当中的函数列几乎处处有限的条件，我们可以定义
$F_{n,k} :=\{x \in [0,1]:|f_n(x)|\geq k\}$那么我们可以知道$$m(\limsup_{k\to \infty}F_{n,k})=0$$而因为$F_{n,k}$关于$k$是单调下降的，即$F_{n,k+1}\subseteq F_{n,k}$,于是$\cup_{i\geq k}F_{n,k}=F_{n,k}$于是我们还可以知道$$m(F_{n,k})\to 0\text{ as }k\to \infty$$
* 这里需要注意，此处的结论来自于[[测度论的基础概念#1.2 测度的基本性质]]当中的性质4“自上而下的连续性”，这个性质要求我们$F_{n,k}$当中至少要有一个$k$对应的集合是有限测度的，否则会存在反例。而条件中的空间$[0,1]$是有限测度的，因此自然是成立“自上而下的连续性”的性质的。

既然如此，如果我们能选择一个合适的$k$的子列$k_n$，那么"主要想法"当中的计划就有可能被实现。

现在唯一需要担心的问题是，是否存在一个这样的$k_n$使得$m(F_{n,k_n})$收敛到0的速度足够快，以至于满足“主要想法”当中Borel-Cantelli引理的要求？这个担忧是多余的，因为[[用子列来提升收敛或发散性质#1.2 收敛中蕴含着收敛更快的子列]]当中的想法告诉我们，既然$m(F_{n,k})\to 0$，那么我们可以找到一个子列收敛得更快。令$k_n$是$k$的子列，使得：$$F_{n,k_n} :=\left\{x \in [0,1]:|f_n(x)|\geq
k_n\right\},m(F_{n,k_n})<\frac{1}{2^n}$$而这就是我们在"主要想法"当中所期待的那个$A_n$,因为:
1. 其测度形成的级数是收敛的，$$\sum_{n\geq 1}m(F_{n,{a_n}})\leq \sum_{n\geq 1}\frac{1}{2^n}<\infty$$
2. 其满足问题中的要求，因为它可以被改写为$$F_{n,k_n} =\left\{x
\in [0,1]:\left| \frac{f_n(x)}{nk_n}\right| \geq
\frac{1}{n}\right\}$$此时我们相当于令$c_n=nk_n,\varepsilon_n=\frac{1}{n}$

于是最终我们得到结论$$\frac{|f_n(x)|}{nk_n}\xrightarrow{a.e.}0$$


