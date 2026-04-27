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
  - 数论
  - 丢番图逼近
---
> [!note] 定义1
> 定义可以被$\psi$逼近的($\psi$-approximable)实数的集合$$A_{\psi}:=\{x\in \mathbb{R}:||qx||<\psi(q) \text{ for infinitely many }q \in \mathbb{N}\}$$其中$||qx||:=\min\{|qx-p|:p\in\mathbb{Z}:\}$。

> [!note] Khintchine定理(1924)
> 令$\psi:\mathbb{N}\to \mathbb{R}_{>0}$是一个单调减少的函数，$m$表示实数的Lebesgue测度，那么:
> 1. 如果$\sum_{q\geq 1}\psi(q)<\infty$那么$m(A_{\psi}\cap [0,1])=0$
> 2. 如果$\sum_{q\geq 1}\psi(q)=\infty$那么$m(A_{\psi}\cap [0,1])=1$

* 因为集合$A_{\psi}$进行整数的平移是不变的，而对于Lebesgue测度而言其是平移不变的，因此我们会发现$A_{\psi}\cap [1,2]=(A_{\psi}+1)\cap ([0,1]+1)=A_{\psi}\cap [0,1]+1$因此$$m(A_{\psi}\cap [1,2])=m(A_{\psi}\cap [0,1])$$所以整个关于$A_{\psi}$的测度问题都可以转换到$A_{\psi}\cap [0,1]$当中去考虑。这样做是有一定的好处的，因为$[0,1]$上的Lebesgue测度是一个概率空间，我们就可以借助概率空间当中的工具来解决问题。
* 此定理的结果意味着，如果函数$\psi$在正整数上取值形成的级数是收敛的，那么几乎所有的实数都是不可以被$\psi$逼近的。否则如果级数发散，那么几乎所有点都是可以被$\psi$逼近的。
* 我们可以把[[无理测度的定义以及基本的命题#1.3 无理测度严格大于2的实数其Lebesgue测度为0]]里面的"命题1.3"，即无理测度严格大于2的实数Lebesgue测度为0，理解为是该定理的一个推论。因为我们可以假设$\psi(q)=q^{-(1+\varepsilon)}$于是如果一个实数$x$是$\psi$可逼近的，那么这也就意味着其无理测度至少是2，反之亦然。因此根据Khintchine的结果，因为$\sum_{q\geq 1}q^{-(1+\varepsilon)}$是收敛的，因此对应的$A_{\psi}$是零测度的，也就证明了"命题1.3"。回顾"命题1.3.1"当中原本的主要策略就是Borel-Cantelli引理(参考[[Borel-Cantelli lemma及其应用]]),那么容易想到Khintchine定理也可以借助这样的工具。

### 1. 级数收敛的情形

整个思路是仿照[[无理测度的定义以及基本的命题#1.3 无理测度严格大于2的实数其Lebesgue测度为0]]当中的“命题1.3”。我们可以定义$E_{q}:=\{x\in [0,1):||qx||<\psi(q)\}$,此时我们注意到$$x\in A_{\psi}\cap [0,1]\iff x\in E_q \text{ i.o.}$$也就是说$$A_{\psi}\cap [0,1]=\limsup_{q\to \infty} E_q$$想要搞清楚这种集合的是不是零测度的，我们可以借助Borel-Cantelli引理去完成。我们首先需要估计$m(E_q)$,几乎是[[无理测度的定义以及基本的命题#1.3 无理测度严格大于2的实数其Lebesgue测度为0]]当中一摸一样的分析，$$E_q=[0,1]\cap \bigcup _{p=0}^{q}\left[\frac{p-\psi(q)}{q},\frac{p+\psi(q)}{q}\right]$$那么$m(E_q) = O\left(\psi(q)\right)$，因此$$\sum_{q\geq 1}m(E_q)=O\left(\sum_{q\geq 1}\psi(q)\right)$$因此只要关于$\psi$的级数是收敛的，那么就能得到$\sum_{q\geq 1}m(E_q)$的收敛性，因此由Borel-Cantelli引理就能得到$\limsup_{q\to \infty} E_q$是零测度的。


### 2. 级数发散的情况




