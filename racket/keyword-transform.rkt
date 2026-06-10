#lang racket/base
(require racket/keyword-transform)
(require "../rename-macro.rkt")

(rename-define
  [syntax-procedure-alias-property 语法过程别名属性]
  [syntax-procedure-converted-arguments-property 语法过程转换参数属性]
)
