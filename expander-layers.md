# 展开器分层 & rename 限制

`racket-cn` 用 `rename-out` 将标识符映射到中文。绝大多数 form 正常工作，
但有少量在 rename 绑定建立**之前**就被 expander 消费，因此无法改名。

## 展开器处理时序

```
源代码
  ├─ Reader       : 文本 → syntax（纯符号）
  ├─ Module-begin : 按 free-identifier=? 分类顶层 form
  │   ⚠ require-form, define-syntax-rule 在这一层被消费
  ├─ Binding 解析 : rename-out 在这一层生效
  ├─ 局部展开     : 表达式层，所有 binding 已就绪
  └─ 编译
```

**核心**：哪个 form 在 Binding 解析之前就被消费，哪个就不能 rename。

## 分类表

| form | 中文 | 消费层 | rename-out |
|------|------|--------|-----------|
| `require` | `引用` | Module-begin | ❌ |
| `provide` | `提供` | Binding 解析 | ✅ |
| `define` | `定义` | 局部展开 | ✅ |
| `define-syntax` | `定义语法` | 局部展开 | ✅ |
| `define-syntax-rule` | `定义语法规则` | Module-begin | ❌ |
| `syntax-rules` | `语法规则` | 局部展开 | ✅* |
| `lambda` `if` `let` ... | 函数 如果 令 ... | 局部展开 | ✅ |
| `struct` `match` `class` ... | 结构 匹配 类 ... | 局部展开 | ✅ |

\* `语法规则` 和原版 `syntax-rules` 一样，只在 `(define-syntax name (语法规则 ...))` 直用 form 下工作，
缩写 form `(define-syntax (name stx) (语法规则 ...))` 不行（语法糖展开为 lambda，类型不匹配）。

## require/provide 子 form

`provide` 本身可用，`require` 顶层不可用。但两者的子 form 通过
`module.rkt` 的 `define-syntax` + `make-rename-transformer` 全部可用：

```
编译期 标签期 元期 模板期    — phase 修饰
全导出 排除导出 重命名导出   — provide 子 form
仅导入 排除导入 前缀导入 重命名导入 — require 子 form
全定义导出                  — provide 顶层
```

## Phase-1 绑定

`base-impl.rkt` 的 `(provide (for-syntax (rename-out ...)))` 已将
`syntax-case`/`语法匹配`、`with-syntax`/`带语法` 等 12 个 macro writer 工具
提供到 phase 1。在 `define-syntax` 体内可用。

Phase-1 只有 `racket/base` 的英文绑定，中文 IO 函数不可用。

## 为什么 `提供` 能用但 `引用` 不行

两者都用 `free-identifier=?` 判断。但：
- `require`-form 在模块体处理前就收集，此时模块自身的 `rename-out` 还没生效
- `provide`-form 在模块体处理后才收集，此时所有 binding 已就绪

这是"先有鸡还是先有蛋"——expander 需要先知道哪些是 define-form 才能建立环境，
但 `定义语法规则` 的绑定依赖于这个环境。
