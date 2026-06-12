# racket-cn 翻译方式、文件总览与已知限制

> 记录项目中使用的所有翻译方式、各自适用场景、以及每个文件使用了哪种方式。

## 一、翻译方式总览（5 种）

### 方式 1：`rename-define` — 标识符 → 中文别名（推荐）

**原理**：`(require racket/xxx "../rename-macro.rkt")` 导入英文原版和宏定义，
再 `(rename-define [eng 中文] ...)` 生成 `(provide (rename-out ...))` 展开。

**适用**：普通函数、宏、特殊形式。这些绑定在 expander 的"Binding 解析"阶段建立，正常重命名。

**文件模板**：
```racket
#lang racket/base
(require racket/xxx "../rename-macro.rkt")
(rename-define [english-name 中文名] ...)
```

### 方式 1b：`rename-define/for-syntax` — Phase-1 编译期绑定

**原理**：同方式 1，但展开为 `(provide (for-syntax (rename-out ...)))`，将中文别名提供到 phase 1。

**适用**：macro writer 工具函数，如 `syntax-case`、`make-parameter-rename-transformer` 等。

### 方式 2：`define-syntax` + `make-rename-transformer` — require/provide 子形式

**原理**：`(define-syntax 中文名 (make-rename-transformer #'english-name))` 创建本地 transformer binding。

**适用**：`require` 和 `provide` 的子形式，如 `only-in`、`all-from-out`、`multi-in`、`matching-identifiers-out` 等。

**为什么必须用这种方式**：require/provide 的内部子形式由 expander 通过 `free-identifier=?` 解析，需要 transformer 属性（`prop:require-transformer` / `prop:provide-transformer`）。`rename-out` 在模块间传递时无法正确保留这些属性，只有本地 `define-syntax` 创建的 binding 在所有位置都携带正确的 transformer 属性。

**文件模板**：
```racket
#lang racket/base
(require racket/xxx
         (for-syntax racket/base))
(define-syntax 中文名 (make-rename-transformer #'english-name))
(provide 中文名)
```

### 方式 3：`定义-关键字函数` — 关键字参数翻译

**原理**：`kw.rkt` 定义的宏。在编译期把带中文关键字参数的调用改写为带英文关键字参数的调用。

**适用**：带关键字参数的函数（如 `open-output-file`），需要同时翻译关键字名和关键字值。

**格式**：
```racket
(定义-关键字函数 中文函数名 英文函数名
  (#:中文关键字 #:english-kw (中文值1 英文值1) (中文值2 英文值2)))
```

**为什么 `rename-out` 不够**：Racket 的关键字参数（`#:exists`、`#:mode`）是独立的句法类别，不参与标识符绑定。`rename-out` 只能重命名标识符，无法触及关键字。

### 方式 4：`for-syntax` — Phase-1 编译期绑定

**原理**：通过 `(provide (for-syntax (rename-out ...)))` 将中文别名提供到 phase 1，使它们在 `define-syntax` 体内可用。

**适用**：macro writer 工具函数，如 `syntax-case`、`with-syntax`、`datum->syntax` 等。

**位置**：不在子模块文件中，统一在 `main.rkt` 的 `(provide (for-syntax ...))` 中提供。

---

## 二、不能翻译的 form（expander 时序限制）

以下 form 在 expander 的 Module-begin 阶段被消费，早于 Binding 解析阶段，任何 rename 方式均无效：

| form | 中文 | 说明 |
|------|------|------|
| `require` | `引用` | 模块顶层必须用英文 `require` |
| `define-syntax-rule` | `定义语法规则` | 用 `定义语法` + `语法匹配` 替代 |
| `#%module-begin` | — | 语言内核，不可替代 |
| `#%app` `#%datum` `#%top` | — | 语言内核，不可替代 |

---

## 三、不可翻译的内核模块（`#%kernel` 层）

以下标准 racket 模块使用 `(module xxx '#%kernel ...)` 编写，语言是内核而非 `racket/base`，无法用以上任何方式包装：

| 模块 | 原因 |
|------|------|
| `kernel.rkt` | 包装 `#%kernel` 本身 |
| `for-clause.rkt` | for 循环展开器的内核钩子 |
| `phase+space.rkt` | 阶段/空间操作原语 |
| `provide-transform.rkt` | provide 子形式的底层实现 |
| `require-transform.rkt` | require 子形式的底层实现 |
| `stxparam-exptime.rkt` | 语法参数展开期实现 |

另有 4 个纯内部模块（`init.rkt`、`interactive.rkt`、`load.rkt`、`base.rkt`）无需翻译。

---

## 四、文件 → 翻译方式对照表

### 顶层文件

