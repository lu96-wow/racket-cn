# racket-cn

Racket 语言的中文版本。提供 `#lang racket-cn` 和 `#lang racket-cn/base`。

覆盖 291 个 `racket/base` 中文别名，24 个子模块，中文关键字参数翻译，
require/provide 子 form 中文原语。

## 安装

```bash
# 方式一：raco pkg install（推荐）
raco pkg install https://github.com/lu96-wow/racket-cn.git

# 方式二：raco link（本地开发）
cd /path/to/racket-cn && raco link racket-cn
```

卸载：`raco pkg remove racket-cn` 或 `raco link -r racket-cn`

### 子模块独立引用

```racket
(require racket-cn/racket)   ;; 加载所有 racket/xxx 中文别名
(require racket-cn/json)     ;; 仅加载 JSON 中文别名
(require racket-cn/racket/list)  ;; 仅加载 racket/list 中文别名
```

## 快速开始

```racket
#lang racket-cn

(定义 (阶乘 n)
  (如果 (<= n 1)
      1
      (* n (阶乘 (- n 1)))))

(显示行 (阶乘 5))

;; 关键字参数
(写入到文件 "你好" "/tmp/t.txt" #:如果存在 '截断)
(显示行 (文件->字符串 "/tmp/t.txt"))

;; 宏定义（推荐用 语法匹配）
(定义语法 (my-or stx)
  (语法匹配 stx ()
    [(_) #'#f]
    [(_ x) #'x]
    [(_ x y ...) #'(let ([t x]) (如果 t t (my-or y ...)))]))

;; require/provide 子 form
(require (仅导入 racket/list take drop))
(提供 (编译期 语法匹配))
```

## 文件结构

```
racket-cn/
│
├── base.rkt          # #lang racket-cn/base 入口
├── main.rkt          # #lang racket-cn 入口 + 实现
├── module.rkt        # require/provide 子 form 中文原语
├── kw.rkt            # 定义-关键字函数 宏
├── translator.rkt    # 中英双向翻译器
├── json.rkt          # \`(require racket-cn/json)\` 入口 shim
├── racket.rkt        # \`(require racket-cn/racket)\` 入口 shim
├── base/lang/        # #lang racket-cn/base reader stub
├── info.rkt
│
├── json/             # json 子集合
│   ├── main.rkt      # JSON 中文别名绑定
│   └── info.rkt
│
├── racket/           # racket/xxx 子集合 (对应 /usr/share/racket/collects/racket/)
│   ├── main.rkt      # \`(require racket-cn/racket)\` 实际入口
│   ├── info.rkt      # 子集合元数据
│   ├── base-impl.rkt # racket/base 中文别名 (291 rename-out + 关键字宏)
│   ├── class.rkt     # racket/class
│   ├── contract.rkt  # racket/contract
│   ├── date.rkt      # racket/date
│   ├── dict.rkt      # racket/dict
│   ├── file.rkt      # racket/file
│   ├── function.rkt  # racket/function
│   ├── future.rkt    # racket/future
│   ├── generator.rkt # racket/generator
│   ├── hash.rkt      # racket/hash
│   ├── list.rkt      # racket/list
│   ├── match.rkt     # racket/match
│   ├── path.rkt      # racket/path
│   ├── port.rkt      # racket/port
│   ├── pretty.rkt    # racket/pretty
│   ├── random.rkt    # racket/random
│   ├── sequence.rkt  # racket/sequence
│   ├── set.rkt       # racket/set
│   ├── splicing.rkt  # racket/splicing
│   ├── stream.rkt    # racket/stream
│   ├── string.rkt    # racket/string
│   ├── system.rkt    # racket/system
│   ├── trace.rkt     # racket/trace
│   └── vector.rkt    # racket/vector
└──
```

## require/provide 子 form 中文原语

通过 `module.rkt` 提供。`require` 本体在模块顶层不能用 `引用` 替代（展开器时序限制），
但其**子 form**全部可用：

```racket
;; require
(require (编译期 racket/base))            ;; for-syntax
(require (仅导入 racket/list take drop))   ;; only-in
(require (排除导入 racket/function curry)) ;; except-in
(require (前缀导入 fn- racket/base))      ;; prefix-in
(require (重命名导入 racket/base [cons 对])) ;; rename-in

;; provide
(提供 (全导出 racket/base))               ;; all-from-out
(提供 (排除导出 racket/base values))      ;; except-out
(提供 (编译期 语法匹配))                 ;; for-syntax in provide
```

## 关键字翻译

```racket
(定义-关键字函数 打开输出文件 open-output-file
  (#:如果存在 #:exists (截断 truncate) (替换 replace))
  (#:模式 #:mode (文本 text)))

(打开输出文件 "a.txt" #:如果存在 '截断 #:模式 '文本)
;; → (open-output-file "a.txt" #:exists 'truncate #:mode 'text)
```

## 注意事项

- 宏定义用 `定义语法` + `语法匹配`，`定义语法规则` 改名后模块层不识别
- `语法规则` 只能在 `(定义语法 name (语法规则 ...))` 直用 form 下工作
- `引用`（`require`）在模块顶层不能替代 `require`
- `for-syntax` 的 phase-1 中文绑定（`语法匹配`、`带语法` 等）已通过 `(provide (for-syntax ...))` 提供
