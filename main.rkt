#lang racket/base

;; ============================================================
;; racket-cn/main -- 薄转发层
;;
;; #lang racket-cn 和 (require racket-cn) 的入口。
;; 实际实现在 main-impl.rkt 中。
;; ============================================================

(require "main-impl.rkt")

(provide (all-from-out "main-impl.rkt"))

;; ============================================================
;; Reader 子模块 -- 支持 #lang racket-cn
;; ============================================================
(module reader syntax/module-reader
  racket-cn/main-impl)
