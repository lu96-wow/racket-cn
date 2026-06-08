#lang racket/base

;; ============================================================
;; racket-cn/base — #lang racket-cn/base 和 (require racket-cn/base) 入口
;;
;; 使用扁平 require+provide 结构（对齐用户集合规范）。
;; Racket 内置集合使用 (module base ...) 包装，但用户集合不支持此模式。
;; ============================================================

(require "racket/base-impl.rkt"
         "module.rkt")

(provide (all-from-out "racket/base-impl.rkt")
         (all-from-out "module.rkt"))

;; ============================================================
;; Reader 子模块 — 支持 #lang racket-cn/base
;; ============================================================
(module reader syntax/module-reader
  racket-cn/base)
