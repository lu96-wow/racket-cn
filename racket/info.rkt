#lang info

(define collection "racket-cn/racket")

(define version "0.2.0")

(define title "racket-cn/racket — Racket 标准库中文别名")

(define authors '("debian"))

(define description
  (string-append
   "racket-cn 的 racket 子模块合集。\\n"
   "对应 /usr/share/racket/collects/racket/ 结构。\\n"
   "覆盖 82 个 racket/xxx 子模块，1031 条中文标识符映射。"))

(define deps '("racket-cn" "base"))

(define build-deps '())

(define auto-tests '())
