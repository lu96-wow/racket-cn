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
