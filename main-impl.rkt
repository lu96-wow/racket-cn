#lang racket/base

;; ============================================================
;; racket-cn/main-impl -- racket 中文版实现
;; ============================================================

(require racket
         "base-impl.rkt"
         "list.rkt"
         "function.rkt"
         "match.rkt"
         "class.rkt"
         "contract.rkt"
         "set.rkt"
         "dict.rkt"
         "stream.rkt"
         "string.rkt"
         "future.rkt"
         "port.rkt")

;; 语言核心绑定
(provide #%module-begin #%app #%datum #%top)

;; 英文原语透传
(provide (all-from-out racket))

;; 子模块的中文绑定
(provide
 (all-from-out "base-impl.rkt")
 (all-from-out "list.rkt")
 (all-from-out "function.rkt")
 (all-from-out "match.rkt")
 (all-from-out "class.rkt")
 (all-from-out "contract.rkt")
 (all-from-out "set.rkt")
 (all-from-out "dict.rkt")
 (all-from-out "stream.rkt")
 (all-from-out "string.rkt")
 (all-from-out "future.rkt")
 (all-from-out "port.rkt")

 ;; 从 racket 直接提供的中文别名
 (rename-out
  [delay 延迟]
  [force 求值]
  [promise? 承诺?]
  [command-line 命令行]))
