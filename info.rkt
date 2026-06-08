#lang info

(define collection "racket-cn")

(define version "0.2.0")

(define title "racket-cn — 中文 Racket 语言")

(define authors '("lu96-wow" "debian"))

(define description
  (string-append
   "Racket 语言的中文版本。\n"
   "提供 #lang racket-cn 和 #lang racket-cn/base。\n"
   "覆盖 1031 条中英文标识符映射，82 个 racket/ 子模块，\n"
   "支持中文关键字参数翻译 (#:如果存在 '截断 → #:exists 'truncate)。"))

(define deps '("base"))

(define build-deps '())

(define auto-tests '("test-translator.rkt"))
