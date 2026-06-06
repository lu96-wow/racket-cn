#lang racket/base

;; ============================================================
;; racket-cn/base -- 薄转发层
;;
;; #lang racket-cn/base 和 (require racket-cn/base) 的入口。
;; 实际实现在 base-impl.rkt 中。
;; ============================================================

(require "base-impl.rkt")

(provide (all-from-out "base-impl.rkt"))

;; ============================================================
;; Reader 子模块 -- 支持 #lang racket-cn/base
;; ============================================================
(module reader syntax/module-reader
  racket-cn/base-impl)
