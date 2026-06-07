# Description-Idea — racket-cn Design Rationale

## 1. `no-translate`: The Translator's Escape Hatch

### 1.1 The Problem

The translator performs wholesale identifier substitution: `定义` → `define`, `hash` → `哈希`.
This is correct under one premise — every identifier in the code belongs to the
evaluable namespace.

But `quote` breaks that premise. The same syntactic form has different identities
in different contexts:

```racket
;; Case A: 'hash is a hash-table key (data)
(hash 'hash 'a 'bash 'b)

;; Case B: '(哈希 'a 'b) will be passed to eval (code)
(eval '(哈希 'a 'b))
```

In Case A, `'hash` should remain the symbol `hash`. In Case B, `'哈希` must become
`'hash` for `eval` to work in standard Racket.

The translator only receives a bare syntax tree — it sees two `(quote ...)` forms
but cannot know one flows into a hash constructor while the other flows into `eval`.
This is an inherent limitation of static analysis (equivalent to the halting problem).

### 1.2 The Discussion

We first considered a "conservative strategy" — never translate inside `quote`.
The rationale: most `quote` usage is indeed data (hash keys, symbol constants,
configuration tables); `eval` scenarios are rarer.

But `#lang racket-cn` itself refutes this:

```racket
#lang racket-cn
(eval '(哈希 'a 'b))     ;; works — '哈希 is symbol 哈希, bound to 哈希 function
```

Inside the CN environment, `'哈希` is the symbol `哈希`, and evaluation finds it
in the Chinese namespace. After translation to standard Racket, if `'哈希` were
preserved as `'哈希`, `eval` would search for symbol `哈希` in the standard Racket
namespace — not found, failure. Therefore the translator **must** translate `'哈希`
to `'hash`. Aggressive full translation is semantically correct.

Since the default behavior is correct, the remaining question is: when does the
user need "don't translate"?

Answer: when a symbol is used purely as a data key that happens to share a name
with a Racket function. In `(hash 'hash 'a)`, `'hash` is a key, not a function
call — translating it to `'哈希` corrupts the data.

### 1.3 The Design

A compile-time annotation: `no-translate`.

```racket
(hash (no-translate 'hash) 'a
      (no-translate 'bash) 'b)
```

When the translator encounters `(no-translate expr)`:
1. Strip the `no-translate` wrapper
2. Return `expr` untouched — no identifier substitution

After translation:
```racket
(哈希 'hash 'a
      'bash 'b)
```

`no-translate` is explicit and local — it does not affect other code and never
appears in output.

### 1.4 Implementation

In the translator's recursive syntax-tree walker, a literal pattern is added
before the generic pair case in `syntax-case`:

```racket
(syntax-case stx (no-translate)
  ;; (no-translate expr) → return expr directly, no recursive translation
  [(no-translate expr)
   #'expr]
  [(a . d)
   ;; ... normal recursive translation ...])
```

`(no-translate expr)` takes priority over the generic `(a . d)` match.
`no-translate` itself is absent from the identifier mapping table, so it is
never translated and is recognized in both directions.


## 2. `kw.rkt`: The Keyword Argument Translation Macro

### 2.1 Why `rename-out` Is Not Enough

`rename-out` is racket-cn's core mechanism for translating ordinary identifiers:

```racket
(provide (rename-out [define 定义]
                     [lambda 函数]))
```

This redirects `定义` to `define`, `函数` to `lambda`. But it works **only for
identifiers**.

Racket keyword arguments (`#:exists`, `#:mode`, etc.) belong to a distinct
syntactic category from identifiers. `rename-out` cannot rename keywords, because
keywords are parsed as keyword arguments by the expander and do not participate
in identifier binding. So `(rename-out [#:exists #:如果存在])` is impossible.

This means: you cannot simply let users write
`(打开输出文件 "a.txt" #:如果存在 '截断)` and map it to
`(open-output-file "a.txt" #:exists 'truncate)` through renaming alone.

### 2.2 The Design

`定义-关键字函数` does one thing: **define a macro that, at compile time, rewrites
calls with Chinese keyword arguments into calls with English keyword arguments**.

The user writes a single line:

