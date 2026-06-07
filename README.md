# racket-cn

Racket 语言的中文版本。提供 `#lang racket-cn` 和 `#lang racket-cn/base`。

覆盖 291 个 `racket/base` 中文别名，21 个常用子模块，支持中文关键字参数翻译。

## 安装

### 方式一：raco pkg install（推荐，从 git 安装）

```bash
raco pkg install https://github.com/lu96-wow/racket-cn.git
```

此后 `#lang racket-cn` 和 `(require racket-cn)` 即可用。

### 方式二：raco link（本地开发）

```bash
cd /path/to/racket-cn
raco link racket-cn
# 或手动创建软链接：
# ln -s /path/to/racket-cn $(racket -e '(displayln (find-collects-dir))')/racket-cn
```

## 卸载

```bash
# raco pkg 安装的：
raco pkg remove racket-cn

# raco link 安装的：
raco link -r racket-cn
```

## 快速开始

```racket
#lang racket-cn

(定义 (阶乘 n)
  (如果 (<= n 1)
      1
      (* n (阶乘 (- n 1)))))

(显示行 (阶乘 5))

;; 关键字参数翻译
(写入到文件 "你好" "/tmp/test.txt" #:如果存在 '截断)
(显示行 (文件->字符串 "/tmp/test.txt"))

;; 宏定义
(定义语法 (my-or stx)
  (语法匹配 stx ()
    [(_) #'#f]
    [(_ x) #'x]
    [(_ x y ...) #'(let ([t x]) (如果 t t (my-or y ...)))]))
```

## 文件结构

> 对齐 Racket 原生结构：base.rkt 使用 `(module base ...)` 模式，
> main.rkt 自身即为实现，reader 子模块自循环指向自身。

```
racket-cn/
├── base.rkt          # #lang racket-cn/base 入口 (module base 模式)
├── base-impl.rkt     # racket/base (291 rename-out + 关键词宏)
├── kw.rkt            # 定义-关键字函数 宏
├── main.rkt          # #lang racket-cn 入口 + 实现 (对齐 Racket)
├── module.rkt        # 引用/提供/全定义导出
│
├── file.rkt          # racket/file
├── hash.rkt          # racket/hash
├── vector.rkt        # racket/vector
├── sequence.rkt      # racket/sequence
├── date.rkt          # racket/date
├── random.rkt        # racket/random
├── path.rkt          # racket/path
├── system.rkt        # racket/system
├── generator.rkt     # racket/generator
├── pretty.rkt        # racket/pretty
├── list.rkt          # racket/list
├── port.rkt          # racket/port
├── string.rkt        # racket/string
├── function.rkt      # racket/function
├── match.rkt         # racket/match
├── class.rkt         # racket/class
├── contract.rkt      # racket/contract
├── set.rkt           # racket/set
├── dict.rkt          # racket/dict
├── stream.rkt        # racket/stream
├── future.rkt        # racket/future
└── info.rkt
```

## 关键字翻译

```racket
#lang racket-cn

;; 一行定义中文包装
(定义-关键字函数 打开输出文件 open-output-file
  (#:如果存在 #:exists (截断 truncate) (替换 replace))
  (#:模式 #:mode (文本 text)))

;; 全中文
(打开输出文件 "a.txt" #:如果存在 '截断 #:模式 '文本)
;; → (open-output-file "a.txt" #:exists 'truncate #:mode 'text)

;; 中英混用
(打开输出文件 "b.txt" #:如果存在 'replace)
;; → (open-output-file "b.txt" #:exists 'replace)

;; 纯英文透传
(打开输出文件 "c.txt" #:exists 'truncate)
;; → (open-output-file "c.txt" #:exists 'truncate)
```

## 注意事项

- 宏定义体内使用中文名（`语法匹配`、`带语法` 等）需要 `(require (for-syntax racket/base))`
- `syntax-rules` 改名后展开器不识别，建议用 `syntax-case`
- `引用`（`require`）在模块顶层不能替代 `require`（展开器时序限制）