| 文件 | 职责 | 翻译方式 |
|------|------|---------|
| `main.rkt` | `#lang racket-cn` 和 `(require racket-cn)` 入口 | 方式1b (rename-define/for-syntax, 30 form) + 透传 |
| `base.rkt` | `#lang racket-cn/base` 入口 | 透传 base-impl + module.rkt |
| `racket.rkt` | `(require racket-cn/racket)` 入口 | 透传 racket/main.rkt |
| `module.rkt` | require/provide 顶层及其子形式 | 方式2 (define-syntax) |
| `kw.rkt` | `定义-关键字函数` 宏实现 | —（基础设施） |

### racket/ 子模块文件

| 文件 | 翻译方式 | 中文别名数 |
|------|---------|-----------|
| `base-impl.rkt` | 方式1 (rename-define) + 方式3 (定义-关键字函数) | ~300 |
| `list.rkt` | 方式1 | 24 |
| `function.rkt` | 方式1 | 6 |
| `string.rkt` | 方式1 | 4 |
| `match.rkt` | 方式1 | 8 |
| `math.rkt` | 方式1 | 24 |
| `hash.rkt` | 方式1 | 9 |
| `vector.rkt` | 方式1 | 23 |
| `format.rkt` | 方式1 | 8 |
| `promise.rkt` | 方式1 | 13 |
| `class.rkt` | 方式1 | 若干 |
| `contract.rkt` | 方式1 | 若干 |
| `struct.rkt` | 方式1 | 若干 |
| `syntax.rkt` | 方式1 | 若干 |
| `stxparam.rkt` | 方式1 + 方式1b (rename-define/for-syntax, 2 form) | 5 |
| `...` | 方式1 (rename-define) | — |
| **`provide.rkt`** | **方式2 (define-syntax)** | 2 |
| **`provide-syntax.rkt`** | 方式1 (rename-define) | 1 |
| **`require.rkt`** | **方式2 (define-syntax)** | 5 |
| **`require-syntax.rkt`** | 方式1 (rename-define) | 1 |
| `linklet.rkt` | 方式1 (rename-define) | 36 |
| `unit-exptime.rkt` | 方式1 (rename-define) | 3 |
| `file.rkt` | 方式1 (rename-define) + 方式3 | 若干 |

### 关键区分：`provide-syntax.rkt` vs `provide.rkt`

- **`provide-syntax.rkt`**：`define-provide-syntax` 是**普通宏**（定义 provide 子形式的宏），不是 provide 子形式本身 → 可以用方式1 `rename-define`
- **`provide.rkt`**：`matching-identifiers-out`、`filtered-out` 是 **provide 子形式本身** → 必须用方式2 `define-syntax`

`require-syntax.rkt` 和 `require.rkt` 的关系同理。

---

## 五、添加新子模块步骤

1. 判断模块类型：
   - 普通函数/宏 → 创建文件用**方式1** (`rename-define`)
   - require/provide 子形式 → 创建文件用**方式2** (`define-syntax + make-rename-transformer`)
   - Phase-1 编译期绑定 → 用**方式1b** (`rename-define/for-syntax`)
2. 无论哪种方式，文件头部添加 `(require "<相对路径>/rename-macro.rkt")`
3. 在 `racket/main.rkt` 的 `require` 列表按字母序添加 `"xxx.rkt"`
4. 在 `racket/main.rkt` 的 `provide` 列表按字母序添加 `(all-from-out "xxx.rkt")`

## 六、FFI（ffi/unsafe）——已删除

**`racket-cn/ffi/` 目录已被删除**，原因如下：

### 问题：`_fun` 宏无法重命名

`ffi/unsafe` 中的 `_fun` 是一个**宏**（`define-syntax (_fun stx) ...`），而非普通函数。当我们用 `rename-define` 将其重命名为 `_函数` 后：

1. `_fun` 宏在展开时会检查其参数是否为合法的 ctype 绑定
2. 宏的内部机制（如 `syntax-local-value`）查找的是宏展开上下文中的绑定
3. `rename-define` 生成的 `make-rename-transformer` 在宏展开上下文中无法正确将中文类型名（如 `_整数`）绑定回英文 ctype（`_int`）
4. 结果：`(_函数 _整数 _整数 -> _空)` 报错 `_fun: missing output type`

### 影响范围

不只是 `_fun` 本身，所有需要作为 `_fun` 参数的 C 类型（`_int`, `_void`, `_pointer`, `_string` 等）也无法通过 `rename-define` 重命名后用于 `_fun` 中。

### 解决方案

用户在使用 FFI 时应直接使用英文原版 `ffi/unsafe`：

```racket
(require ffi/unsafe)
;; 使用英文 _fun, _int, _void, _string, _pointer 等
```

其他 `racket-cn/ffi/unsafe/define` 等子模块也被一并删除。

## 七、测试

- `test-lang.rkt` — `#lang racket-cn` 冒烟测试
- `test-all.rkt` — 全面功能测试
- 添加新绑定后运行测试验证