```racket
(定义-关键字函数 打开输出文件 open-output-file
  (#:如果存在 #:exists (截断 truncate) (替换 replace))
  (#:模式   #:mode   (文本 text)))
```

This expands into a `define-syntax` named `打开输出文件`. When code contains:

```racket
(打开输出文件 "a.txt" #:如果存在 '截断 #:模式 '文本)
```

The macro walks the argument list, translating:
- Keyword `#:如果存在` → `#:exists`
- Keyword `#:模式` → `#:mode`
- Quoted value `'截断` → `'truncate` (only when it follows `#:如果存在`)
- Quoted value `'文本` → `'text` (only when it follows `#:模式`)

Then packages the arguments into a call to the English function:

```racket
(open-output-file "a.txt" #:exists 'truncate #:mode 'text)
```

### 2.3 Structure of the Generated Macro

`定义-关键字函数` is essentially a **macro generator** — it reads a declarative
specification and emits `define-syntax` code. The expanded macro contains three
key components:

**kw-map — keyword mapping table**

`((#:如果存在 . #:exists) (#:模式 . #:mode))`

When walking arguments, keywords are looked up in this table and replaced if found.

**val-map — keyword value mapping table**

`((#:exists ((截断 . truncate) (替换 . replace))) (#:mode ((文本 . text))))`

Each translated keyword is associated with a value mapping. When the walker
encounters a quoted symbol that follows a known keyword, it uses this table to
find the translation.

**The state machine — `k` context**

```racket
(let loop ([rest lst] [k #f] [acc '()])
  (let ([d (syntax->datum (car rest))])
    (cond
      [(keyword? d)
       ;; look up kw-map, record current keyword context k
       ...]
      [(and k (pair? d) (eq? (car d) 'quote) ...)
       ;; with k context active, '截断 → 'truncate (via val-map)
       ...]
      [else
       ;; ordinary arguments pass through unchanged
       ...])))
```

`k` is the critical design element: when `#:如果存在` appears, `k` is set to
`#:exists`. If the next element is `'截断`, `k` is used to find `#:exists`'s
sub-table in `val-map`, then `截断 → truncate` is looked up. After this argument
is processed, `k` is reset to `#f`, preventing interference with subsequent
arguments.

This ensures that in `(打开输出文件 "a" #:如果存在 '截断 #:模式 '文本)`, `'截断`
is translated only in the `#:如果存在` context and `'文本` only in the `#:模式`
context — they never collide.

### 2.4 Why Not a Simpler Approach

Another possible approach: let users write English keywords directly.

```racket
(打开输出文件 "a.txt" #:exists 'truncate)  ;; keyword is already English
```

This is technically feasible — the macro generated by `定义-关键字函数` passes
English keywords through unchanged. But it defeats the purpose of "Chinese Racket"
— if keyword arguments still require English, the language experience is incomplete.
The value of `kw.rkt` is enabling users to write function calls **entirely in
Chinese**, keyword arguments included.

### 2.5 A Theoretical Edge Case

`kw.rkt` only walks top-level arguments — it never recurses into nested expressions.
But on the **top-level plane**, there is a judgment call:

When `(car d)` equals `quote` and the argument immediately follows a known keyword,
the macro treats it as a keyword value and translates it. In all normal usage,
this is correct — in `#:如果存在 '截断`, `'截断` genuinely is a keyword argument.

Translation would fail in this extreme case:

```racket
;; Suppose some function accepts #:如果存在 as a keyword,
;; and the user passes an ordinary argument that happens to
;; be '截断 right after it:
(some-func arg1 #:如果存在 '截断)
```

Here `'截断` is not a keyword value but merely ordinary data coincidentally
following the keyword — yet the macro would translate it to `'truncate`.

However, this is **virtually impossible in practice**, because:
1. `#:如果存在` only appears as a keyword in functions wrapped by
   `定义-关键字函数` (like `打开输入文件`, `打开输出文件`)
2. Those functions have fixed keyword value semantics — `'截断` after
   `#:如果存在` genuinely means `'truncate`
3. No user would use `#:如果存在` in an unrelated function followed by a
   quoted symbol that coincidentally matches a keyword value

Noted here for posterity.
