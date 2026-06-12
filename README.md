# racket-cn

Racket 语言的中文版本。提供 `#lang racket-cn` 和 `#lang racket-cn/base`。

覆盖 **~1400 条**中英文翻译对，涵盖 racket/base 核心、88 个 racket/ 子模块、
json、module.rkt，以及中文关键字参数翻译。

## 安装

> ⚠️ 只能选一种方式安装。如需切换，请先卸载当前版本。

### 远程安装（推荐）

从 GitHub 直接安装：

```bash
raco pkg install https://github.com/lu96-wow/racket-cn.git
```

### Git 安装

从 GitHub 克隆后安装：

```bash
git clone https://github.com/lu96-wow/racket-cn.git
cd racket-cn
raco pkg install --link
```

### 链接安装

已有本地源码目录时：

```bash
cd /path/to/racket-cn
raco pkg install --link
```

### 卸载

```bash
raco pkg remove racket-cn
```

---

## 开发

用于修改源码后即时生效（区别于安装，此方式不经过 `raco pkg` 管理）：

```bash
cd /path/to/racket-cn
raco link racket-cn
```

解除链接：

```bash
raco link -r racket-cn
# 如果残留符号链接，手动清理：
rm -f $(raco link -s 2>/dev/null || echo ~/.local/share/racket/*/collects)/racket-cn
```

## 使用

### 语言模式

```racket
#lang racket-cn           ;; 完整版（racket/base + 全部子模块）
#lang racket-cn/base      ;; 基础版（仅 racket/base）
```

### 子模块引用

```racket
(require racket-cn/racket)       ;; 所有 racket/* 中文别名
(require racket-cn/racket/math)  ;; 仅数学模块
(require racket-cn/racket/tcp)   ;; TCP 网络
(require racket-cn/json)         ;; JSON 中文别名
```

### 快速开始

```racket
#lang racket-cn

(定义 (阶乘 n)
  (如果 (<= n 1)
       1
       (* n (阶乘 (- n 1)))))

(显示行 (阶乘 5))
```

### 关键字参数

```racket
(写入到文件 "你好" "/tmp/t.txt" #:如果存在 '截断)
(显示行 (文件->字符串 "/tmp/t.txt"))
;; → (write-to-file "你好" "/tmp/t.txt" #:exists 'truncate)
```

### 宏定义

```racket
;; 使用 定义语法 + 语法匹配（推荐）
(定义语法 (my-or stx)
  (语法匹配 stx ()
    [(_) #'#f]
    [(_ x) #'x]
    [(_ x y ...) #'(令 ([t x]) (如果 t t (my-or y ...)))]))
```

### require/provide 子 form

```racket
;; require 子 form（全中文）
(require (编译期 racket/base))              ;; for-syntax
(require (仅导入 racket/list take drop))     ;; only-in
(require (排除导入 racket/function curry))   ;; except-in
(require (前缀导入 fn- racket/base))         ;; prefix-in
(require (重命名导入 racket/base [cons 对]))  ;; rename-in

;; provide 子 form（全中文）
(提供 (全导出 racket/base))                  ;; all-from-out
(提供 (排除导出 racket/base values))         ;; except-out
(提供 (编译期 语法匹配))                    ;; for-syntax in provide
```

> `require` 本体在模块顶层不能用 `引用` 替代（展开器时序限制），子 form 全部可用。

### 映射查询

```racket
;; 查询英文对应的中文
(query-mapping 'define)
;; → '(define 定义 rename-define/for-syntax \".../main.rkt\")

;; 查询中文对应的英文
(query-mapping '打开-输入-无数据)
;; → '(open-input-nowhere 打开-输入-无数据 rename-define \".../port.rkt\")

;; 查看全部英文→中文映射
(en->cn-list)

;; 查看全部中文→英文映射
(cn->en-list)
```

## 翻译器

`racket-cn/translator` 提供双向翻译工具，可将英文 Racket 代码翻译为中文，反之亦然。

```racket
(require racket-cn/translator)
```

### 更新映射表

翻译器依赖自动生成的映射表。安装后应先运行一次，之后修改源码中的翻译对后也需重新运行：

```racket
(update-translator-map)  ;; 重新扫描源文件，生成 ~1380 条映射
```

### 文件翻译

```racket
;; 英文 → 中文
(en-to-cn "src.rkt" "out.rkt")

;; 中文 → 英文
(cn-to-en "src.rkt" "out.rkt")

;; 静默覆盖（跳过确认提示）
(en-to-cn "src.rkt" "out.rkt" #:confirm? #f)
```

输出文件已存在时会交互确认：`y`覆盖 / `n`跳过 / `a`全部覆盖 / `q`退出。

### 目录翻译

递归翻译整个目录中的 `.rkt` 文件，保持目录结构：

```racket
;; 英文目录 → 中文目录
(en-to-cn-folder "racket-src/" "racket-src-cn/")

;; 中文目录 → 英文目录
(cn-to-en-folder "racket-src-cn/" "racket-src-en/")
```

目录翻译会先列出所有将被覆盖的文件，再逐个询问确认。

### 翻译内容

| 项目 | 示例 |
|------|------|
| `#lang` 行 | `#lang racket` ↔ `#lang racket-cn` |
| 标识符 | `define` ↔ `定义`, `lambda` ↔ `函数` |
| 关键字 | `#:exists` ↔ `#:如果存在` |
| 模块路径 | `racket/list` ↔ `racket-cn/racket/list` |
| 特殊模块 | `json` ↔ `racket-cn/json` |
| require 子形式 | `only-in`, `prefix-in`, `for-syntax` 等保留结构，仅翻译路径 |

> 字符串和数字原样保留，不会被翻译。

## 注意事项

- 宏定义用 `定义语法` + `语法匹配`，`定义语法规则` 改名后模块层不识别
- `语法规则` 只能在 `(定义语法 name (语法规则 ...))` 直用 form 下工作
- Phase-1 中文绑定（`语法匹配`、`函数`、`如果` 等 32 个）已通过 `main.rkt`（30 个）和 `stxparam.rkt`（2 个）的 `rename-define/for-syntax` 提供，和 `(require (for-syntax racket/base))` 对称

## 覆盖

| 集合 | 模块数 | 说明 |
|------|--------|------|
| racket/base 核心 | 1 | 定义、函数、如果、令… + 关键字参数翻译 |
| racket/* 子模块 | 88 | 对应 /usr/racket/collects/racket/*.rkt |
| json | 1 | JSON 处理中文别名 |
| module.rkt | 1 | require/provide 子 form 中文原语 |
| **总计** | **~1400 条映射** | |

完整限制参考 [局限.md](局限.md)。
