#lang info

(define collection "racket-cn/racket")

(define version "0.1.0")

(define title "racket-cn/racket — Racket 基础库中文别名")

(define authors '("debian"))

(define description
  (string-append
   "racket-cn 的 racket 子模块合集。\\n"
   "对应 /usr/share/racket/collects/racket/ 结构。\\n"
   "提供 racket/base 核心中文别名 + 24 个 racket/xxx 子模块中文别名。"))

(define deps '("base"))

(define build-deps '())

(define auto-tests '())
