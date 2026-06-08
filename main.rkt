#lang racket/base

;; ============================================================
;; racket-cn — Racket 中文版实现
;;
;; 对齐 Racket 的 main.rkt 模式：自身即为实现，reader 自循环。
;; #lang racket-cn 和 (require racket-cn) 的入口。
;; ============================================================

(require racket
         "racket/base-impl.rkt"   ;; racket/base 全量
         "module.rkt"             ;; require/provide 中文别名
         "json/main.rkt"          ;; json (顶层集合)
         "racket/main.rkt")       ;; racket/xxx 子模块全部

;; 语言核心绑定
(provide #%module-begin #%app #%datum #%top)

;; 英文原语全部透传
(provide (all-from-out racket))

;; 中文子模块 (phase 0)
(提供
 (全定义导出))

;; 语法工具 (phase 1: define-syntax body 中可用)
(require (for-syntax racket/base))
(provide
 ;; Phase-1 中文语法工具（和 for-syntax racket/base 对称）
 (for-syntax (rename-out [syntax-case 语法匹配]
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
                         [local-expand 局部展开]
                         [lambda 函数]
                         [if 如果]
                         [let 令]
                         [let* 依次令]
                         [letrec 递归令]
                         [and 且]
                         [or 或]
                         [not 非]
                         [list 列表]
                         [cons 对]
                         [car 首]
                         [cdr 尾]
                         [quote 引述]
                         [quasiquote 准引用]
                         [define 定义]
                         [begin 顺序求值]
                         [values 多值]))
 (all-from-out "racket/base-impl.rkt")
 (all-from-out "module.rkt")
 (all-from-out "racket/main.rkt")
 (all-from-out "json/main.rkt")

 ;; racket 特有绑定（不在 racket/base 中）
 (rename-out
  [delay         延迟]
  [force         求值]
  [promise?      承诺?]
  [command-line  命令行]))

;; ============================================================
;; Reader 子模块 — 支持 #lang racket-cn
;; ============================================================
(module reader syntax/module-reader
  racket-cn)
