# 展开器分层 & rename-out 限制分析

## 概要

`racket-cn` 用 `rename-out` 将 300+ 个英文 Racket 标识符映射到中文别名。绝大多数工作正常，但有少量 form 在 `rename-out` 下失效。根因不在 `rename-out` 本身，而在 Racket 展开器**分层处理**的时序——某些 form 在 rename 绑定建立之前就被消费掉了。

---

## 展开器处理流程

```
源代码
  │
  ├─ [Phase 0: Reader]
  │   文本 → syntax 对象（纯符号，无绑定信息）
  │   定义 → 符号 定义
  │
  ├─ [Phase 1: Module-begin 扫描]
  │   遍历模块体顶层 form，按 free-identifier=? 分类：
  │     require-form, provide-form, define-form, begin-form, ...
  │   ⚠ 这一层决定哪些 binding 生效
  │
  ├─ [Phase 2: Binding 解析]
  │   根据 require/provide 建立模块的导入/导出表
  │   rename-out 在这一层生效
  │
  ├─ [Phase 3: 局部展开]
  │   表达式层递归宏展开
  │   所有 phase-0/1 binding 已就绪
  │
  └─ [编译]
```

关键洞察：**Phase 2 的 binding 建立起作用，但 Phase 1 的分类判断在 Phase 2 之前。** 如果某个 form 在 Phase 1 就被消费掉了，那么 Phase 2 的 rename 对它无效。

---

## Phase 1: Module-begin 扫描

展开器用 `free-identifier=?` 把顶层 form 分到这些类别：

| 类别 | 中文名 | Phase 1 free-identifier=? | 结果 |
|------|--------|---------------------------|------|
| `require` | `引用` | ❌ | Phase 1 消费，rename 还没建立 |
| `provide` | `提供` | ✅ | Phase 2 才消费，rename 已生效 |
| `define` | `定义` | ✅ | Phase 3 消费 |
| `define-syntax` | `定义语法` | ✅ | Phase 3 消费 |
| `define-syntax-rule` | `定义语法规则` | ❌ | Phase 1 消费 |
| `define-values` | `定义多值` | ✅ | Phase 3 消费 |
| `begin` | `顺序求值` | ✅ | Phase 3 消费 |

### 为什么 `提供` 能用但 `引用` 不行？

两者在 Phase 1 都通过 `free-identifier=?` 判断。但消费时机不同：

- **`require`-form**：展开器在看到模块体内容之前，先收集所有 `require`，建立 Phase 0/1 的初始绑定表。这个过程发生在模块自身的 `provide`（包括 `rename-out`）生效**之前**。所以 `(引用 ...)` 里的 `引用` 此时还没绑定到 `require`。

- **`provide`-form**：展开器在模块体处理**完毕之后**才收集 `provide`。此时所有 Phase 2 binding 已就绪。

- **`define-syntax-rule`**：同上——展开器在 Phase 1 识别 define-form 并消费。如果 `定义语法规则` 此时还未绑定，识别失败。

### 为什么 `定义`、`定义语法` 能用？

它们的 Phase 1 分类用的是 `free-identifier=?`，而 `free-identifier=?` 检查的是**绑定是否相同**，不是符号字面名。

`定义` 通过 `rename-out` 在 Phase 2 获得和 `define` 相同的 binding 后，`free-identifier=?` 返回 `#t`。但 `引用` 和 `定义语法规则` 在 Phase 1 被检查时 binding 还没建立。

本质是鸡生蛋蛋生鸡：展开器需要先知道哪些是 define-form 才能建立绑定环境，但 `定义语法规则` 这个绑定本身就依赖于这个环境。

---

## `syntax-rules` → `语法规则` 调查

### 最初假设（错误）

README 原本写 "`syntax-rules` 改名后展开器不识别"。实际调查推翻了这一点。

### 实验

```racket
#lang racket/base

;; ✅ Form A (直接 form) — 原版工作
(define-syntax t1
  (syntax-rules () [(_ x) #'x]))

;; ❌ Form B (缩写 form) — 原版也挂！
(define-syntax (t2 stx)
  (syntax-rules () [(_ x) #'x]))
;; → "received value from syntax expander was not syntax"
```

```racket
#lang racket-cn/base

;; ✅ Form A — 改名后同样工作
(定义语法 t3
  (语法规则 () [(_ x) #'x]))

;; ❌ Form B — 改名后同样挂（和原版一致）
(定义语法 (t4 stx)
  (语法规则 () [(_ x) #'x]))
;; → 同名错误
```

### 根因

