# racket-cn

Racket 语言的中文版本。提供 `#lang racket-cn` 和 `#lang racket-cn/base`。

覆盖 **1176 条**中英文翻译对，涵盖 racket/base 核心、82 个 racket/ 子模块、
json、FFI、module.rkt，以及中文关键字参数翻译。翻译映射全部从源文件自动扫描生成。

## 安装

```bash
# 推荐：raco pkg install
raco pkg install https://github.com/lu96-wow/racket-cn.git

# 本地开发：raco link
cd /path/to/racket-cn && raco link racket-cn

# 卸载
raco pkg remove racket-cn
# 或 raco link -r racket-cn
```

## 使用

### 语言模式

```racket
#lang racket-cn           ;; 完整版（racket/base + 全部子模块）
#lang racket-cn/base      ;; 基础版（仅 racket/base）
#lang racket-cn/translator ;; 翻译器脚本模式
```

### 子模块引用

```racket
(require racket-cn/racket)       ;; 所有 racket/* 中文别名
(require racket-cn/racket/math)  ;; 仅数学模块
(require racket-cn/racket/tcp)   ;; TCP 网络
(require racket-cn/json)         ;; JSON 中文别名
(require racket-cn/ffi/unsafe)   ;; FFI 中文别名
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

;; Phase-1 中文绑定需显式 require（和标准 Racket 一致）
(require (for-syntax racket-cn/base))
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

### FFI

```racket
(require racket-cn/ffi/unsafe)

(分配内存 128)                              ; malloc
(指针-引用 ptr 类型-整数 0)                  ; ptr-ref
(FFI库 "libc")                              ; ffi-lib
```

### 翻译器

```racket
#lang racket-cn/translator

;; 单文件
(翻译文件-英->中 "input.rkt")
(翻译文件-英->中 "input.rkt" "output-cn.rkt")
(翻译文件-中->英 "input-cn.rkt" "output-en.rkt")

;; 目录递归
(翻译文件夹-英->中 "src/" "out-cn/")
(翻译文件夹-中->英 "src-cn/" "out-en/")
```

命令行：

```bash
racket translator.rkt input.rkt -o output.rkt --en-to-cn
racket translator.rkt --gen-data          # 重新生成翻译数据
racket translator.rkt --update-tests      # 自动更新测试用例
racket translator.rkt --dir src/ out/     # 递归翻译目录
```

## 注意事项

- 宏定义用 `定义语法` + `语法匹配`，`定义语法规则` 改名后模块层不识别
- `语法规则` 只能在 `(定义语法 name (语法规则 ...))` 直用 form 下工作
- Phase-1 中文绑定（`语法匹配`、`带语法` 等）需显式 `(require (for-syntax racket-cn/base))`，和标准 Racket 一致
- 映射表由 `translator.rkt` 自动扫描源文件生成，添加新模块后运行 `racket translator.rkt --gen-data` 即可

## 覆盖

| 集合 | 模块数 | 说明 |
|------|--------|------|
| racket/base 核心 | 1 | 定义、函数、如果、令… + 关键字参数翻译 |
| racket/* 子模块 | 82 | 对应 /usr/racket/collects/racket/*.rkt |
| json | 1 | JSON 处理中文别名 |
| ffi/unsafe | 6 | FFI 中文别名（malloc、ptr-ref…） |
| module.rkt | 1 | require/provide 子 form 中文原语 |
| **总计** | **1176 条映射** | |

完整限制参考 [局限.md](局限.md)。
