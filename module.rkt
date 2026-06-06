#lang racket/base
(require (for-syntax racket/base))

;; ============================================================
;; racket-cn/module — 模块系统中文原语
;;
;; require / provide / all-defined-out 是模块级形式，
;; 不属于 racket/base，而是模块语言的一部分。
;; ============================================================

(define-syntax 引用 (make-rename-transformer #'require))
(define-syntax 提供 (make-rename-transformer #'provide))
(define-syntax 全定义导出 (make-rename-transformer #'all-defined-out))

(provide 引用 提供 全定义导出)