`(define-syntax (name stx) body)` 是语法糖：
```racket
(define-syntax name (lambda (stx) body))
```

`body` 在 lambda 内部，期望返回 **syntax 对象**。`(syntax-rules ...)` 返回的是 **procedure**（macro transformer），不是 syntax。类型不匹配。

这不是改名问题——原版 `syntax-rules` 一样有这个限制。

### 结论

`语法规则` 在 `rename-out` 下**完全正常工作**，和原版 `syntax-rules` 行为一致。

---

## Phase 3: 表达式层 — 全部工作

所有 binding 已就绪。以下全部通过 `rename-out` 工作：

```racket
;; 核心特殊形式
(定义 x 1)                     ;; ✅
(如果 #t 1 0)                  ;; ✅
(令 ([x 1]) x)                 ;; ✅

;; 宏定义（syntax-case 路径）
(定义语法 (my-or stx)
  (语法匹配 stx ()
    [(_) #'#f]
    [(_ x y ...) #'(令 ([t x]) (如果 t t (my-or y ...)))]))

;; for 循环
(循环/列表 ([x (在范围 5)]) x)  ;; ✅

;; struct
(结构 点 (x y))                 ;; ✅
(点-x (点 3 4))                 ;; ✅

;; match
(匹配 42 [x x])                 ;; ✅

;; class
(类 object% (super-new))        ;; ✅
```

---

## 跨 Phase 绑定: `for-syntax`

`base-impl.rkt` 为 macro writer 提供了 phase-1 绑定：

```racket
(provide (for-syntax (rename-out
  [syntax-case 语法匹配]
  [syntax-rules 语法规则]
  [with-syntax 带语法]
  [quasisyntax 准语法]
  [unsyntax 反语法]
  [syntax 语法]
  [syntax->list 语法->列表]
  [syntax->datum 语法->数据]
  [datum->syntax 数据->语法]
  [syntax-e 语法值]
  [free-identifier=? 自由标识符等同?]
  [bound-identifier=? 绑定标识符等同?]
  [local-expand 局部展开])))
```

这些在 `define-syntax` 体内（phase 1 执行）可以正常使用。

注意：phase 1 只有 `racket/base` 的 for-syntax 提供（英文），中文 IO 函数（如 `显示行`）只在 phase 0 提供，phase 1 不可用。

---

## 总结表

| form | 中文名 | rename-out | 原因 |
|------|--------|-----------|------|
| define | 定义 | ✅ | Phase 3 消费 |
| define-syntax | 定义语法 | ✅ | Phase 3 消费 |
| define-values | 定义多值 | ✅ | Phase 3 消费 |
| lambda | 函数 | ✅ | Phase 3 消费 |
| if/cond/let/... | 如果/条件/令/... | ✅ | Phase 3 消费 |
| struct | 结构 | ✅ | macro 不是 core form |
| match | 匹配 | ✅ | Phase 3 消费 |
| class/new/send | 类/新建/发送 | ✅ | Phase 3 消费 |
| for/for*/... | 循环/循环*/... | ✅ | Phase 3 消费 |
| syntax-case | 语法匹配 | ✅ | Phase 3 消费 (phase 1 提供) |
| with-syntax | 带语法 | ✅ | Phase 3 消费 (phase 1 提供) |
| quote/quasiquote | 引述/准引用 | ✅ | Phase 3 消费 |
| **syntax-rules** | **语法规则** | ✅ | **直用 form 工作，缩写 form 和原版一致** |
| **define-syntax-rule** | **定义语法规则** | ❌ | **Phase 1 消费** |
| **require** | **引用（顶层）** | ❌ | **Phase 1 消费** |
| provide | 提供 | ✅ | Phase 2 消费（晚于 require） |

---

## 给 macro writer 的建议

```racket
#lang racket-cn

;; ✅ 推荐：定义语法 + 语法匹配
(定义语法 (my-or stx)
  (语法匹配 stx ()
    [(_) #'#f]
    [(_ x) #'x]
    [(_ x y ...) #'(令 ([t x]) (如果 t t (my-or y ...)))]))

;; ✅ 也可以：定义语法 + 语法规则（直用 form）
(定义语法 my-or
  (语法规则 ()
    [(_) #f]
    [(_ x) x]
    [(_ x y ...) (令 ([t x]) (如果 t t (my-or y ...)))]))

;; ❌ 不行：定义语法规则（Phase 1 不识别）
;; (定义语法规则 my-or ...)

;; ❌ 不行：模块顶层用 引用 替代 require
;; (引用 racket/list)
;; 请用 (require racket/list)
```
