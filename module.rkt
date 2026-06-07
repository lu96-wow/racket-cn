#lang racket/base
(require (for-syntax racket/base))

;; ============================================================
;; racket-cn/module — 模块系统中文原语
;;
;; require / provide 及其子 form 的中文别名。
;; 使用 define-syntax + make-rename-transformer 模式，
;; 而非 rename-out（因 require 顶层 form 在 rename 建立前被消费）。
;;
;; 注意: 引用（require）在模块顶层不能替代 require（展开器时序限制），
;; 但 require/provide 的**子 form**（编译期、仅导入、全导出等）可用。
;; ============================================================

;; ── 顶层 require/provide ──
(define-syntax 引用       (make-rename-transformer #'require))
(define-syntax 提供       (make-rename-transformer #'provide))
(define-syntax 全定义导出 (make-rename-transformer #'all-defined-out))

;; ── phase 修饰（require & provide 通用）──
(define-syntax 编译期     (make-rename-transformer #'for-syntax))
(define-syntax 标签期     (make-rename-transformer #'for-label))
(define-syntax 元期       (make-rename-transformer #'for-meta))
(define-syntax 模板期     (make-rename-transformer #'for-template))

;; ── provide 子 form ──
(define-syntax 全导出     (make-rename-transformer #'all-from-out))
(define-syntax 排除导出   (make-rename-transformer #'except-out))
(define-syntax 重命名导出 (make-rename-transformer #'rename-out))

;; ── require 子 form ──
(define-syntax 仅导入     (make-rename-transformer #'only-in))
(define-syntax 排除导入   (make-rename-transformer #'except-in))
(define-syntax 前缀导入   (make-rename-transformer #'prefix-in))
(define-syntax 重命名导入 (make-rename-transformer #'rename-in))

(provide
 引用 提供 全定义导出
 编译期 标签期 元期 模板期
 全导出 排除导出 重命名导出
 仅导入 排除导入 前缀导入 重命名导入)
