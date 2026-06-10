#lang racket/base
(require racket/fasl)
(require "../rename-macro.rkt")

(rename-define
  [fasl->s-exp 快速加载->S表达式]
  [s-exp->fasl S表达式->快速加载]
)
