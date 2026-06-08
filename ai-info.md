# ai-info — racket-cn 绑定添加指南

> 给 AI 或贡献者的规范：如何添加中文绑定、哪些能改哪些不能改。

## 绑定添加方式（3 种）

### 方式 1：`rename-out`（标识符 → 中文别名）

用于：普通函数、宏、特殊形式。在 `base-impl.rkt` 或子模块 `.rkt` 中。

```racket
;; base-impl.rkt
(provide (rename-out [define 定义] [lambda 函数] ...))

;; 子模块（如 list.rkt）
(provide (rename-out [take 取前] [drop 去掉前] ...))
```

**要求**：
- 英文原名必须已通过 `require` 导入
- Phase-1 绑定需要 `(provide (for-syntax (rename-out ...)))`
- 子模块文件结构：`(require racket/xxx)` → `(provide (rename-out ...))`

### 方式 2：`define-syntax` + `make-rename-transformer`（require/provide 子 form）

用于：`require`/`provide` 的子 form（`for-syntax`、`only-in`、`all-from-out` 等）。
在 `module.rkt` 中。

```racket
;; module.rkt
(define-syntax 编译期 (make-rename-transformer #'for-syntax))
(define-syntax 仅导入 (make-rename-transformer #'only-in))
```

**为什么不用 `rename-out`**：这些 form 在 require/provide 内部被 expander 通过
`free-identifier=?` 解析，而 `rename-out` 只在模块顶层 provide 时生效。
`define-syntax` 定义的 binding 在所有位置可用。

### 方式 3：`定义-关键字函数`（关键字参数函数）

用于：需要中文关键字参数的函数。在 `base-impl.rkt` 或 `file.rkt` 中。

```racket
(定义-关键字函数 打开输出文件 open-output-file
  (#:如果存在 #:exists (截断 truncate) (替换 replace))
  (#:模式 #:mode (文本 text)))
```

**声明格式**：`(#:中文kw #:english-kw (中文val . english-val) ...)`

定义后必须在模块末尾 `(provide 函数名 ...)`。

## 不能通过 rename 添加的 form

这些 form 在 expander 的 Phase 1（module-begin 扫描）被消费，
早于 Phase 2 的 rename 绑定建立，因此 `rename-out` 或 `make-rename-transformer` 都无效：

| form | 中文 | 替代方案 |
|------|------|---------|
| `require` | `引用` | 模块顶层必须用 `require`；`(require (引用 ...))` 也不行 |
| `define-syntax-rule` | `定义语法规则` | 用 `定义语法` + `语法匹配` |

## 跨 Phase 注意事项

### Phase-1 绑定（macro writer 用）

这些在 `define-syntax` 体内可用。`base-impl.rkt` 通过 `(provide (for-syntax ...))` 提供：

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

Phase-1 只有 `racket/base` 的 for-syntax 提供，中文 IO 函数不可用。

### `语法规则` 的使用限制

和原版 `syntax-rules` 行为一致：

```racket
;; ✅ 直用 form
(定义语法 tt (语法规则 () [(_ x) #'x]))

;; ❌ 缩写 form（语法糖展开为 lambda，syntax-rules 返回 procedure 非 syntax）
(定义语法 (tt stx) (语法规则 () [(_ x) #'x]))
```

推荐使用 `语法匹配`，两种 form 都支持。

## 文件职责

| 文件 | 职责 | 添加方式 |
|------|------|---------|
| `base-impl.rkt` | racket/base 核心绑定 + 关键字函数 | rename-out, 定义-关键字函数 |
| `module.rkt` | require/provide 子 form | define-syntax + make-rename-transformer |
| `file.rkt` 等 | 子模块绑定 | rename-out, 定义-关键字函数 |
| `kw.rkt` | 定义-关键字函数 宏实现 | 不需要改 |
| `main.rkt` | #lang racket-cn 入口 | require 新子模块 + provide |
| `translator.rkt` | 中英双向翻译器 | 自动扫描所有源文件，无需手动更新 |
| `translator-data.rkt` | 翻译映射数据（自动生成）| 由 `racket translator.rkt --gen-data` 生成 |

## 添加新子模块步骤

1. 创建 `xxx.rkt`：`(require racket/xxx)` → `(provide (rename-out [...]))`
2. 在 `main.rkt` 的 `require` 列表添加 `"xxx.rkt"`
3. 在 `main.rkt` 的 `provide` 列表添加 `(all-from-out "xxx.rkt")`
4. 更新 README.md 文件结构
5. 重新生成翻译数据：`racket translator.rkt --gen-data`

## 测试

- `test-lang.rkt` — #lang racket-cn 冒烟测试
- `test-translator.rkt` — 104 项翻译器测试
- 添加新绑定后两条都要跑
