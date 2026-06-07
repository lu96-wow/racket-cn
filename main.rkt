#lang racket/base

;; ============================================================
;; racket-cn — Racket 中文版实现
;;
;; 对齐 Racket 的 main.rkt 模式：自身即为实现，reader 自循环。
;; #lang racket-cn 和 (require racket-cn) 的入口。
;; ============================================================

(require racket
         "base-impl.rkt"      ;; racket/base 全量
         "module.rkt"         ;; require/provide 中文别名
         "class.rkt"          ;; racket/class
         "contract.rkt"       ;; racket/contract
         "date.rkt"           ;; racket/date
         "dict.rkt"           ;; racket/dict
         "file.rkt"           ;; racket/file
         "function.rkt"       ;; racket/function
         "future.rkt"         ;; racket/future
         "generator.rkt"      ;; racket/generator
         "hash.rkt"           ;; racket/hash
         "hash.rkt"           ;; racket/hash
         "json.rkt"           ;; json
         "list.rkt"           ;; racket/list
         "match.rkt"          ;; racket/match
         "path.rkt"           ;; racket/path
         "port.rkt"           ;; racket/port
         "pretty.rkt"         ;; racket/pretty
         "random.rkt"         ;; racket/random
         "sequence.rkt"       ;; racket/sequence
         "set.rkt"            ;; racket/set
         "splicing.rkt"       ;; racket/splicing
         "stream.rkt"         ;; racket/stream
         "string.rkt"         ;; racket/string
         "system.rkt"         ;; racket/system
          "trace.rkt"          ;; racket/trace
         "vector.rkt")        ;; racket/vector

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
 (all-from-out "base-impl.rkt")
 (all-from-out "module.rkt")
 (all-from-out "class.rkt")
 (all-from-out "contract.rkt")
 (all-from-out "date.rkt")
 (all-from-out "dict.rkt")
 (all-from-out "file.rkt")
 (all-from-out "function.rkt")
 (all-from-out "future.rkt")
 (all-from-out "generator.rkt")
 (all-from-out "hash.rkt")
 (all-from-out "hash.rkt")
 (all-from-out "json.rkt")
 (all-from-out "list.rkt")
 (all-from-out "match.rkt")
 (all-from-out "path.rkt")
 (all-from-out "port.rkt")
 (all-from-out "pretty.rkt")
 (all-from-out "random.rkt")
 (all-from-out "sequence.rkt")
 (all-from-out "set.rkt")
 (all-from-out "stream.rkt")
 (all-from-out "splicing.rkt")
 (all-from-out "string.rkt")
 (all-from-out "system.rkt")
 (all-from-out "trace.rkt")
 (all-from-out "vector.rkt")

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
